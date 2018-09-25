#!/usr/bin/env bash

PROJECT=$(gcloud info --format='value(config.project)')
gsutil cp backend.yml gs://$PROJECT-spinnaker/manifests/backend.yml