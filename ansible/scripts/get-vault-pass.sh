#!/usr/bin/env bash
# Fetch the Ansible Vault password from the central nix-secrets repo using SOPS.
# Requires 'sops' to be installed and YubiKey to be present.

SECRETS_FILE="/home/martin/Develop/github.com/kleinbem/openwrt-secrets/secrets.yaml"

if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: Secrets file not found at $SECRETS_FILE" >&2
    exit 1
fi

# Extract the key 'ansible_vault_pass' from the YAML
# Note: This assumes the key in secrets.yaml is named 'ansible_vault_pass'
sops -d --extract '["ansible_vault_pass"]' "$SECRETS_FILE"
