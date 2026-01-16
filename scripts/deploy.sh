#!/bin/bash
set -e

# Configuration
ROUTER_HOST="root@192.168.1.2"  # Router B (Attic)
CONTAINER_NAME="brain"
FLAKE_DIR="./nixos-containers"

echo "🧠 [1/3] Cross-Compiling NixOS (ARM64)..."
nix build "$FLAKE_DIR#nixosConfigurations.$CONTAINER_NAME.config.system.build.tarball" \
    --out-link result-brain

echo "📦 [2/3] Uploading to Router B..."
IMAGE_PATH=$(readlink -f result-brain/tarball/*.tar.xz)
scp "$IMAGE_PATH" "$ROUTER_HOST:/srv/lxc/nixos-brain.tar.xz"

echo "🚀 [3/3] Re-Deploying Container..."
ssh "$ROUTER_HOST" "
    # 1. Ensure Config Exists (First Run)
    if [ ! -f /etc/lxc/$CONTAINER_NAME.conf ]; then
        echo 'Creating LXC Config...'
        cat > /etc/lxc/$CONTAINER_NAME.conf <<EOF
lxc.arch = aarch64
lxc.include = /usr/share/lxc/config/common.conf
lxc.include = /usr/share/lxc/config/nesting.conf
lxc.uts.name = $CONTAINER_NAME
lxc.rootfs.path = dir:/srv/lxc/$CONTAINER_NAME/rootfs
lxc.net.0.type = veth
lxc.net.0.link = br-lan
lxc.net.0.flags = up
lxc.net.0.name = eth0
lxc.init.cmd = /sbin/init
EOF
    fi

    # 2. Stop & Refresh
    lxc-stop -n $CONTAINER_NAME || true
    mkdir -p /srv/lxc/$CONTAINER_NAME/rootfs
    
    echo 'Extracting RootFS...'
    tar -xf /srv/lxc/nixos-brain.tar.xz -C /srv/lxc/$CONTAINER_NAME/rootfs
    
    rm /srv/lxc/nixos-brain.tar.xz
    lxc-start -n $CONTAINER_NAME
"
echo "✅ Done! NixOS Brain is running."