#! /bin/bash
#set -e

#ADV_ADDR="172.16.16.100"
POD_NW_CIDR="192.168.0.0/16"
#CP_ENDPOINT="kmaster"

create_files() {
echo "=========== in manifest files creation function =========="

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
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

deploy_k8s_cluster() {
  echo "=========== In k8s cluster deploy function =========="
  # === install Kubernetes
#  sudo hostnamectl set-hostname master-node

  #====================

  kubeadm config images pull >/dev/null 2>&1
  
  sudo kubeadm init --pod-network-cidr=192.168.0.0/16
#  sudo kubeadm init --apiserver-advertise-address=${ADV_ADDR} --pod-network-cidr=${POD_NW_CIDR} \
#  --control-plane-endpoint=${CP_ENDPOINT}

  #wait while k8s comps are getting created
  export KUBECONFIG=/etc/kubernetes/admin.conf
  #== to taint - run kubectl taint nodes master-node key1=value1:NoSchedule
  
  kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null
  echo "=== deployed cluster on master node ===="
}
 
install_supp_tools() {
  echo "=========== Tools installation function =========="
  # ======= configuring autocompletion
  sudo apt-get install openssl, jq, bash-completion -y
  echo "=== Installed supporting tools on master node ==="
}

deploy_network() {
  echo "=========== deploy Calico n/w =========="
  [[ -f /etc/kubernetes/admin.conf ]] && echo "==== config  file exists! ===="
  export KUBECONFIG=/etc/kubernetes/admin.conf
  # configure calico - CRD and plugin
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
  # OR flannel - ====# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  echo "=== deployed nw ==="
 }

enable_master_deploy()
{
  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
  echo "=== workload can be deployed on Master node now  ==="
}

deploy_busybox() {
  echo "=========== in deploy busybox function =========="
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f busybox.yaml
}

enable_root_ssh_access(){
  echo "=== Enable ssh password authentication"
  sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
  systemctl reload sshd >/dev/null 2>&1

  echo "Set root password"
  echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
  echo "export TERM=xterm" >> /etc/bash.bashrc
  echo "=== enabled root access ==="
}

configure_host(){
  # remove ubuntu-bionic entry from hosts file
  sed -e '/^.*ubuntu2204.*/d' -i /etc/hosts
  echo "=== Configured host ===="
}

configure_user(){
  adduser student01 --disabled-password -q
  usermod -aG sudo student01

  echo "student01 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/student01

  mkdir -p /home/student01/.kube
  cp -i /etc/kubernetes/admin.conf /home/student01/.kube/config
  chown -R student01:student01 /home/student01/.kube

  #source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> /home/student01/.bashrc
  echo "=== configured student01 user"
  #add alias
  alias kn='kubectl config set-context --current --namespace ' >> /home/student01/.bash_aliases
}

main() {
  echo "=========== In main function =========="
  # == install supporting tools like docker
  install_supp_tools
  #=== create files like manifest
  create_files
  configure_host
  deploy_k8s_cluster
  #== deploy flannel n/w
  deploy_network
  enable_master_deploy
  enable_root_ssh_access
  configure_user
  # == deploy_busybox
  echo "=== done with master node configuration"
}

main "$@"