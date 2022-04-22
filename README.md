# Ansible Role: Nginx

Installs Nginx on Debian/Ubuntu servers.

This role installs and configured Nginx from the Nginx apt repository. You can change [virtualhosts].conf file inside `/etc/nginx/conf.d/` describing the location and options to use for your particular website.

## Role Variables

Available variables are listed below (see `vars/main.yml`):


Creates the required number of virtual hosts.

`server_name' - Hostname

`name` - the name of the file with the virtual host settings [name].conf
`listen' - port number
`index' - list of index files
