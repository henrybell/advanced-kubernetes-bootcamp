// Package sdlog provides a minimal logger that can be used to write Info and Error
// messages to Stackdriver.
package sdlog

import (
	"context"
	"log"

	"cloud.google.com/go/logging"
)

// StackdriverLogger wraps a Google Cloud Logging logger.
type StackdriverLogger struct {
	logger *logging.Logger
}

// Logger creates and initializes a new StackdriverLogger for the specified project and log name.
func Logger(projectID, logname string) (*StackdriverLogger, error) {
	lc, err := logging.NewClient(context.Background(), projectID)
	if err != nil {
		return nil, err
	}

	lc.OnError = func(e error) {
		log.Printf("logging client error: %+v", e)
	}

	return &StackdriverLogger{logger: lc.Logger(logname)}, nil
}

// LogError writes a structured error message to the log associated with the logger.
func (l StackdriverLogger) LogError(msg string, err error) {
	l.logger.Log(logging.Entry{
		Payload: struct {
			Message string
			Error   string
		}{
			Message: msg,
			Error:   err.Error(),
		},
		Severity: logging.Error,
	})
}

// LogInfo write a structured info message to the log associated with the logger.
func (l StackdriverLogger) LogInfo(msg string) {
	l.logger.Log(logging.Entry{
		Payload: struct {
			Message string
		}{
			Message: msg,
		},
		Severity: logging.Info,
	})
}
