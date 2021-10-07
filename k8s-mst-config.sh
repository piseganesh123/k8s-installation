#! /bin/bash

echo " ======= Installing Docker ============"

#install docker

 sudo apt-get update
 sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo " ======= Installing Kubernetes ============"
# install Kubernetes

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-get install curl

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo swapoff -a

sudo apt-get install -y kubeadm kubelet kubectl

sudo apt-mark hold kubeadm kubelet kubectl

#sudo swapoff –a

sudo hostnamectl set-hostname master-node

#create kubeadmin config file
cat <<EOF > kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.22.0
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: cgroupfs
EOF

sudo kubeadm init --config kubeadm-config.yaml

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf /home/piseg432/.kube/config

sudo chown piseg432 /home/piseg432/.kube/config

sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml