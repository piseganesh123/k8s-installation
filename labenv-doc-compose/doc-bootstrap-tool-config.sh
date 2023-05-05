#! /bin/bash
#set -e

install_docker_supp_tools() {
  echo "=========== Supporting utility installation function =========="
  sudo apt-get update -y >/dev/null 2>&1
  sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      lsb-release >/dev/null 2>&1
  #\ 
  #?    software-properties-common
  #?  gnupg2 - is it required?

  # =========== install  container runtime repo 
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
 
  sudo apt-get update -y >/dev/null 2>&1
  
  #=== configure container runtime
  sudo apt-get install -y containerd.io=1.6.9-1 >/dev/null 2>&1
  sudo apt-get install -y docker-ce=5:23.0.4-1~ubuntu.22.04~jammy docker-compose=1.29.2-1 >/dev/null 2>&1

  containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
  sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

  sudo systemctl restart containerd >/dev/null 2>&1
  sudo systemctl enable containerd >/dev/null 2>&1
  echo "=== Installed supporting tools === "
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
  sudo sysctl --system >/dev/null 2>&1

# ===== configure container runtime and kubernetes
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

#===== enable ip forwarding
  echo 1 > /proc/sys/net/ipv4/ip_forward

echo "==== Configured host === "
}


main() {
  echo "=========== In main support tool install function =========="
  # == install supporting tools like docker
  install_docker_supp_tools
  configure_host
  echo "=== done with k8s installation ==="
}

main "$@"