# Justfile for OpenWrt Config

set dotenv-load

default:
    @just --list

# --- Aliases for Meta-Repo consistency ---

provision *args:
    @just deploy {{args}}

verify:
    @just check all

# --- Core Commands ---

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

# --- Control: live device isolation at the gateway edge ---

# Quarantine a device (drop all its traffic) by MAC. e.g. just quarantine AA:BB:.. kids-tablet
quarantine mac name="":
    ansible-playbook -i ansible/inventory.ini ansible/quarantine.yml -e mac={{mac}} -e state=on -e name={{name}}

# Release a quarantined device by MAC.
release mac:
    ansible-playbook -i ansible/inventory.ini ansible/quarantine.yml -e mac={{mac}} -e state=off

# Show currently quarantined devices.
quarantine-list:
    ansible-playbook -i ansible/inventory.ini ansible/quarantine.yml -e mac=00:00:00:00:00:00 -e state=list

# --- Diagnostics: packet capture (open the pulled .pcap in Wireshark) ---

# Capture packets on a VLAN (or 'wan') and pull the pcap. e.g. just capture iot 60
capture vlan seconds="30":
    @mkdir -p captures
    ansible-playbook -i ansible/inventory.ini ansible/capture.yml -e vlan={{vlan}} -e seconds={{seconds}}
