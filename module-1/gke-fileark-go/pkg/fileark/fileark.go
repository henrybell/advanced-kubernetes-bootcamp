// Package fileark provides the constructor and ServeHTTP method for the fileark microservice.
// The fileark microservice is responsible for accepting files from clients and then uploading
// them to an archive bucket in Google Cloud Storage.
package fileark

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"mime/multipart"
	"net/http"

	"cloud.google.com/go/storage"

	"github.com/GoogleCloudPlatform/gke-fileark-go/pkg/satokensource"
	"github.com/GoogleCloudPlatform/gke-fileark-go/pkg/sdlog"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	iam "google.golang.org/api/iam/v1"
	"google.golang.org/api/option"
)

// A Receiver accepts file upload requests via HTTP. The files it
// receives are archived in a Google Cloud Storage bucket.
type Receiver struct {
	bucket string
	logger *sdlog.StackdriverLogger
	sc     *storage.Client
}

var (
	ctx = context.Background()
)

// New creates and initializes a Receiver.
func New(bucket string, logger *sdlog.StackdriverLogger, projectID, serviceAccount string) (*Receiver, error) {
	client, err := google.DefaultClient(ctx, iam.CloudPlatformScope, "https://www.googleapis.com/auth/iam")
	if err != nil {
		log.Fatalf("unable to get application default credentials: %+v\n", err)
	}

	fileark := &Receiver{
		bucket: bucket,
		logger: logger,
	}

	if len(serviceAccount) == 0 {
		fileark.sc, err = storage.NewClient(ctx)
	} else {
		// [START TokenSourceClient]
		ts := option.WithTokenSource(oauth2.ReuseTokenSource(nil, satokensource.New(client, logger, projectID, serviceAccount)))
		fileark.sc, err = storage.NewClient(ctx, ts)
		// [END TokenSourceClient]
	}

	if err != nil {
		return nil, err
	}

	return fileark, nil
}

// ServeHTTP handles receiving the file and writing it to the Google Cloud Storage bucket.
func (r Receiver) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		fmt.Fprintf(w, "Must POST to resource [%s]", req.URL)
		return
	}

	file, header, err := req.FormFile("file")
	if err != nil {
		msg := fmt.Sprint("Unable to extract file contents from request")

		r.logger.LogError(msg, err)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "%s [%+v]", msg, err)
		return
	}
	defer file.Close()

	if err = writeToCloudStorage(r.sc, r.logger, file, r.bucket, header.Filename); err != nil {
		msg := fmt.Sprintf("Unable to archive contents of file: %s", header.Filename)

		r.logger.LogError(msg, err)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "%s [%+v]", msg, err)
		return
	}

	fmt.Fprintf(w, "File %s uploaded successfully.\n", header.Filename)
}

func writeToCloudStorage(sc *storage.Client, logger *sdlog.StackdriverLogger, f multipart.File, bucket, obj string) error {
	w := sc.Bucket(bucket).Object(obj).NewWriter(ctx)
	w.ContentType = "application/octet-stream"

	bs, err := ioutil.ReadAll(f)
	if err != nil {
		return err
	}

	if _, err := w.Write(bs); err != nil {
		return err
	}

	if err = w.Close(); err != nil {
		return err
	}

	return nil
}
