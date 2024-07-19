aws eks update-kubeconfig --region ap-southeast-2 --name my-cluster

kubectl get pods -A    


helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install my-webserver nginx-stable/nginx-ingress
helm uninstall my-webserver


kubectl get ingresses
kubectl get services


helm install happy-panda bitnami/wordpress
kubectl get svc --namespace default -w happy-panda-wordpress

helm uninstall happy-panda


terraform destroy -var-file='test.tfvars'