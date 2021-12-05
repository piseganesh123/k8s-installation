# kuber-inst-poc
POC to install kubernetes on Ubuntu servers for demo purpose

Pre-Requisite
1. Ensure compute engine api is enabled before creating infrastructure

Steps:
1. clone repository
2. Update variables (variables.tf file) according to your GCP account
3. run terraform init && terraform apply

To connect to Kubernetes cluster
  $mkdir -p $HOME/.kube
  $sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  $sudo chown $(id -u):$(id -g) $HOME/.kube/config

create service acccount having access to GCR and upload on new server

Create secret to pull image from gcr

$kubectl create secret docker-registry gcr-key-1 --docker-server=gcr.io --docker-username=_json_key --docker-password="$(cat /home/pgan432_gmail_com/gcr-user-level-epoch.json)" --docker-email=any@valid.email

apply changes from deploy.yaml

=========== Worked node connects with master using below commands ============
get secrete from kubeneretes 

# Join master node
kubeadm join 10.160.0.8:6443 --token <XXXXd1.5y2hj0yvvxzzXXXX> --discovery-token-ca-cert-hash <sha256:XXXX45908e73699e8fb8132f667adb7400a5bd151dd794947e3954e305XXXXXX>
  
