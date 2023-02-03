# kuber-inst-poc
Install kubernetes on Ubuntu servers for demo purpose

Validated on:
OS - Ubuntu 22.04 LTS
Kubernetes version - 1.25.0
containerd version - 1.6.9-1
helm 3.7
vagrant - v2.3.4
Virtualbox - 6.1.4
git - 2.39.0

Pre-Requisite
1. Ensure compute engine api is enabled before creating infrastructure

Steps:
1. clone repository
2. Generate key with permission to create compute instances on GCP your account
2. Update variables (variables.tf file) according to your GCP account
3. Create public and private key, update public key in "k8s-mst-slv-vm.tf" file, refer - https://phoenixnap.com/kb/generate-setup-ssh-key-ubuntu
4. run terraform init && terraform apply

To connect to Kubernetes cluster

  "$mkdir -p $HOME/.kube"
  
  "$sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config"
  
  "$sudo chown $(id -u):$(id -g) $HOME/.kube/config"

create service acccount having access to GCR and upload on new server

Create secret to pull image from gcr

$kubectl create secret docker-registry gcr-key-1 --docker-server=gcr.io --docker-username=_json_key --docker-password="$(cat /home/pgan432_gmail_com/gcr-user-level-epoch.json)" --docker-email=any@valid.email

apply changes from deploy.yaml

============ Open firewall ports on master =====

$sudo ufw allow 6443/tcp
$sudo ufw allow 2379:2380/tcp
$sudo ufw allow 10250:10260/tcp

#On worker node
$sudo ufw allow 30000:32767/tcp
$sudo ufw allow 10250/tcp

=========== Worked node connects with master using below commands ============
get secrete from kubeneretes 
$kubeadm token create --print-join-command

# Join master node
$kubeadm join 10.160.0.8:6443 --token <XXXXd1.5y2hj0yvvxzzXXXX> --discovery-token-ca-cert-hash <sha256:XXXX45908e73699e8fb8132f667adb7400a5bd151dd794947e3954e305XXXXXX>
  

FOLLOW BELOW STEPS - In case you are using vagrant
#change user to root
#clone repository
$cd kuber-inst-poc
$sh ./k8s-mst-config.sh

high level steps
Install supporting tools and utilities

install & configure container runtime

install kubectl, kubeadm, kubelet

configure host server

create cluster using kubeadm
