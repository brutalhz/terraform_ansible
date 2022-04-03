[webserver]
${ya_pub_ip}

[all:vars]
ansible_ssh_private_key_file = ${key_path}
ansible_ssh_user = ubuntu
