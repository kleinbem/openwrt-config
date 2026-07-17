# AI Context: Network Infrastructure & Brain

## Project Identity

**Repo Name:** `openwrt-config`
**Role:** The "Controller". Manages runtime state (Ansible) and Edge Services (NixOS).
**Methodology:** GitOps.
**Host OS:** FrankW OpenWrt (managed via Ansible).
**Guest OS:** NixOS inside LXC (managed via Flakes).

## Infrastructure Topology

| Hostname | Role | IP | HW | OS |
| :--- | :--- | :--- | :--- | :--- |
| `core-gateway` | Gateway / Edge | 10.0.0.1 (bench: 192.168.1.1) | BPI-R4 | OpenWrt (pinned official, openwrt-builder) |
| `ap-upstairs` | AP / LXC host | 10.0.0.2 (bench: 192.168.1.2) | BPI-R4 | OpenWrt (pinned official, openwrt-builder) |
| `brain` | Edge Intelligence | DHCP | LXC Container | NixOS (ARM64) |

## Tech Stack Rules

1. **Ansible:**
    - Use `raw` or `command` modules for `uci` interactions on OpenWrt where Python modules fail.
    - Python IS available on these routers (installed via `openwrt-builder`), so prefer standard modules (`copy`, `file`, `systemd`) where possible.
2. **NixOS (The Brain):**
    - Target Architecture: `aarch64-linux` (Cross-compiled from x86).
    - Host: ap-upstairs (NVMe storage at `/srv/lxc`).
    - **Podman:** Enabled inside NixOS (Nested Virtualization).

## Configuration Targets

1. **Network:** 10Gbps SFP+ Backhaul, VLANs (Home, Guest, IoT), 802.11r Roaming (DAWN).
2. **Storage:** Format and mount NVMe on `ap-upstairs` for LXC storage.
3. **Services (NixOS):** AdGuard Home, Tailscale, Home Assistant, Prometheus.

## Immediate Next Tasks for AI

1. **Ansible:** Fill in `ansible/group_vars/mediatek.yml` with correct network interface names (`eth1` vs `eth0`) for the BPI-R4.
2. **NixOS:** Verify `nixos-containers/flake.nix` imports the user's local `common.nix` correctly.
3. **Scripting:** Test `scripts/deploy-brain.sh` logic for creating the initial LXC config on the router.
