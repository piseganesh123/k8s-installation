install_supp_tools() {
  #=== install Kubectl
  echo " ======= Installing tools on worker ============"
  sudo apt install -qq -y sshpass >/dev/null 2>&1
  echo "=== installed supporting tools on worker ==="
}

join_k8s_cluster() {
  # Join node to Kubernetes Cluster
  echo "=========== joining k8s cluster =========="
  sudo sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster:/joincluster.sh /joincluster.sh
  sudo sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster:/etc/kubernetes/admin.conf  /etc/kubernetes/admin.conf
  bash /joincluster.sh
  echo "configure below environment variable to use kubectl from master server"
  echo "export KUBECONFIG=/etc/kubernetes/admin.conf"
  # for worker node validation purpose
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl get nodes -o wide
}

disable_master_deploy()
{
  kubectl taint nodes kmaster node-role.kubernetes.io/control-plane:NoSchedule
  echo "=== workload can be deployed on Master node now  ==="
}
configure_worker(){
  #sudo hostnamectl set-hostname worker1
  echo "no tool to configure on worker node as of now"
}

configure_etc_hosts(){
  # remove ubuntu-bionic entry from hosts file
  sudo sed -e '/^.*ubuntu2204.*/d' -i /etc/hosts
  echo "=== Configured host file on worker ==="
}

configure_user(){
  adduser student01 --disabled-password -q
  usermod -aG sudo student01

  echo "student01 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/student01

  mkdir -p /home/student01/.kube
  cp -i /etc/kubernetes/admin.conf /home/student01/.kube/config
  chown student01:student01 /home/student01/.kube/config

  #source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> /home/student01/.bashrc
  echo "=== configured student user on worker node"
}

main() {
  echo "=========== In worker config main function =========="
  install_supp_tools
  configure_worker
  configure_etc_hosts
  join_k8s_cluster
  disable_master_deploy
  configure_user
  echo "=== done with k8s worker node configuration === "
}

main "$@"