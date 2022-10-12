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
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
  sudo apt-get install curl
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  sudo swapoff -a
  sudo apt-get install -y kubeadm=1.22.2-00 kubelet=1.22.2-00 kubectl=1.22.2-00
  sudo apt-mark hold kubeadm kubelet kubectl
  sudo hostnamectl set-hostname master-node

  sudo sysctl --system
  #====================

  echo 1 > /proc/sys/net/ipv4/ip_forward
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16
  #wait while k8s comps are getting created
  sleep 60
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

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  
  sudo apt-get update
  sudo apt-get install -y docker-ce=5:20.10.18~3-0~ubuntu-focal docker-ce-cli=5:20.10.18~3-0~ubuntu-focal containerd.io=1.4.11-1

  echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' >> /etc/docker/daemon.json
  systemctl restart docker
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
  install_supp_tools
  # create files like manifest
  create_files
  install_k8s
  #deploy flannel n/w
  deploy_network
  deploy_busybox
}

main "$@"

#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

#set user specific config

#cd $admin_user_dir && mkdir -p .kube

#yes | sudo cp -i /etc/kubernetes/admin.conf $admin_user_dir/.kube/config

#sudo chown $admin_user $admin_user_dir/.kube/config

#sudo su $admin_user -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
#cat <<EOF > .bash_aliases
#alias lesssyslog='sudo less -g /var/log/syslog | grep startup-s' 
#EOF

#references
#kubeadm token create --print-join-command
#kubectl get pods --all-namespaces
#journalctl -xeu kubelet
#alias lesssyslog="sudo less -g /var/log/syslog | grep startup-s" 
#kubectl create secret docker-registry gcr-json-key --docker-server=eu.gcr.io --docker-username=_json_key --docker-password="$(cat ~/gcr_user.json)" --docker-email=piseganesh123@gmail.com
#kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'
#
#sudo cp -i /busybox.yaml /home/piseg432/

#sudo su $admin_user -c "kubectl apply -f "$admin_user_dir"/busybox.yaml"
#sleep 60
# configure k8s to use master node
 
  #create kubeadmin config file
  #cat <<EOF > kubeadm-config.yaml
  #kind: ClusterConfiguration
  #apiVersion: kubeadm.k8s.io/v1beta3
  #kubernetesVersion: v1.22.0
  #---
  #kind: KubeletConfiguration
  #apiVersion: kubelet.config.k8s.io/v1beta1
  #cgroupDriver: cgroupfs
  #EOF
  #sudo sysctl net.bridge.bridge-nf-call-iptables=1

  # ==== enable iptable entries
  #sudo cp -i /kubeadm-config.yaml /home/piseg432/
#sudo kubeadm init --config kubeadm-config.yaml --pod-network-cidr=10.244.0.0/16
  #sudo apt-get install -y kubeadm kubelet kubectl
  #sudo swapoff –a
  #sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  #   ls $admin_user_dir
#  [[ -d $admin_user_dir ]] && echo "==== os-user is created ! ===="
#admin_user=pgan432
#admin_user_dir=/home/pgan432/
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
