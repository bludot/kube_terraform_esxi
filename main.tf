terraform {
  required_version = ">= 0.13"
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
      #
      # For more information, see the provider source documentation:
      # https://github.com/josenk/terraform-provider-esxi
      # https://registry.terraform.io/providers/josenk/esxi
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_host
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = var.esxi_user
  esxi_password = var.esxi_password
}

data "template_file" "master_userdata" {
  template = file("userdata.yaml")
  vars = {
    username     = var.username
    ssh_key_pub  = var.ssh_key_pub
    ssh_key_priv = var.ssh_key_priv
    hostname     = "${var.guest_name}-master"
  }
}

data "template_file" "master_metadata" {
  template = file("metadata.yaml")
  vars = {
    gateway_ip = var.gateway_ip
    static_ip  = var.master_ip
  }
}

data "template_file" "node_userdata" {
  for_each = toset(var.node_ips)
  template = file("userdata.yaml")
  vars = {
    username     = var.username
    ssh_key_pub  = var.ssh_key_pub
    ssh_key_priv = var.ssh_key_priv
    hostname     = "${var.guest_name}-${index(var.node_ips, each.value)}"
  }
}

data "template_file" "node_metadata" {
  for_each = toset(var.node_ips)
  template = file("metadata.yaml")
  vars = {
    gateway_ip = var.gateway_ip
    static_ip  = each.value
  }
}

resource "esxi_virtual_disk" "master_disk" {
  virtual_disk_disk_store = "datastore2"
  virtual_disk_dir        = var.guest_name
  virtual_disk_size       = var.master_disk_size
}


resource "esxi_virtual_disk" "node_disks" {
  for_each                = toset(var.node_ips)
  virtual_disk_disk_store = "datastore2"
  virtual_disk_dir        = "${var.guest_name}-${each.key}"
  virtual_disk_size       = var.node_disk_size
}

resource "esxi_guest" "master" {
  guest_name = var.guest_name
  disk_store = "datastore2"

  numvcpus       = 4
  memsize        = 16384
  boot_disk_size = var.master_boot_disk_size
  ovf_source     = "focal-server-cloudimg-amd64.ova"

  network_interfaces {
    virtual_network = "kube"
  }
  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.master_disk.id
    slot            = "0:1"
  }
  guestinfo = {
    "metadata"          = base64gzip("${data.template_file.master_metadata.rendered}")
    "metadata.encoding" = "gzip+base64"
    userdata            = base64gzip("${data.template_file.master_userdata.rendered}")
    "userdata.encoding" = "gzip+base64"
  }
  provisioner "remote-exec" {
    connection {
      host        = var.master_ip
      user        = "ubuntu"
      private_key = file("files/id_rsa")
    }

    inline = ["echo 'connected!'"]
  }
  provisioner "local-exec" {
    command = <<EOT
            k3sup install --ip ${var.master_ip} --user ubuntu --ssh-key ~/.ssh/github --k3s-extra-args '--write-kubeconfig-mode 644 --disable servicelb --disable traefik --kubelet-arg eviction-hard=memory.available<300Mi --kubelet-arg=image-gc-high-threshold=85 --kubelet-arg=image-gc-low-threshold=80' --k3s-version v1.26.0+k3s2
        EOT
  }
}

resource "esxi_guest" "node" {
  for_each   = toset(var.node_ips)
  guest_name = "${var.guest_name}-${each.key}"
  disk_store = "datastore2"

  numvcpus       = 4
  memsize        = 16384
  boot_disk_size = var.node_boot_disk_size
  ovf_source     = "focal-server-cloudimg-amd64.ova"

  network_interfaces {
    virtual_network = "kube"
  }
  guestinfo = {
    "metadata"          = base64gzip("${data.template_file.node_metadata[each.key].rendered}")
    "metadata.encoding" = "gzip+base64"
    userdata            = base64gzip("${data.template_file.node_userdata[each.key].rendered}")
    "userdata.encoding" = "gzip+base64"
  }
  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.node_disks[each.key].id
    slot            = "0:1"
  }
  provisioner "remote-exec" {
    connection {
      host        = each.value
      user        = "ubuntu"
      private_key = file("files/id_rsa")
    }

    inline = ["echo 'connected!'"]
  }
  provisioner "local-exec" {
    command = <<EOT
            k3sup join --ip ${each.value} --server-ip ${var.master_ip} --user ${var.username} --ssh-key ~/.ssh/github --k3s-version v1.26.0+k3s2
        EOT
  }
  depends_on = [
    esxi_guest.master
  ]
}


output "cloud-init" {
  value = data.template_file.node_userdata
}
