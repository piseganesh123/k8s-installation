#! /bin/bash

gcloud container clusters get-credentials istio-poc-cluster-tf --zone asia-south1-c

terraform init && terraform apply -auto-approve