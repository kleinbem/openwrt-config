# Justfile for OpenWrt Config

set dotenv-load

# Recipes run from the repo root, and ansible only looks for ./ansible.cfg in
# the CWD, so without this ansible/ansible.cfg (host key pinning included)
# is silently ignored.
export ANSIBLE_CONFIG := "ansible/ansible.cfg"

default:
    @just --list

# --- Aliases for Meta-Repo consistency ---

# Configure one host or group, or every router when no target is given
provision target="":
    @{{ if target == "" { "just deploy" } else { "just configure " + quote(target) } }}

verify:
    @just check all

# --- Core Commands ---

# Configure all routers
deploy:
    ansible-playbook -i ansible/inventory.ini ansible/site.yml

# Configure a specific host or group
configure target:
    @[ -n "$(printf '%s' {{quote(target)}} | tr -d '[:space:]')" ] || { echo 'error: empty target' >&2; exit 1; }
    ansible-playbook -i ansible/inventory.ini ansible/site.yml --limit {{quote(target)}}

# Dry-run configuration (check mode)
check target:
    @[ -n "$(printf '%s' {{quote(target)}} | tr -d '[:space:]')" ] || { echo 'error: empty target' >&2; exit 1; }
    ansible-playbook -i ansible/inventory.ini ansible/site.yml --limit {{quote(target)}} --check --diff

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
