# kuber-inst-poc
POC to install kubernetes on Ubuntu servers for demo purpose

Pre-Requisite
1. Ensure compute engine api is enabled before creating infrastructure

Steps:
1. clone repository
2. Update variables (variables.tf file) according to your GCP account
3. run terraform init && terraform apply

Create secret to pull image from gcr

$kubectl create secret docker-registry test-image –docker-server=https://gcr.io –docker-username=_json_key –docker-email=gcr-user@level-epoch-329208.iam.gserviceaccount.com –docker-password=”$(cat /home/pgan432_gmail_com/gcr-user-level-epoch.json)”

test (not checked)- kubectl create secret docker-registry my-secret --from-file=.dockerconfigjson=/home/pgan432_gmail_com/gcr-user-level-epoch.json
