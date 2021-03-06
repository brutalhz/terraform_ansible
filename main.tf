terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.72.0"
}

provider "yandex" {
  service_account_key_file = "key.json" 
  cloud_id  = var.ya_cloud_id
  folder_id = var.ya_folder_id
  zone      = var.zone
}


# Configure the AWS Provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "eu-west-1"
}

data "aws_route53_zone" "main" {
  name = "devops.rebrain.srwx.net"
}

data "yandex_vpc_subnet" "default" {
  name = "default-${var.zone}"
}

data "yandex_compute_image" "base_image_ubuntu" {
  family = var.yc_image_family_ubuntu
}

## Create a new Yandex Cloud instance
resource "yandex_compute_instance" "ubuntu" {
  count       = length(var.devs)
  name        = "brutalhz-${element(var.devs, count.index)}"
  hostname    = "brutalhz-${element(var.devs, count.index)}"
  platform_id = var.platform_id
  labels = var.label
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.base_image_ubuntu.id
      size = var.disk_size
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.pub_key)}"
  }

}

resource "aws_route53_record" "devops_dns" {
  count   = length(var.devs)
  allow_overwrite = true
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "brutalhz-${element(var.devs, count.index)}"
  type    = "A"
  ttl     = "300"
  records = ["${yandex_compute_instance.ubuntu[count.index].network_interface.0.nat_ip_address}"]
}

data "template_file" "inventory" {
    template = "${file("${path.module}/inventory.tpl")}"

    vars = {
       ya_pub_ip = "${join("\n", yandex_compute_instance.ubuntu.*.network_interface.0.nat_ip_address)}"
       u_ssh = var.user_ssh
       key_path = var.private_key 


    }
}

resource "local_file" "ansible_inventory" {
  content = data.template_file.inventory.rendered
  filename = "${path.module}/inventory"

#  connection {
#    host = yandex_compute_instance.ubuntu.network_interface.0.nat_ip_address
#    type = "ssh"
#    user = var.user_ssh
#    agent = false
#    private_key = file(var.private_key)

#  }

#  provisioner "remote-exec" {
#    inline = [
#      "sudo sleep 30",
#    ]
#  }

#  provisioner "local-exec" {
#    command = "ansible-playbook -i inventory roles.yml"
#  }
}

