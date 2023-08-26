variable "vmcount" { default = 3 }

variable "hostname" {
  description = "The names of the VMs to create"
  type = list(string)
  #default = ["k8smaster1","k8smaster2","k8smaster3","k8sworker1","k8sworker2","k8sworker3"]
  default = ["k8snode1","k8snode2","k8snode3","k8snode4","k8snode5","k8snode6"]
}

variable "memoryMB" { default = 1024 * 4 }
variable "cpu" { default = 2 }
variable "ipaddr" {
  description = "IP addresses for VMs"
  type = list(string)
  default = ["192.168.50.101","192.168.50.102","192.168.50.103","192.168.50.104","192.168.50.105"]
}

variable "gateway" { default = "192.168.50.1"}
variable "prefix" { default = 24 }
variable "dns" { default = "192.168.50.1" }

