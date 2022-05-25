[ubuntu]
${ya_pub_ip}

[centos]
${ya_pub_ip2}

[all:vars]
ansible_ssh_private_key_file = ${key_path}

[ubuntu:vars]
ansible_ssh_user = ${u_ssh}

[centos:vars]
ansible_ssh_user = ${u_ssh2}
