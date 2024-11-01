#!/bin/bash

echo 'Enabling necessary APIs'

project=$(grep -o '\"project_id\": \"[^\"]*' terraform.tfvars.json | grep -o '[^\"]*$')

gcloud services enable "compute.googleapis.com" --project=$project

export APIS="googleapis.com www.googleapis.com iam.googleapis.com iamcredentials.googleapis.com storage.googleapis.com compute.googleapis.com servicemanagement.googleapis.com servicecontrol.googleapis.com cloudapis.googleapis.com cloudresourcemanager.googleapis.com"
for i in $APIS
do
  echo "199.36.153.10 $i" >> /etc/hosts
done