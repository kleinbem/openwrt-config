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
just configure router-a
```

### Dry Run (Check Mode)

```bash
just check router-b
```

## Directory Structure

- `ansible/`: Core Ansible files.
  - `inventory.ini`: Host definitions.
  - `site.yml`: Main playbook.
