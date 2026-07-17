# AI Context: Network Infrastructure & Brain

## Project Identity

**Repo Name:** `openwrt-config`
**Role:** The "Controller". Manages runtime state (Ansible) and Edge Services (NixOS).
**Methodology:** GitOps.
**Host OS:** FrankW OpenWrt (managed via Ansible).
**Guest OS:** none active — LXC capability dormant on ap-upstairs.

## Infrastructure Topology

| Hostname | Role | IP | HW | OS |
| :--- | :--- | :--- | :--- | :--- |
| `core-gateway` | Gateway / Edge | 10.0.0.1 (bench: 192.168.1.1) | BPI-R4 | OpenWrt (pinned official, openwrt-builder) |
| `ap-upstairs` | AP / LXC host | 10.0.0.2 (bench: 192.168.1.2) | BPI-R4 | OpenWrt (pinned official, openwrt-builder) |

## Tech Stack Rules

1. **Ansible:**
    - Use `raw` or `command` modules for `uci` interactions on OpenWrt where Python modules fail.
    - Python IS available on these routers (installed via `openwrt-builder`), so prefer standard modules (`copy`, `file`, `systemd`) where possible.
2. **LXC (dormant capability):** ap-upstairs keeps NVMe at `/srv/lxc` +
    LXC config, but the NixOS "brain" containers were dropped 2026-07-18
    (never deployed; all tenants live on the NixOS fleet).

## Configuration Targets

1. **Network:** 10Gbps SFP+ Backhaul, VLANs (Home, Guest, IoT), 802.11r Roaming (DAWN).
2. **Storage:** Format and mount NVMe on `ap-upstairs` for LXC storage.

## Immediate Next Tasks for AI

See `../../docs/NETWORK_PLAN.md` — bench-provision → swap runbook.
