#! /bin/bash
#set -e
configure_host(){
  echo 1 > /proc/sys/net/ipv4/ip_forward
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}
hard_reset_k8s()
{
    kubeadm reset -f
}

join_k8s_cluster() {
  # Join node to Kubernetes Cluster
  echo "=========== joining k8s cluster =========="
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster:/joincluster.sh /joincluster.sh
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster:/etc/kubernetes/admin.conf  /etc/kubernetes/admin.conf
  bash /joincluster.sh
  echo "configure below environment variable to use kubectl from master server"
  echo "export KUBECONFIG=/etc/kubernetes/admin.conf"
  # for worker node validation purpose
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl get nodes -o wide
}
main() {
  echo "=========== In reset function =========="
  # == install supporting tools like docker
  hard_reset_k8s
  configure_host
  join_k8s_cluster
}

main "$@"