#!/usr/bin/env bash

PROJECT=$(gcloud info --format='value(config.project)')
gsutil cp frontend.yml gs://$PROJECT-spinnaker/manifests/frontend.yml