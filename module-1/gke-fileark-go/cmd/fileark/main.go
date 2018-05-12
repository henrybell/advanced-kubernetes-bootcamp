// Implements the receiver microservice binary.
package main

import (
	"flag"
	"log"
	"net/http"
	"os"

	"github.com/GoogleCloudPlatform/gke-fileark-go/pkg/cmd"
	"github.com/GoogleCloudPlatform/gke-fileark-go/pkg/fileark"
	"github.com/GoogleCloudPlatform/gke-fileark-go/pkg/sdlog"
)

const (
	logname = "fileark_log"
)

var (
	bucket         = flag.String("bucket", "", "Name of the archival bucket (Required)")
	projectID      = flag.String("projectid", "", "Project ID of the project hosting the application (Required)")
	serviceAccount = flag.String("serviceaccount", "", "Service account to use of publishing")

	logger *sdlog.StackdriverLogger
)

func main() {
	flag.Parse()

	if len(*bucket) == 0 || len(*projectID) == 0 {
		flag.PrintDefaults()
		os.Exit(1)
	}

	logger, err := sdlog.Logger(*projectID, logname)
	if err != nil {
		log.Fatalf("unable to create Stackdriver logger [%+v]", err)
	}

	http.HandleFunc("/_alive", cmd.Liveness)
	http.HandleFunc("/_ready", cmd.Readiness)

	fileark, err := fileark.New(*bucket, logger, *projectID, *serviceAccount)
	if err != nil {
		log.Fatalf("fileark creation failed: %+v\n", err)
	}
	http.Handle("/receive", fileark)

	http.ListenAndServe(":8080", nil)
}
