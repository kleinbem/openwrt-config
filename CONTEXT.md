# OpenWrt Config Context

This repository manages the **runtime configuration** of OpenWrt routers using Ansible. It assumes the routers are already flashed with an image from `openwrt-builder` that includes Python 3.

## Core Philosophy

- **Inventory-Driven**: Hosts are defined in `ansible/inventory.ini`.
- **Idempontency**: Re-running playbooks should be safe and enforce the desired state.
- **Declarative**: We define *what* the router should look like (packages, files, UCI settings).

## Key Files

- `ansible/inventory.ini`: Defines groups (routers, brains) and host variables.
- `ansible/site.yml`: The main playbook.
- `Justfile`: Automation commands (e.g., `just configure`).

## AI Workflow

To change configuration:

1. **Analyze**: Check `ansible/site.yml` and `inventory.ini`.
2. **Modify**: Edit the playbook or variables to add/remove settings.
3. **Deploy**: Run `just configure <host>` (or generally `just deploy` for all).
