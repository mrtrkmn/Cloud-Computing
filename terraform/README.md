# How to run 

## Prerequisites for GCP

```bash 

$ gcloud projects create <project-name>
$ gcloud config set project <project-name>
$ gcloud iam service-accounts create <service-account-name> --description="service account for terraform" --display-name="terraform_service_account"

$ gcloud iam service-accounts keys create ~/google-key.json --iam-account  <service-account-name>@<project-id>.iam.gserviceaccount.com
## sometimes the last command does not work, if it does not work, just create the key and download it from management ui.
## it is also required to provide permissions for the user that you have created for service account which is can be done from IAM management on GCP
```

## Running Terraform Commands

This is quite straightforward to accomplish. 

```bash 

$ terraform init
$ terraform apply

# in case you want to destroy 
$ terraform destroy

```

Compute admin
Compute network admin
Kubernetes Engine cluster admin
Service account admin