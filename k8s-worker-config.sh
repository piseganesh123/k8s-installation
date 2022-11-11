install_supp_tools() {
  #install Kubectl
  echo " ======= Installing tools on worker ============"
    sudo apt install -qq -y sshpass >/dev/null 2>&1

}

join_k8s_cluster() {
  # Join node to Kubernetes Cluster
  echo "=========== joining k8s cluster =========="
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.example.com:/joincluster.sh /joincluster.sh >/dev/null 2>&1
  bash /joincluster.sh
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.example.com:/etc/kubernetes/admin.conf  /etc/kubernetes/admin.conf >/dev/null 2>&1
  echo "configure below environment variable to use kubectl from master server"
  echo "export KUBECONFIG=/etc/kubernetes/admin.conf"
  # for worker node validation purpose
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl get nodes
}

condigure-worker(){
 sudo hostnamectl set-hostname worker1
}

main() {
  echo "=========== In main function =========="
  install_supp_tools
  condigure-worker
  join_k8s_cluster
}

main "$@"