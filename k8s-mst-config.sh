#! /bin/bash
#set -e

admin_user=pgan432
admin_user_dir=/home/pgan432/

install_k8s() {
  echo "=========== In k8s function =========="
  echo " ======= Installing Kubernetes ============"
  # install Kubernetes
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
  sudo apt-get install curl
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  sudo swapoff -a
  #sudo apt-get install -y kubeadm kubelet kubectl
  sudo apt-get install -y kubeadm=1.22.2-00 kubelet=1.22.2-00 kubectl=1.22.2-00
  sudo apt-mark hold kubeadm kubelet kubectl
  #sudo swapoff –a
  sudo hostnamectl set-hostname master-node
}
 
install_supp_tools() {
  echo "=========== Tools installation =========="
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
  #sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo apt-get install -y docker-ce=5:20.10.9~3-0~ubuntu-bionic docker-ce-cli=5:20.10.9~3-0~ubuntu-bionic containerd.io=1.4.11-1

  echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' >> /etc/docker/daemon.json
  systemctl restart docker
}
 
main() {
  echo "=========== In main function =========="
  install_supp_tools
  install_k8s
 
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

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
#====================

#sudo cp -i /kubeadm-config.yaml /home/piseg432/
echo 1 > /proc/sys/net/ipv4/ip_forward

#sudo kubeadm init --config kubeadm-config.yaml --pod-network-cidr=10.244.0.0/16
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
#sleep 60
# configure k8s to use master node
kubectl taint nodes --all node-role.kubernetes.io/master-

[[ -f /etc/kubernetes/admin.conf ]] && echo "==== config  file exists! ===="

#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config
#export KUBECONFIG=/etc/kubernetes/admin.conf

#set user specific config

#cd $admin_user_dir && mkdir -p .kube

#yes | sudo cp -i /etc/kubernetes/admin.conf $admin_user_dir/.kube/config

#sudo chown $admin_user $admin_user_dir/.kube/config

#sudo su $admin_user -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

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

#sudo cp -i /busybox.yaml /home/piseg432/

#sudo su $admin_user -c "kubectl apply -f "$admin_user_dir"/busybox.yaml"
kubectl apply -f "$admin_user_dir"/busybox.yaml

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
}

main "$@"