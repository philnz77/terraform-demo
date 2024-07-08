# terraform-demo

## bootstrapping remote state

initially the backend is local as there is no bucket
```
cd iac/remote-state
terraform init
terraform apply -var-file='test.tfvars'
```

now you have a bucket set up, we can migrate from local backend to s3 backend

- open iac/remote-state/remote-state.tf
- uncomment backend "s3" section

```
terraform init -backend-config=test.s3.tfbackend
terraform apply -var-file='test.tfvars'
```

now the state is stored in s3, you can delete the terraform.tfstate file (it's git ignored anyway)

### destroying the bootstrapped remote state

Because the bucket is in use, we first need to transfer the backend back to local.

- open iac/remote-state/remote-state.tf
- comment out the backend "s3" section

```
terraform init -migrate-state   
terraform apply -var-file='test.tfvars'  
terraform destroy -var-file='test.tfvars'  
```

## Packaging lambda
cd demo-lambda
zip -r ../iac/demo-lambda/myapp-lambda7.zip . -x "*DS_Store"