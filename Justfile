# Justfile for OpenWrt Config

set dotenv-load

# Every recipe below invokes ansible-playbook/ansible from the repo root,
# but ansible.cfg lives in ansible/ — ansible's own config discovery only
# checks $ANSIBLE_CONFIG, then ./ansible.cfg relative to the CURRENT
# directory, so without this export ansible.cfg was never actually being
# loaded (confirmed via `ansible-config dump`: CONFIG_FILE() = None
# without it). That silently no-op'd every setting in it, including the
# host_key_checking this file now relies on actually taking effect.
export ANSIBLE_CONFIG := "ansible/ansible.cfg"

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

# Render every role template per host with dummy secrets (never touches a
# router) and shellcheck the generated uci scripts. CI runs the same.
# SC2016: a literal $ inside single quotes is the correctly quoted dummy secret.
render-check:
    rm -rf .render
    ansible-playbook -i ansible/inventory.ini ci/render-templates.yml -e @ci/dummy-secrets.yml
    shellcheck -s sh -e SC2016 .render/*/*.sh

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
