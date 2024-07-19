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
terraform apply -var-file='test.tfvars' -target=aws_eks_cluster.cluster
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

### logging in to aws
```
export AWS_PROFILE=pa1

~/.aws/config 
[profile pa1]
sso_session = s1
sso_account_id = 335687180128
sso_role_name = AdministratorAccess
region = ap-southeast-2
[sso-session s1]
sso_start_url = https://d-9767483a00.awsapps.com/start/#
sso_region = ap-southeast-2
sso_registration_scopes = sso:account:access

aws sso login
```




### kubernetes experiment 
```
aws eks update-kubeconfig --name my-cluster 

kubectl apply -f k8s/simple-deployment.yaml

kubectl apply -f k8s/

kubectl get pods -n kube-system

kubectl describe pod [id] -n kube-system

watch -n 1 -t kubectl get pods -n staging

kubectl get hpa php-apache -w -n staging

kubectl run -i -tt -n staging load-generator --pod-running-timeout=5m0s --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

### helm
```
helm list -n kube-system
```

## Packaging lambda
cd demo-lambda
zip -r ../iac/demo-lambda/myapp-lambda7.zip . -x "*DS_Store"