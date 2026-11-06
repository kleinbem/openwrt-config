---
priority: critical
role: InfrastructureController
---

# SYSTEM HANDOVER: Network & Brain

## Project Identity

**Repo Name:** `openwrt-config`
**Methodology:** GitOps (Ansible + NixOS)

## CRITICAL RULES (DO NOT VIOLATE)

1. **Topology:** - `core-gateway` (10.0.0.1; bench 192.168.1.1): Gateway (pinned official OpenWrt via openwrt-builder)
    - `ap-upstairs` (10.0.0.2; bench 192.168.1.2): AP + Host for LXC
    - `brain` (DHCP): NixOS LXC Container (ARM64)
2. **Ansible:** Use `raw` module for OpenWrt UCI commands if standard modules fail.
3. **NixOS:** Target `aarch64-linux`. Do not try to build x86 containers for the router.

## Next Task

Verify that `ansible/inventory.ini` correctly groups the `mediatek` hosts.
