#! /bin/bash
#set -e

install_utilites() {
  echo "=========== Supporting utility installation function =========="
  sudo apt-get update
  sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      lsb-release \ 
      software-properties-common
  #?  gnupg2 - is it required?

  # =========== configure  container runtime 
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y containerd.io=1.6.9-1

  containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
  sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

  sudo systemctl restart containerd
  sudo systemctl enable containerd
}

install_k8s_supp_tools() {
  echo "=========== In k8s supporting tool inst function =========="
  # ===  install Kubernetes
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  sudo apt-get update
  sudo apt-get install -y kubeadm=1.25.1-00 kubelet=1.25.1-00 kubectl=1.25.1-00
  sudo apt-mark hold kubeadm kubelet kubectl
}


configure_host()
{
# === configure_hosts_file
cat >>/etc/hosts<<EOF
172.16.16.100   kmaster     kmaster.local
172.16.16.101   kworker1    kworker1
172.16.16.101   kworker1    kworker1.local
EOF

#=== configure_firewall
  echo "==== Stop and Disable firewall =="
  systemctl disable --now ufw >/dev/null 2>&1

# === disable swap
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# ===== configure OS modules
  sudo modprobe overlay
  sudo modprobe br_netfilter
  sudo sysctl --system

# ===== configure container runtime and kubernetes
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

#===== enable ip forwarding
  echo 1 > /proc/sys/net/ipv4/ip_forward

}


main() {
  echo "=========== In main support tool install function =========="
  # == install supporting tools like docker
  install_utilites
  install_k8s_supp_tools
  configure_host
}

main "$@"