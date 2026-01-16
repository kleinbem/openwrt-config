# Justfile for OpenWrt Config

set dotenv-load

default:
    @just --list

# Configure all routers
deploy:
    ansible-playbook -i ansible/inventory.ini ansible/site.yml

# Configure a specific host or group
configure target:
    ansible-playbook -i ansible/inventory.ini ansible/site.yml --limit {{target}}

# Dry-run configuration (check mode)
check target:
    ansible-playbook -i ansible/inventory.ini ansible/site.yml --limit {{target}} --check --diff

# Ping all hosts to verify connectivity
ping:
    ansible -i ansible/inventory.ini all -m ping

# List available hosts from inventory
list-hosts:
    @ansible-inventory -i ansible/inventory.ini --list --yaml | grep "ansible_host" -B 1
