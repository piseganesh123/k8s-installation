#! /bin/bash
#set -e

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
  sudo hostnamectl set-hostname master-node

  #====================

  echo 1 > /proc/sys/net/ipv4/ip_forward
  
  kubeadm config images pull >/dev/null 2>&1
  
  sudo kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=10.244.0.0/16
  #wait while k8s comps are getting created
  sleep 60
  export KUBECONFIG=/etc/kubernetes/admin.conf
  #== to taint - run kubectl taint nodes master-node key1=value1:NoSchedule
  
  kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null
 
}
 
install_supp_tools() {
  echo "=========== Tools installation function =========="
  #===== install helm
  snap install --channel=3.7 helm --classic
}

deploy_network() {
  echo "=========== in deploy n/w function =========="
  [[ -f /etc/kubernetes/admin.conf ]] && echo "==== config  file exists! ===="
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
 }

deploy_busybox() {
  echo "=========== in deploy busybox function =========="
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f busybox.yaml
}

enable_root_ssh_access(){
  echo "Enable ssh password authentication"
  sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
  systemctl reload sshd

  echo "Set root password"
  echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
  echo "export TERM=xterm" >> /etc/bash.bashrc
}

main() {
  echo "=========== In main function =========="
  # == install supporting tools like docker
  install_supp_tools
  #=== create files like manifest
  create_files
  deploy_k8s_cluster
  #== deploy flannel n/w
  deploy_network
  enable_root_ssh_access
  # == deploy_busybox
}

main "$@"