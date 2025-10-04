# Security Hardening Guide

## Current Security Status

**Risk Level:** MODERATE (was HIGH)

### ✅ Implemented Protections

1. **CPU Security:** Spectre/Meltdown mitigations enabled
2. **SSH:** Key-based authentication only, root login disabled
3. **Audit Logging:** auditd tracking all privileged operations
4. **Kernel Hardening:** dmesg restricted, BPF JIT hardened, kernel image protected
5. **Secrets Management:** sops-nix infrastructure ready
6. **Auto-Commit Security:** Secret scanning, critical file protection, .claude/ exclusion
7. **Panic Protection:** 30s cooldown, automatic backup to branch
8. **Commit Signing:** SSH-based GPG signing enabled
9. **AppArmor:** Mandatory access control profiles active
10. **Sudo Restrictions:** Wheel group only, password required

### ⚠️ CRITICAL - Manual Actions Required

**IMMEDIATE (Do Now):**

```bash
# 1. Generate SSH key for commit signing and SSH access
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub SSH keys

# 2. Configure SSH allowed signers for commit verification
mkdir -p ~/.config/git
echo "$(git config user.email) $(cat ~/.ssh/id_ed25519.pub)" > ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers

# 3. Change user password (currently 'a')
passwd

# 4. Change sudo password (currently '7')
sudo passwd root

# 5. Update scripts that hardcode password '7'
# Check locations:
grep -r "echo 7" /home/a/nix-modules/modules/system/

# 6. Initialize sops-nix secrets
age-keygen -o ~/.config/sops/age/keys.txt
# Get public key and create .sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt

# 7. Audit git history for leaked secrets
git log -p | grep -iE '(password|secret|token|key).*=.*["\x27]'
```

**MEDIUM PRIORITY (This Week):**

```bash
# Enable full disk encryption (requires reinstall)
# - Backup data first
# - Reinstall with LUKS encryption
# - Restore configuration from GitHub

# Set BIOS/UEFI password
# - Reboot and enter BIOS (Del/F2)
# - Set supervisor and user passwords

# Audit GitHub token storage
gh auth status
# If token is plaintext, migrate to system keyring

# Install pre-commit hooks
nix-shell -p pre-commit --run 'pre-commit install'
```

## Secrets Management with sops-nix

### Setup

1. **Generate age key:**
```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # Get public key
```

2. **Create `.sops.yaml`:**
```yaml
keys:
  - &admin YOUR_AGE_PUBLIC_KEY_HERE
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *admin
```

3. **Create secrets file:**
```bash
mkdir -p /home/a/nix-modules/secrets
sops secrets/secrets.yaml
```

4. **Example secrets.yaml:**
```yaml
sudo_password: "YOUR_STRONG_PASSWORD_HERE"
github_token: "ghp_YOUR_TOKEN_HERE"
```

5. **Reference in configuration:**
```nix
sops.secrets.sudo-password = {
  neededForUsers = true;
};
```

## Auto-Commit Security

The auto-commit system now includes:
- ✅ Secret pattern detection (blocks password/token/key patterns)
- ✅ Critical file review gate (requires manual commit for auth files)
- ✅ .claude/DOCUMENTATION/ exclusion (manual review for session logs)
- ✅ GPG/SSH commit signing
- ✅ Detailed commit messages with security annotations

**Blocked patterns:**
- `password=`, `secret=`, `token=`, `api_key=`, `private_key=`
- Any file with path containing: secrets, password, token, key, auth

## Panic Command Safety

The `panic` command now includes:
- ⏱️ 30-second cooldown between executions
- 💾 Automatic backup to timestamped branch
- 🔢 Limited aliases (A! to AAAAA! only, down from 20)

**Recovery after panic:**
```bash
# Your changes are in a backup branch
git branch -a | grep panic-backup
git checkout panic-backup-TIMESTAMP
```

## Attack Surface Reduction

### Mitigated Threats

| Threat | Mitigation |
|--------|-----------|
| S1: Weak user password | MANUAL: Change with `passwd` |
| S2: Weak sudo password | MANUAL: Change with `sudo passwd root` |
| T1: Auto-commit without review | Secret scanning, critical file gates |
| T2: Hardcoded passwords in scripts | MANUAL: Update after password change |
| T7: Unsigned kernel modules | AppArmor confinement |
| R4: No commit signing | SSH-based GPG signing enabled |
| I1: Passwords in CLAUDE.md | Removed from documentation |
| I2: Secrets in Nix store | sops-nix infrastructure ready |
| D1: Panic command abuse | Rate limiting + backup |
| E1: Hardcoded sudo password | MANUAL: Remove after password change |

### Remaining Risks

**HIGH:**
- No full disk encryption (P4) - Requires reinstall
- Weak passwords still active (S1, S2, E1, E2) - CHANGE NOW
- Scripts contain hardcoded "7" (T2) - Update after password change

**MEDIUM:**
- GitHub token storage unclear (I10) - Audit with `gh auth status`
- MCP server sandboxing incomplete (T8) - Needs namespace isolation
- No multi-factor authentication (S5) - Consider PAM modules

## Security Monitoring

```bash
# Check audit logs
sudo ausearch -k privileged-commands
sudo ausearch -k secrets-access

# Monitor AppArmor
sudo aa-status

# Check failed authentication attempts
sudo journalctl -u sshd | grep Failed

# View firewall logs
sudo journalctl -u firewall | grep refused

# Check for security updates
nix flake update && nix flake check
```

## Next Steps

1. **CHANGE PASSWORDS** (blocking all other security work)
2. Generate SSH key and configure GitHub
3. Set up sops-nix with age key
4. Migrate hardcoded "7" in scripts to use sudo prompt
5. Enable full disk encryption (requires reinstall)
6. Add BIOS/UEFI password
7. Implement MCP server sandboxing

---

**Last Updated:** 2025-10-01
**Security Framework:** STRIDE Threat Model Applied
**Next Review:** After password changes
