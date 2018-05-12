// Package cmd provides utility functions common across cmd binaries.
package cmd

import (
	"log"
	"net/http"
	"os"
)

// Liveness responds to HTTP requests with a 200. It is the
// simplest possible K8S liveness probe handler.
func Liveness(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

// MustGetenv retrieves the value of an environment variable or logs a fatal error.
func MustGetenv(name string) string {
	val := os.Getenv(name)
	if len(val) == 0 {
		log.Fatalf("%s must be set", name)
	}
	return val
}

// Readiness responds to HTTP requests with a 200. It is the
// simplest possible K8S readiness probe handler.
func Readiness(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}
