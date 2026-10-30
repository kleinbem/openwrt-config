# OpenWrt Configuration Management

This repository uses **Ansible** to configure OpenWrt routers and related services.

## Prerequisites

- **Python 3**: Must be installed on the target routers (handled by `openwrt-builder`).
- **SSH Key**: Your SSH key must be on the routers.

## Usage

We use `just` to standardize commands.

### List Hosts

```bash
just list-hosts
```

### Configure a Specific Router

```bash
just configure core-gateway
```

### Dry Run (Check Mode)

```bash
just check ap-upstairs
```

### Render Templates (no router needed)

Renders every role template for each host with dummy secrets into `.render/` and shellchecks the generated scripts. CI runs the same.

```bash
just render-check
```

## Directory Structure

- `ansible/`: Core Ansible files.
  - `inventory.ini`: Host definitions. **Generated** from `nix-config/inventory.nix` — do not hand-edit.
  - `site.yml`: Main playbook.
