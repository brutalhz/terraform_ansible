[ubuntu]
${ya_pub_ip}

[all:vars]
ansible_ssh_private_key_file = ${key_path}

[ubuntu:vars]
ansible_ssh_user = ${u_ssh}
