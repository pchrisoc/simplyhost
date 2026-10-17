---
title: Proxmox
nav_order: 1
parent: Intro
---

![Proxmox](https://www.proxmox.com/images/proxmox/logos/mediakit-proxmox-server-solutions-logos-light.svg)

# Proxmox VE
## *The One Hypervisor To Rule Them All*

## What is a hypervisor?
- A [hypervisor](https://en.wikipedia.org/wiki/Hypervisor) (in the case of [Proxmox VE](https://www.proxmox.com/en/)) is a server virtualization management solution. It is the software that enables the creation and continuous running of [virtual machines](https://en.wikipedia.org/wiki/Virtual_machine) and [LXCs](https://en.wikipedia.org/wiki/LXC). ![Hypervisor](https://imgs.search.brave.com/3Z2n__kPnvcgD91HeJdAwJfIw1x8TCdevW1LQbqymJU/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly93d3cu/bnV0YW5peC5jb20v/ZXNfbXgvaW5mby9o/eXBlcnZpc29yL19q/Y3JfY29udGVudC9y/b290L2NvbnRhaW5l/ci9jb21wb25lbnRD/b250YWluZXIvY29u/dGFpbmVyX2ZsZXhf/Ym94XzIxMjU0Mzc0/NDEvZmxleGNvbF8y/L2ltYWdlLmNvcmVp/bWcucG5nLzE2NDk3/NzkyMzU1NTcvaW1n/LWh5cGVydmlzb3Iu/cG5n)

## Why do I need a hypervisor?
- While a hypervisor is overkill for certain hardware with lower specs, a lot of homelabbers (including myself) often regret not going straight into Proxmox. The containerization and potential to run more then one operating system is going to prove to help in the long run.
- Proxmox also comes with a web UI that allows for a visual interaction with your VMs and LXCs.

## Why Proxmox VE? I really want VMWare ESX!
- Proxmox VE is open-source, and enterprise features are free for personal deployments. It is well-maintained, well-documented, and has as great [backup system](https://pbs.proxmox.com/wiki/Main_Page)!
- No, you don't want VMWare ESX. Sorry, not sorry Broadcom.
