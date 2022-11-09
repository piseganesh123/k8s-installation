#! /bin/bash
#set -e

install_k8s_sup_tools() {
  echo "=========== In k8s supporting tool inst function =========="
  # install Kubernetes
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
 
  sudo apt update

  sudo apt-get install -y kubeadm=1.25.1-00 kubelet=1.25.1-00 kubectl=1.25.1-00
#  sudo apt-get install -y kubeadm=1.25.3-00 kubelet=1.25.3-00 kubectl=1.25.3-00
  sudo apt-mark hold kubeadm kubelet kubectl
  #sudo hostnamectl set-hostname master-node

  #====================


  #sudo kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=10.244.0.0/16
  #wait while k8s comps are getting created
  #sleep 60
  #export KUBECONFIG=/etc/kubernetes/admin.conf
  #kubectl taint nodes --all node-role.kubernetes.io/master-
}
 
install_supp_tools() {
  echo "=========== Support Tools installation function =========="
  sudo apt-get update
  sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      lsb-release \ 
      gnupg \
      software-properties-common

 #configure OS parameters for container runtime      
#  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

  #disable firewall on host server
  systemctl disable --now ufw >/dev/null 2>&1
  
  sudo modprobe overlay
  sudo modprobe br_netfilter
  sudo sysctl --system


  #configure  container runtime 
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  sudo apt-get update

  sudo apt-get install -y containerd.io=1.6.9-1

  containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
  sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

#  echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' >> /etc/docker/daemon.json
   sudo systemctl restart containerd
   sudo systemctl enable containerd
}

#deploy_network() {
#  echo "=========== in deploy n/w function =========="
##  [[ -f /etc/kubernetes/admin.conf ]] && echo "==== config  file exists! ===="
 # export KUBECONFIG=/etc/kubernetes/admin.conf
#  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# }

#deploy_busybox() {
#  echo "=========== in deploy busybox function =========="
# kubectl apply -f busybox.yaml
#}
main() {
  echo "=========== In main support tool install function =========="
  #install supporting tools like docker
  install_supp_tools
  # create files like manifest
  #create_files
  install_k8s_sup_tools
  #deploy flannel n/w
  #deploy_network
  #deploy_busybox
}

main "$@"