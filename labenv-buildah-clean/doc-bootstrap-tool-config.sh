#! /bin/bash
#set -e

install_buildah_supp_tools() {
  echo "=========== Supporting utility installation function =========="
  sudo apt-get update -y >/dev/null 2>&1
  sudo apt-get -y install podman
  sudo apt-get -y install buildah
  sudo apt-get -y install runc

  #=== configure container runtime
  echo "=== updated supporting tools === "
}

configure_host()
{
# === configure_hosts_file
cat >>/etc/hosts<<EOF
172.16.16.100   vmaster     kmaster.local
EOF
sed -e '/^.*ubuntu2204.*/d' -i /etc/hosts

#=== configure_firewall
#  echo "==== Stop and Disable firewall =="
#  systemctl disable --now ufw >/dev/null 2>&1

# ===== configure OS modules
#  sudo modprobe overlay
#  sudo modprobe br_netfilter
#  sudo sysctl --system >/dev/null 2>&1

#===== enable ip forwarding
  echo 1 > /proc/sys/net/ipv4/ip_forward

echo "==== Configured host === "
}

#configure_user()
#{
#  echo "=== configured vagrant user ===="
#}

main() {
  echo "=========== In main support tool install function =========="
  # == install supporting tools like docker
  install_buildah_supp_tools
  configure_host
#  configure_user
  echo "=== done with buildah, podman installation ==="
}

main "$@"