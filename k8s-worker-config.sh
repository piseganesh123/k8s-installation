install_supp_tools() {
  #install Kubectl
  echo " ======= Installing Kubectl ============"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  #wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
  echo " ======= Installing docker ============"
  #curl -LO https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz
  #install docker
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
  sudo apt-get install -y docker-ce=5:20.10.9~3-0~ubuntu-bionic docker-ce-cli=5:20.10.9~3-0~ubuntu-bionic containerd.io=1.4.11-1

  echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' >> /etc/docker/daemon.json
  systemctl restart docker
  echo " ======= Installed Docker ============"
  sudo hostnamectl set-hostname worker01
  echo ======== Installing kube tools ============
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
  sudo apt-get install curl
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  sudo swapoff -a
  sudo apt-get install -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00
  sudo apt-mark hold kubeadm kubelet kubectl
  sudo hostnamectl set-hostname worker-node
}

join_k8s_cluster() {
  echo "Join node to Kubernetes Cluster"
  apt install -qq -y sshpass >/dev/null 2>&1
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no 172.16.16.100:/joincluster.sh /joincluster.sh 2>/dev/null
  bash /joincluster.sh
  # >/dev/null 2>&1
}

main() {
  echo "=========== In main function =========="
  #install supporting tools like docker
  #install_supp_tools
  join_k8s_cluster
}

main "$@"