# Enhancing Lynis with Custom USB Storage Auditing and Removable Media Risk Detection

A Linux security-auditing project that adds a custom Lynis test for USB storage module state and removable-media detection.

> **Scope note:** This repository contains shell scripts for Lynis, not Nmap NSE scripts. Lynis custom tests use shell syntax and are sourced by Lynis. The files here are alternative `tests_custom` variants: install one variant at a time.

## Project enhancements

### Enhancement 1 — USB storage module auditing

The first variant checks:

1. Whether `usb_storage` module information is available through `modinfo`.
2. Whether `usb_storage` is currently loaded, using `lsmod`.
3. Whether a blacklist rule for `usb-storage` or `usb_storage` exists in `/etc/modprobe.d/`.

### Enhancement 2 — Removable-media detection and risk classification

The second variant includes Enhancement 1 and also uses `lsblk` to detect removable block devices. It checks both `RM=1` and `TYPE=disk` so optical devices with `TYPE=rom` are not classified as removable disks.

Project risk rules:

| Condition | Project risk |
|---|---|
| USB storage module is blacklisted | LOW |
| Module is not loaded and no removable disk is detected | LOW |
| Module is loaded and no removable disk is detected | MEDIUM |
| Module is loaded and a removable disk is detected | HIGH |
| Removable disk is detected but module is not reported loaded and no blacklist exists | MEDIUM; investigate the inconsistent state |

These are project-defined categories, not universal Lynis severity levels. A blacklist rule is a configuration indicator; it should not be treated as proof that all USB storage access is impossible.

## Repository layout

```text
.
├── README.md
├── LICENSE
├── install.sh
└── scripts/
    ├── enhancement1/
    │   └── tests_custom
    └── enhancement2/
        └── tests_custom
```

## Requirements

- Kali Linux or another Linux distribution supported by Lynis.
- Lynis installed; the default Kali package path used by the installer is `/usr/share/lynis/include`.
- `modinfo`, `lsmod`, `grep`, `awk`, and `lsblk` available in `PATH`.
- Root privileges for installation and a full privileged audit.

## Install a variant

Extract this archive and change into the project directory.

Install **Enhancement 1** (module checks only):

```bash
sudo ./install.sh 1
```

Install **Enhancement 2** (module checks, removable-media detection, and risk result):

```bash
sudo ./install.sh 2
```

The installer backs up an existing `tests_custom` before replacing it and installs the selected file as `root:root` with mode `0640`, matching Lynis custom-test permission requirements. The variants are alternatives because Lynis loads the single file named `tests_custom`; choose one at a time.

## Run the custom test

```bash
sudo lynis audit system --tests-from-group "usb storage" --quick --skip-plugins
```

Look for the section titled `Custom tests - USB Storage Module` (Enhancement 1) or `Custom tests - Removable Media` (Enhancement 2).

For a normal full audit, the custom test is also sourced as part of the Lynis custom-tests phase. A full audit may take longer because it runs other tests and plugins.

## Verify the installed file

```bash
ls -l /usr/share/lynis/include/tests_custom
sudo grep -n 'CUST-0040' /usr/share/lynis/include/tests_custom
```

## Uninstall / restore

The installer creates a backup beside `tests_custom` if one already existed. To restore a backup, choose the backup you want and copy it back, for example:

```bash
sudo cp -p /usr/share/lynis/include/tests_custom.backup.YYYYMMDDHHMMSS \
  /usr/share/lynis/include/tests_custom
sudo chown root:root /usr/share/lynis/include/tests_custom
sudo chmod 0640 /usr/share/lynis/include/tests_custom
```

Replace the timestamp with the actual backup filename. Do not remove a blacklist or unload a kernel module on a production machine solely to reproduce a demo; perform state changes only in a controlled lab VM.

## Example output

An output observed in the development VM was:

```text
[+] Custom tests - Removable Media
------------------------------------
  - Checking usb-storage kernel module                        [ NOT FOUND ]
  - Checking usb-storage module state                         [ NOT LOADED ]
  - Checking usb-storage blacklist                            [ BLACKLISTED ]
  - Checking for removable storage                            [ NOT DETECTED ]
  - Removable-media security risk                             [ LOW ]
```

Actual statuses vary according to kernel packages, configuration files, loaded modules, and connected devices.

## GitHub upload

Create a new GitHub repository, extract this archive, and upload/commit the contents. Do not upload machine-specific Lynis logs, report data, registration numbers, or unrelated personal information.
