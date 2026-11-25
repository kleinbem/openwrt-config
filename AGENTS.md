# OpenWrt Config Context

This repository manages the **runtime configuration** of OpenWrt routers using Ansible. It assumes the routers are already flashed with an image from `openwrt-builder` that includes Python 3.

## Core Philosophy

- **Inventory-Driven**: Hosts are defined in `ansible/inventory.ini` — but that file is **generated** from `nix-config/inventory.nix` (see its own header) and must never be hand-edited; regenerate it via `just maintenance::sync-inventory` (run from `nix-config` or a conductor) after changing the source of truth.
- **Idempontency**: Re-running playbooks should be safe and enforce the desired state.
- **Declarative**: We define *what* the router should look like (packages, files, UCI settings).

## Key Files

- `ansible/inventory.ini`: Defines groups (routers, gateways, access_points, lxc_hosts) and host variables. **Generated — do not hand-edit**; source of truth is `nix-config/inventory.nix`.
- `ansible/site.yml`: The main playbook.
- `Justfile`: Automation commands (e.g., `just configure`).

## AI Workflow

To change configuration:

1. **Analyze**: Check `ansible/site.yml` and `inventory.ini`.
2. **Modify**: Edit the playbook or `group_vars`/`host_vars` to add/remove settings — never `inventory.ini` itself (regenerate it from `nix-config/inventory.nix` instead).
3. **Deploy**: Run `just configure <host>` (or generally `just deploy` for all).
