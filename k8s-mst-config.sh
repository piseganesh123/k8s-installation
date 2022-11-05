#! /bin/bash
#set -e

create_files() {
echo "=========== in files creation function =========="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
cat <<EOF > busybox.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox1
  labels:
    app: busybox1
spec:
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
  restartPolicy: Always
EOF
} 

install_k8s() {
  echo "=========== In k8s inst function =========="
  # install Kubernetes
 # sudo apt-get install -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00
  sudo hostnamectl set-hostname master-node

  #sudo sysctl --system
  #====================

  echo 1 > /proc/sys/net/ipv4/ip_forward
  sudo kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=10.244.0.0/16
  #wait while k8s comps are getting created
  #sleep 60
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl taint nodes --all node-role.kubernetes.io/master-
}
 
install_supp_tools() {
  echo "=========== Tools installation function =========="
  sudo apt-get update
  sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

# containerd , docker installation
#  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  
  sudo apt-get update
#  sudo apt-get install -y docker-ce=5:20.10.18~3-0~ubuntu-focal docker-ce-cli=5:20.10.18~3-0~ubuntu-focal containerd.io=1.4.11-1

#  echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' >> /etc/docker/daemon.json
#  systemctl restart docker
}

deploy_network() {
  echo "=========== in deploy n/w function =========="
  [[ -f /etc/kubernetes/admin.conf ]] && echo "==== config  file exists! ===="
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
 }

deploy_busybox() {
  echo "=========== in deploy busybox function =========="
 kubectl apply -f busybox.yaml
}
main() {
  echo "=========== In main function =========="
  #install supporting tools like docker
  #install_supp_tools
  # create files like manifest
  create_files
  install_k8s
  #deploy flannel n/w
  deploy_network
  deploy_busybox
}

main "$@"