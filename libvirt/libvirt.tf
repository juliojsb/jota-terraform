resource "libvirt_volume" "k8s-qcow2" {
  #name = "srvk8s${count.index+1}.qcow2"
  name = "${var.hostname[count.index]}.qcow2"
  pool = "vms" # List storage pools using virsh pool-listgre
  source = "/aux/centos8stream.qcow2" # Download image and put it in local, so the deployment of VM is faster
  #size = 21474836480 # 20gb If "source" is used, you cannot set size. Resize image instead, ex.: qemu-img resize...
  # See https://github.com/dmacvicar/terraform-provider-libvirt/issues/357
  format = "qcow2"
  count = var.vmcount
}

resource "libvirt_cloudinit_disk" "commoninit" {
  pool = "vms"
  count = length(var.hostname)
  name = "${var.hostname[count.index]}-commoninit.iso"
  user_data = data.template_file.user_data[count.index].rendered
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
  count = length(var.hostname)
  vars = {
    hostname = element(var.hostname, count.index)
    ipaddr = element(var.ipaddr, count.index)
    prefix = var.prefix
    gateway = var.gateway
    dns = var.dns
  }
}

resource "libvirt_domain" "k8s" {
  name = "${var.hostname[count.index]}"
  qemu_agent = true
  memory = var.memoryMB
  vcpu   = var.cpu
  count = var.vmcount
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name = "default" # List networks with virsh net-list
    #bridge = "br0" # Name of your bridge network, use "brctl show"
    hostname = "${var.hostname[count.index]}"
    wait_for_lease = false
    mac = "AA:BB:CC:11:22:2${count.index+1}" # Fix MAC address to ensure static assignment in DHCP
  }

  disk {
    #volume_id = "${libvirt_volume.centos7-qcow2.id}"
    volume_id = element(libvirt_volume.k8s-qcow2.*.id, count.index+1)
    #volume_id = "${var.hostname[count.index]}"
  }
  
  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
#output "ip" {
#  value = "${libvirt_domain.centos7.network_interface.0.addresses.0}"
#}
