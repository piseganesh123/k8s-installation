#! /bin/bash
#set -e

ADV_ADDR="172.16.16.100"
POD_NW_CIDR="192.168.0.0/16"
CP_ENDPOINT="kmaster"

deploy_k8s_cluster() {
  echo "=========== In k8s cluster deploy function =========="
  # === install Kubernetes
    
  sudo kubeadm config images pull >/dev/null 2>&1
  
#  sudo kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=10.244.0.0/16
  sudo kubeadm init --apiserver-advertise-address=${ADV_ADDR} --pod-network-cidr=${POD_NW_CIDR} \
  --control-plane-endpoint=${CP_ENDPOINT}

  #===wait while k8s comps are getting created
  #== to taint - run $kubectl taint nodes master-node key1=value1:NoSchedule

#  echo $(kubeadm token create --print-join-command) | sudo tee  /joincluster.sh
  sudo bash -c "echo $(kubeadm token create --print-join-command) >> /joincluster.sh"
  echo "==== deployed k8s cluster ===="
}

deploy_network() {
  echo "=========== in deploy flannel n/w function =========="
#  [[ -f /etc/kubernetes/admin.conf ]] && echo "==== config  file exists! ===="
#  export KUBECONFIG=/etc/kubernetes/admin.conf
  #kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml 2>&1
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml 2>&1
  echo "=== deployed calico network ===="
 }

configure_host(){
  echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  echo "==== Configured host ======="
}
hard_reset_k8s()
{
    sudo kubeadm reset -f
}

re_configure_user(){
  rm /home/student01/.kube/config
  sudo cp -i /etc/kubernetes/admin.conf /home/student01/.kube/config
  sudo chown student01:student01 /home/student01/.kube/config

  #source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> /home/student01/.bashrc
  echo "==== Reconfigured user student01"
}

enable_master_deploy()
{
  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
  echo "=== workload can be deployed on Master node now  ==="
}


main() {
  echo "=========== In reset function =========="
  # == install supporting tools like docker
  hard_reset_k8s
  configure_host
  deploy_k8s_cluster
  #== deploy flannel n/w
  re_configure_user
  deploy_network
  enable_master_deploy

}

main "$@"
