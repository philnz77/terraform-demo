https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html

1)
aws cloudformation create-stack \
--region ap-southeast-2 \
--stack-name my-eks-vpc-stack \
--template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml

2)
instead of directly running the following 2 commands, I'll do that in terraform

aws iam create-role \
--role-name myAmazonEKSClusterRole \
--assume-role-policy-document file://"eks-cluster-role-trust-policy.json"

aws iam attach-role-policy \
--policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
--role-name myAmazonEKSClusterRole

I put both of these in
cluster-policy.tf

3)
Step 3 Open the Amazon EKS console at
... manual

3.1) Cluster service role set to myAmazonEKSClusterRole

3.2) Left default setting at true
Bootstrap cluster administrator access
Choose whether the IAM principal creating the cluster has Kubernetes cluster administrator access.

Bootstrap cluster administrator access can only be set at cluster creation. If you set the admin bootstrap parameter to True, then EKS will automatically create a cluster admin access entry on your behalf. This parameter can be set independent of cluster authentication mode.

3.3) Cluster authentication mode
Left default setting on EKS API and ConfigMap

3.4) Secrets encryption  
Turn on envelope encryption of Kubernetes secrets using KMS

left this off for the tutorial, but for sure we'll be setting this one!

3.5) Vpc
leave the defaults of both the private and public subnets

3.5.1) Leaving Security groups blank???
There are 2 security groups in the list????
The reason there are 2 is because one of them comes by default whenever you create a vpc (I assume).
Maybe there is a way to turn that off in terraform, I'm not sure what's going on, I've seen it before though.
The other one was created in the stack.
It says 

Security group name

my-eks-vpc-stack-ControlPlaneSecurityGroup-3yA1FvBJNEo6
Security group ID

sg-0e1dfcc6463c027ce
Description

Cluster communication with worker nodes

So if we don't use it here, then where do we use it!!!


Choose the security groups to apply to the EKS-managed Elastic Network Interfaces that are created in your control plane subnets. To create a new security group, go to the corresponding page in the

Security groups control communications within the Amazon EKS cluster including between the managed Kubernetes control plane and compute resources in your AWS account such as worker nodes and Fargate pods.

The Cluster Security Group is a unified security group that is used to control communications between the Kubernetes control plane and compute resources on the cluster. The cluster security group is applied by default to the Kubernetes control plane managed by Amazon EKS as well as any managed compute resources created through the Amazon EKS API.

Additional cluster security groups control communications from the Kubernetes control plane to compute resources in your account.
Worker node security groups are security groups applied to unmanaged worker nodes that control communications from worker nodes to the Kubernetes control plane.

https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

outcome:
first thing I'm going to try is setting this to the security group
we created, maybe it would have defaulted to that in the past.

4) Leave observability off for now, but I'm sure it's going to be wanted

5) Add ons, defaults are 4/5
====On====
CoreDNS  Info
Enable service discovery within your cluster.
Category
networking
kube-proxy  Info
Enable service networking within your cluster.
Category
networking
Amazon VPC CNI  Info
Enable pod networking within your cluster.
Category
networking
Amazon EKS Pod Identity Agent  Info
Install EKS Pod Identity Agent to use EKS Pod Identity to grant AWS IAM permissions to pods through Kubernetes service accounts.
Category
security
====Off====
Amazon GuardDuty EKS Runtime Monitoring  Info
Install EKS Runtime Monitoring add-on within your cluster. Ensure to enable 

each add on has a version




6) Cluster is created, lets have a look... 
```
aws eks update-kubeconfig --name my-cluster
kubectl config current-context
kubectl config use-context arn:aws:eks:ap-southeast-2:335687180128:cluster/my-cluster
kubectl get pods -A
kubectl get svc
```
No resources found, no nodes anywhere.
I wonder why in the 113 tutorial when I did a
resource "aws_eks_cluster" ,and I didn't have any
add ons, I ended up with some coredns nodes that wouldn't start.

However here, I didn't get those nodes, seems like if anything it should
have been the other way around. 

Actually they did eventually pop up, and everything now
looks the same as when I used resource "aws_eks_cluster"

In the docs, the bootstrap_self_managed_addons is doing it,
it defaults to true, so must be doing the same thing as those 
check boxes, I wonder what happens if you change the default 
on the console?
I'm guessing it always has that as false in the console
and instead lists out the add ons with their versions.
So probably makes sense to turn that default off to 
be more specific.

Eventually use
"aws_eks_addon"

7) https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html#eks-launch-workers
Managed nodes – Linux
Instead of 1 a b& c, use 
node-policy.tf


8) Should I use a launch template
   Using EC2 launch templates
   Amazon EKS supports using Amazon EC2 launch templates to create node groups. Launch templates allow you to customize the configuration of the EC2 instances created as part of your node group. You may optionally specify a custom AMI ID in your launch template.

When using a launch template do not specify instanceTypes, diskSize or remoteAccess in the node group configuration. These properties must be configured within the launch template itself.
Instance role and subnets can only be specified in node group configuration parameters.
Instance market options (EC2 Spot) are not supported in launch templates used with managed node groups.
When you update your node group to a newer version of your launch template, all your nodes will be recycled to match the new configuration of the launch template version specified.
If you specify custom security groups in the launch template, Amazon EKS will not add the cluster security group, and you must ensure the ingress and egress rules of your security groups enable communication with your cluster’s endpoint.
Amazon EC2 user data in launch templates used with managed node groups must be in the MIME multi-part archive format, because your user data is merged with Amazon EKS user data required for nodes to join the cluster.
When specifying a custom AMI in a launch template, Amazon EKS will not merge any user data. You are responsible for supplying the required bootstrap commands for nodes to join the cluster.

https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html
https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-templates.html

9) All subnets

10) All looks good but cant deploy wordpress
helm install happy-panda bitnami/wordpress

helm install my-webserver nginx-stable/nginx-ingress
this is working on http but not https

11) Add on Amazon EFS CSI Driver  
aws eks describe-cluster --name my-cluster --query "cluster.identity.oidc.issuer" --output text
based on the output of the above, run eks-ebs-csi-policy.tf





    
