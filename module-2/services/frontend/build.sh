#!/usr/bin/env bash

PROJECT=$(gcloud info --format='value(config.project)')
gcloud builds submit -q --tag gcr.io/$PROJECT/frontend .
