#! /bin/bash
#set -e
deploy_k8s_cluster() {
  echo "=========== In k8s cluster deploy function =========="
  # === install Kubernetes
    
  kubeadm config images pull >/dev/null 2>&1
  
  sudo kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=10.244.0.0/16
  #===wait while k8s comps are getting created
  #== to taint - run $kubectl taint nodes master-node key1=value1:NoSchedule
  kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null
  echo "==== deployed k8s cluster ===="
}

deploy_network() {
  echo "=========== in deploy flannel n/w function =========="
#  [[ -f /etc/kubernetes/admin.conf ]] && echo "==== config  file exists! ===="
  export KUBECONFIG=/etc/kubernetes/admin.conf
  #kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
  echo "=== deployed calico network ===="
 }

configure_host(){
  echo 1 > /proc/sys/net/ipv4/ip_forward
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  echo "==== Configured host ======="
}
hard_reset_k8s()
{
    kubeadm reset -f
}

re_configure_user(){
  rm /home/student01/.kube/config
  cp -i /etc/kubernetes/admin.conf /home/student01/.kube/config
  chown student01:student01 /home/student01/.kube/config

  #source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> /home/student01/.bashrc
  echo "==== Reconfigured user student01"
}

main() {
  echo "=========== In reset function =========="
  # == install supporting tools like docker
  hard_reset_k8s
  configure_host
  deploy_k8s_cluster
  #== deploy flannel n/w
  deploy_network
  re_configure_user
}

main "$@"