#! /bin/bash
#set -e
configure_host(){
  echo 1 > /proc/sys/net/ipv4/ip_forward
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  echo "=== Reconfigured host"
}
hard_reset_k8s()
{
    sudo kubeadm reset -f
}

join_k8s_cluster() {
  # Join node to Kubernetes Cluster
  echo "=========== joining k8s cluster =========="
#  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster:/joincluster.sh /joincluster.sh
  sudo sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster:/etc/kubernetes/admin.conf  /etc/kubernetes/admin.conf
  sudo export KUBECONFIG=/etc/kubernetes/admin.conf
  sudo kubeadm token create --print-join-command > ./joincluster.sh 2>/dev/null
  sudo bash ./joincluster.sh
  # for worker node validation purpose
  echo "configure below environment variable to use kubectl from master server"
  echo "export KUBECONFIG=/etc/kubernetes/admin.conf"

  kubectl get nodes -o wide
  echo "==== Joined cluster ======="
}

re_configure_user(){
  sudo cp /etc/kubernetes/admin.conf /home/student01/.kube/config
  sudo chown student01:student01 /home/student01/.kube/config

  #source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> /home/student01/.bashrc
  echo "=== reconfigured student user ===="
}

main() {
  echo "=========== In reset function =========="
  # == install supporting tools like docker
  hard_reset_k8s
  configure_host 
  join_k8s_cluster
  re_configure_user
}

main "$@"