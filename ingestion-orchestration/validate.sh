gcloud auth application-default login   # one-time, if not already done
cd infra/envs/dev
cp terraform.tfvars.example terraform.tfvars   # fill in your project ID
terraform init
terraform plan
