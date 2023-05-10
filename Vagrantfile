# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

VAGRANT_BOX         = "generic/ubuntu2204"
VAGRANT_BOX_VERSION = "4.0.2"
CPUS_MASTER_NODE    = 2
CPUS_WORKER_NODE    = 2
MEMORY_MASTER_NODE  = 2048
MEMORY_WORKER_NODE  = 2048
WORKER_NODES_COUNT  = 0
IP_NW = "172.16.16."
MASTER_IP_START = 1
NODE_IP_START = 2

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "k8s-bootstrap-tool-config.sh"
  

  # Kubernetes Master Server
  config.vm.define "kmaster" do |node|
  
    node.vm.box               = VAGRANT_BOX
    node.vm.box_check_update  = false
    node.vm.box_version       = VAGRANT_BOX_VERSION
    node.vm.hostname          = "kmaster"

    node.vm.network "private_network", ip: "172.16.16.100"
#    node.vm.network "public_network"
  
    node.vm.provider :virtualbox do |v|
      v.name    = "kmaster"
      v.memory  = MEMORY_MASTER_NODE
      v.cpus    = CPUS_MASTER_NODE
    end
  
    node.vm.provider :libvirt do |v|
      v.memory  = MEMORY_MASTER_NODE
      v.nested  = true
      v.cpus    = CPUS_MASTER_NODE
    end
  
    node.vm.provision "shell", path: "k8s-mst-config.sh" do |s|
      s.args = ["enp0s8"]
    end
  
  end

  # Kubernetes Worker Nodes
  (1..WORKER_NODES_COUNT).each do |i|

    config.vm.define "kworker#{i}" do |node|

      node.vm.box               = VAGRANT_BOX
      node.vm.box_check_update  = false
      node.vm.box_version       = VAGRANT_BOX_VERSION
      node.vm.hostname          = "kworker#{i}"

      node.vm.network "private_network", ip: "172.16.16.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "kworker#{i}"
        v.memory  = MEMORY_WORKER_NODE
        v.cpus    = CPUS_WORKER_NODE
      end

      node.vm.provider :libvirt do |v|
        v.memory  = MEMORY_WORKER_NODE
        v.nested  = true
        v.cpus    = CPUS_WORKER_NODE
      end

      node.vm.provision "shell", path: "k8s-worker-config.sh" do |s|
        s.args = ["enp0s8"]
      end

    end

  end

end