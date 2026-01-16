---
description: Configure an OpenWrt router using Ansible
---

To apply configuration changes to a router:

1. **Verify Connectivity**:

   ```bash
   just ping
   ```

2. **Apply Configuration**:

   ```bash
   just configure <host_name>
   # Example: just configure router-a
   ```

3. **Verify**:
   Check the output for "changed=..." to see what was updated.
