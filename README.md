# SimplyHost

**Build your own Proxmox home server from a guided hardware setup and an application checklist.**

SimplyHost is a planned open-source web configurator and local deployment tool. Users enter their hardware, choose virtual machines and operating systems, select self-hosted applications, and receive a complete deployment plan with networking, storage, remote access, backups, and documentation.

Optional **Budget Mode** shows how every selection affects available RAM, CPU capacity, and storage. A modular catalog tracks official upstream releases so new installations and existing deployments can stay current.

> **Status:** Planning and development roadmap. Features below are intended goals, not claims of existing functionality.

## Project goals

- [ ] Make Proxmox self-hosting approachable for beginners.
- [ ] Support reproducible configurations for experienced homelab users.
- [ ] Keep hardware, data, configuration, and secrets under the user's control.
- [ ] Generate a reviewable plan before making changes.
- [ ] Provide ready-to-deploy VM configurations built from verified official images.
- [ ] Provide generated commands and configuration files for manual deployment.
- [ ] Make resource budgeting optional in the interface.
- [ ] Make applications, providers, policies, and templates modular.
- [ ] Continuously track upstream releases instead of maintaining fixed version lists.
- [ ] Include maintenance, backup, and restoration in every supported deployment.

## Intended workflow

1. Start a new project or import an existing configuration.
2. Enter hardware or import an optional local discovery report.
3. Choose whether to display Budget Mode.
4. Choose VM count, operating systems, and deployment style.
5. Select applications and review recommendations.
6. Configure storage, Tailscale/Pangolin, exposure, and backups.
7. Review the architecture and exact deployment plan.
8. Export the bundle and apply it locally.
9. Verify services and backups, then manage updates.

## Roadmap checklist

### 1. Project foundation

- [ ] Choose the final project name.
- [ ] Choose a license strategy for the website, CLI, schemas, and catalog.
- [ ] Create the source repository and development environment.
- [ ] Document the architecture and module boundaries.
- [ ] Add a contribution guide and catalog authoring guide.
- [ ] Add a security policy and vulnerability reporting process.
- [ ] Establish catalog review, ownership, and maintenance rules.
- [ ] Record major architecture decisions.
- [ ] Create beginner-friendly documentation and sample configurations.

### 2. Hardware setup and discovery

- [ ] Prompt for CPU model, architecture, physical cores, and logical threads.
- [ ] Prompt for installed RAM.
- [ ] Prompt for boot disks, data disks, storage pools, and available capacity.
- [ ] Prompt for existing VM/container allocations and storage usage.
- [ ] Prompt for network interfaces and existing bridges.
- [ ] Prompt for GPU, integrated graphics, and required USB devices.
- [ ] Prompt for household size and expected workloads.
- [ ] Collect optional UPS, idle power, and electricity-price information.
- [ ] Support new-server, existing-server, and exploration workflows.
- [ ] Offer hardware presets that remain editable.
- [ ] Build optional read-only local hardware/Proxmox discovery.
- [ ] Import discovery results without sending administrative credentials to the website.
- [ ] Handle unknown hardware values explicitly.
- [ ] Generate a customized Proxmox installation guide.
- [ ] Include BIOS/UEFI, installer, management IP, repositories, updates, storage, and device preparation steps.

### 3. RAM, CPU, and storage budgets

- [ ] Calculate allocatable RAM after host reserve, existing allocations, and headroom.
- [ ] Calculate CPU capacity with an explicit workload and overcommit policy.
- [ ] Distinguish physical cores, logical threads, assigned vCPUs, and estimated CPU load.
- [ ] Calculate usable storage separately for each storage pool.
- [ ] Account for redundancy, used capacity, and free-space reserves.
- [ ] Separate logical/thin allocations from physical storage consumption.
- [ ] Account for VM operating-system and container-runtime overhead.
- [ ] Account for gateway, proxy, monitoring, and shared infrastructure overhead.
- [ ] Count shared dependencies and shared storage allocations once.
- [ ] Separate boot, configuration, database, bulk data, cache, and backup storage.
- [ ] Estimate data growth over a configurable planning horizon.
- [ ] Include snapshot and backup capacity where applicable.
- [ ] Allow users to edit reserves, allocation profiles, and headroom.
- [ ] Recalculate the complete plan when applications, workloads, or allocations change.
- [ ] Explain budget calculations and estimate uncertainty.

### 4. Optional Budget Mode

- [ ] Provide a persistent Budget Mode on/off toggle.
- [ ] Show live RAM, CPU, and per-pool storage usage when enabled.
- [ ] Show remaining capacity and over-budget findings.
- [ ] Preview each application's incremental resource cost before selection.
- [ ] Show minimum, recommended, and performance allocation choices.
- [ ] Suggest alternatives that fit the remaining budget.
- [ ] Explain the tradeoffs of lower allocations or lighter applications.
- [ ] Allow over-budget exploration while reporting deployment constraints.
- [ ] Hide all budget bars, counters, labels, and budget-based ranking when disabled.
- [ ] Preserve selections when Budget Mode changes.
- [ ] Keep hardware compatibility and feasibility checks active in both modes.
- [ ] Avoid silently dropping applications or reducing allocations below requirements.

### 5. Application selection and recommendations

- [ ] Build a searchable catalog with categories and checkbox selection.
- [ ] Display project purpose, license, source, and upstream website.
- [ ] Display supported architectures, runtimes, and operating systems.
- [ ] Display minimum and recommended resource estimates.
- [ ] Display mobile/desktop client availability.
- [ ] Display storage requirements, ports, dependencies, and exposure options.
- [ ] Display GPU/USB requirements and privileges.
- [ ] Display backup, restoration, and update support.
- [ ] Ask workload questions only when relevant to selected applications.
- [ ] Adjust estimates for users, concurrent streams, transcoding, photo ingestion, and retention.
- [ ] Record estimate sources, assumptions, confidence, and verification dates.
- [ ] Use reviewed estimates when official requirements are unavailable.
- [ ] Resolve dependencies and report application conflicts.
- [ ] Remove unused dependencies only after their last consumer is removed.
- [ ] Suggest compatible guest placement and explain recommendations.

### 6. VM, LXC, and container architecture

- [ ] Let users choose VM count, operating systems, and guest allocations.
- [ ] Support recommended, simple, isolated, LXC-first, and advanced layouts.
- [ ] Support one standalone x86-64 Proxmox node for the MVP.
- [ ] Support Debian and Ubuntu through official cloud images.
- [ ] Support Debian LXCs for reviewed compatible workloads.
- [ ] Support one or more Docker VMs.
- [ ] Support manual application assignment and an advanced guest layout editor.
- [ ] Allocate VMIDs and IP addresses deterministically.
- [ ] Detect conflicts with existing guests and externally managed resources.
- [ ] Keep ordinary applications and Docker inside guests.
- [ ] Use dedicated guests for routing and Home Assistant OS.
- [ ] Respect GPU/USB availability during placement.
- [ ] Require explicit choices for privileged containers.
- [ ] Build reusable cloud-init templates without embedded secrets.
- [ ] Generate Ansible and Docker Compose configurations.

### 7. Networking and remote access

- [ ] Preserve the existing LAN bridge, normally `vmbr0`.
- [ ] Generate an isolated service bridge, normally `vmbr1`, after conflict checks.
- [ ] Allocate an editable private subnet and static guest addresses.
- [ ] Deploy an access gateway with LAN and service-network interfaces.
- [ ] Support local-only, Tailscale, Pangolin/Newt, and combined access.
- [ ] Use one Tailscale gateway device to provide access to the service subnet.
- [ ] Support one gateway destination IP with hostname routing for web services.
- [ ] Explain subnet routing and hostname proxying separately.
- [ ] Configure forwarding and outbound NAT where required.
- [ ] Generate Tailscale route approval instructions and suggested access policies.
- [ ] Configure Newt against the user's Pangolin endpoint.
- [ ] Provide per-app private, LAN, tailnet, authenticated, and public exposure policies.
- [ ] Generate default-deny firewall rules and declared dependency exceptions.
- [ ] Protect databases and Proxmox management from unintended exposure.
- [ ] Prevent duplicate hostname/proxy ownership.
- [ ] Provide Caddy as the initial reverse proxy and modular support for alternatives.
- [ ] Generate DNS, split-DNS, domain, and TLS instructions.
- [ ] Support public certificates and local certificate authority workflows.
- [ ] Verify allowed access paths and denied access paths.

### 8. Modular design

- [ ] Define versioned interfaces for all integration modules.
- [ ] Create application modules for metadata, dependencies, templates, and lifecycle hooks.
- [ ] Create OS-image modules for discovery, verification, and initialization capabilities.
- [ ] Create runtime modules for VM, LXC, and Compose behavior.
- [ ] Create access-provider modules for Tailscale and Pangolin/Newt.
- [ ] Create storage and backup provider modules.
- [ ] Create resource-policy modules for reserves, grouping, and CPU sharing.
- [ ] Create release-provider adapters for official APIs, registries, and package feeds.
- [ ] Create update-strategy modules for migrations, health checks, and recovery.
- [ ] Derive catalog cards and relevant forms from module metadata.
- [ ] Add catalog applications without app-specific changes throughout the website.
- [ ] Version modules independently while validating schema compatibility.
- [ ] Declare maintainers, dependencies, conflicts, permissions, and provenance.
- [ ] Review executable module hooks and restrict unattended privileges.
- [ ] Publish signed catalog snapshots independently of website/CLI releases.

### 9. Continuous upstream release tracking

- [ ] Discover versions from official upstream sources.
- [ ] Track application, OS-image, connector, template, catalog, and project releases.
- [ ] Use scheduled polling and authenticated webhooks where available.
- [ ] Implement caching, conditional requests, rate limits, retries, and backoff.
- [ ] Normalize versions without assuming all projects use semantic versioning.
- [ ] Distinguish stable, prerelease, and unsupported releases.
- [ ] Confirm that source releases have corresponding deployable artifacts.
- [ ] Verify architecture availability and artifact checksums/signatures where supplied.
- [ ] Automatically validate affected modules and dependencies after releases.
- [ ] Publish successful compatible catalog updates automatically.
- [ ] Show newest upstream, newest tested-compatible, and installed versions separately.
- [ ] Display source URLs, last check times, pending checks, and failed validations.
- [ ] Mark cached information stale when upstream checks fail.
- [ ] Avoid permanent production version lists and “latest version” constants in UI code.
- [ ] Recheck resource estimates when releases change requirements.
- [ ] Define and monitor freshness targets for each source.

### 10. Automatic updates and lifecycle management

- [ ] Offer automatic compatible updates during a maintenance window.
- [ ] Offer immediate compatible updates after validation gates pass.
- [ ] Offer notify-and-review updates.
- [ ] Offer explicit advanced upstream/prerelease opt-in.
- [ ] Configure policies independently for host, guest OS, applications, and infrastructure.
- [ ] Resolve the newest tested-compatible stable release for fresh installs.
- [ ] Recheck resources, dependencies, and exposure before upgrades.
- [ ] Provide defined migration paths for breaking upgrades.
- [ ] Capture application-consistent backups before stateful upgrades.
- [ ] Use snapshots as an additional recovery mechanism where supported.
- [ ] Run post-update service and access checks.
- [ ] Implement application-aware recovery, including database restoration when required.
- [ ] Keep update discovery active when installation is deferred or blocked.
- [ ] Record update history, health results, and recovery instructions.
- [ ] Update inventory and documentation after deployment changes.
- [ ] Provide a catalog revocation process for compromised releases.

### 11. Manifests and generated bundles

- [ ] Define a versioned secret-free Homelab manifest schema.
- [ ] Define module and application catalog schemas.
- [ ] Validate identifiers, addresses, hostnames, ports, mounts, and dependencies.
- [ ] Reject unsupported fields in strict validation mode.
- [ ] Support externally managed resources and reserved identifiers.
- [ ] Record explicit defaults and deterministic ordering.
- [ ] Provide schema migrations that preserve intent.
- [ ] Export/import projects as YAML and JSON.
- [ ] Generate a lockfile containing resolved versions, digests, and catalog revisions.
- [ ] Keep exact artifacts fixed during a reviewed apply operation.
- [ ] Refresh the lockfile through the update planning workflow.
- [ ] Generate a downloadable ZIP/tar bundle.
- [ ] Include commands, cloud-init, Ansible, Compose, proxy, and firewall files.
- [ ] Include installation instructions, architecture, inventory, and service URLs.
- [ ] Include backup coverage and disaster-recovery documentation.
- [ ] Keep historical catalog snapshots available for reproducible restoration.

### 12. Local deployment CLI

- [ ] Choose and scaffold the CLI implementation; Go is the initial proposal.
- [ ] Implement `init` and manifest loading.
- [ ] Implement `validate`.
- [ ] Implement read-only `doctor` for hardware, storage, bridges, permissions, and compatibility.
- [ ] Implement `plan` with exact ordered operations and findings.
- [ ] Implement `apply` with review confirmation and staged execution.
- [ ] Implement `status` and `export-inventory`.
- [ ] Implement `backup-check` and `restore-test`.
- [ ] Implement targeted `destroy` with data retained by default.
- [ ] Use Proxmox API operations and narrow command adapters where necessary.
- [ ] Download and verify official guest images.
- [ ] Wait for guest readiness before configuration.
- [ ] Prompt for secrets locally and redact logs.
- [ ] Track managed resource tags, manifest hashes, and completed stages.
- [ ] Refuse silent adoption of existing unmanaged guests.
- [ ] Support idempotent reapply, interruption recovery, and safe retries.
- [ ] Stop on unsafe partial failure and provide recovery instructions.
- [ ] Export local state for administrative backup.
- [ ] Detect changed hardware or artifacts and require a fresh reviewed plan.

### 13. Storage, backups, and restoration

- [ ] Make storage ownership, mount permissions, and UID/GID behavior explicit.
- [ ] Detect persistent data placed on ephemeral storage.
- [ ] Provide an explicit backup decision for large media datasets.
- [ ] Identify external data excluded from VM backups.
- [ ] Generate per-resource backup coverage, schedules, and retention.
- [ ] Support Proxmox Backup Server and documented alternatives.
- [ ] Provide database-aware backups and application consistency procedures.
- [ ] Keep backup repositories protected from ordinary application writes.
- [ ] Plan independent/off-site backup and a practical 3-2-1 path.
- [ ] Exclude disposable cache and transcode data where appropriate.
- [ ] Rebuild guests from manifests and restore configuration, databases, and bulk data.
- [ ] Recover certificates and remote-access connectivity.
- [ ] Verify services after restoration.
- [ ] Provide disposable automated restore tests.

### 14. Monitoring and operational visibility

- [ ] Monitor Proxmox nodes, guests, and application health.
- [ ] Monitor disk capacity, SMART warnings, RAM pressure, and CPU load.
- [ ] Monitor backup results and backup age.
- [ ] Monitor TLS expiry and remote-access connector health.
- [ ] Provide Uptime Kuma and initial metrics integrations.
- [ ] Keep operational monitoring local by default.
- [ ] Provide actionable diagnostics and maintenance guidance.
- [ ] Add advanced metrics, dashboards, logs, and alert routing later.

### 15. Security and privacy

- [ ] Keep Proxmox, Tailscale, Newt, DNS, and app secrets out of the website.
- [ ] Store runtime secrets with restrictive permissions on target guests.
- [ ] Generate passwords locally using secure randomness.
- [ ] Use least-privilege administrative access where supported.
- [ ] Review privileged guests and executable templates.
- [ ] Sign releases and verify official artifacts.
- [ ] Scan dependencies, containers, and generated bundles.
- [ ] Protect against command injection and path traversal.
- [ ] Maintain default-deny exposure and lateral-access policies.
- [ ] Protect backups and restore operations.
- [ ] Document the threat model and root-automation trust boundary.
- [ ] Keep telemetry disabled by default.
- [ ] Support optional encrypted secret storage/password-manager integrations later.

### 16. Web interface and documentation

- [ ] Build landing, hardware, catalog, guest-layout, access, storage, review, and export screens.
- [ ] Allow exploration without an account.
- [ ] Save/import/export browser projects.
- [ ] Use accessible controls and support keyboard navigation.
- [ ] Provide usable layouts on desktop and mobile.
- [ ] Render the guest and network architecture visually.
- [ ] Explain findings with clear errors, warnings, notices, and recommendations.
- [ ] Provide printable installation and recovery manuals.
- [ ] Link version-specific official documentation.
- [ ] Keep website APIs stateless for project data where practical.
- [ ] Keep planning deterministic for the same inputs and catalog snapshot.

### 17. Initial supported application modules

- [ ] Docker Engine and Compose.
- [ ] Caddy.
- [ ] Tailscale.
- [ ] Pangolin Newt.
- [ ] Uptime Kuma.
- [ ] Nextcloud.
- [ ] Syncthing.
- [ ] Paperless-ngx.
- [ ] Immich.
- [ ] Jellyfin.
- [ ] Navidrome.
- [ ] Vaultwarden.
- [ ] Home Assistant OS.
- [ ] AdGuard Home.
- [ ] Forgejo or Gitea.
- [ ] n8n.
- [ ] Expand into calendar/contacts, game servers, archival, and additional community applications.

Every stable application module should include resource metadata, a controlled artifact policy, persistent storage, health checks, update tests, backup/restore instructions, and data-preserving uninstall behavior.

### 18. Testing and release quality

- [ ] Test schemas, migrations, and invalid input handling.
- [ ] Test resource budgets across small and large hardware profiles.
- [ ] Test dependency sharing, guest overhead, storage growth, and overcommit behavior.
- [ ] Test that Budget Mode can be hidden completely without losing selections.
- [ ] Test guest grouping, GPU/USB constraints, and exposure policies.
- [ ] Validate rendered Compose, Ansible, proxy, and firewall configurations.
- [ ] Test upstream discovery, stale cache, rate limits, and artifact availability.
- [ ] Test update compatibility, migrations, recovery, and catalog revocation.
- [ ] Test local secret redaction and template input security.
- [ ] Test create/update/remove in a disposable Proxmox environment.
- [ ] Test interrupted apply, state recovery, and unchanged reapply.
- [ ] Test complete configuration, deployment, access, backup, and restore workflows.
- [ ] Automate relevant checks in CI.
- [ ] Build signed CLI releases and software bills of materials.
- [ ] Publish compatibility matrices, release notes, and migration documentation.

### 19. Development milestones

- [ ] **Foundation:** Repository, license, architecture, contribution, and security documents.
- [ ] **Hardware and budgets:** Hardware schema, discovery import, and resource calculator.
- [ ] **Modular planner:** Module schemas, dependency resolution, placement, and recommendations.
- [ ] **Web configurator:** Hardware wizard, checkbox catalog, Budget Mode, layout, and export.
- [ ] **Release pipeline:** Official source adapters, validation, and signed catalog delivery.
- [ ] **Read-only CLI:** Validate, doctor, and exact planning against a real node.
- [ ] **First deployment:** Gateway + Docker VM + Tailscale + Caddy + Uptime Kuma.
- [ ] **Second access path:** Pangolin/Newt with per-app exposure and verification.
- [ ] **Operations:** Backups, restore verification, monitoring, and automatic compatible updates.
- [ ] **Public alpha:** Documentation, signed releases, reviewed catalog, and external feedback.

### 20. Future expansion

- [ ] Multi-node Proxmox clusters and migration policies.
- [ ] High availability and redundant gateways.
- [ ] Advanced ZFS topology planning and optional Ceph integration.
- [ ] ARM planning/deployment targets where the underlying platform supports them.
- [ ] VLAN-aware topology generation.
- [ ] Multiple sites and off-site replication.
- [ ] Appliance hardware profiles.
- [ ] Existing-environment discovery, adoption, and import.
- [ ] Migration of applications between managed guests.
- [ ] Community catalog repositories and independent mirrors.
- [ ] Energy-use estimates and scheduling.
- [ ] Optional support services that preserve user ownership.
- [ ] Optional privacy-preserving research on power, utilization, administrative time, and recovery.

## MVP completion criteria

- [ ] A user can enter supported hardware and select five to ten applications.
- [ ] Budget Mode accurately reflects selections and can be hidden entirely.
- [ ] The planner generates a valid guest, storage, and private-network design.
- [ ] The user can select local-only, Tailscale, Pangolin, or combined access.
- [ ] The exported manifest and documentation contain no deployment secrets.
- [ ] The local CLI validates the actual node and presents every planned change.
- [ ] A gateway and Docker VM deploy reproducibly on supported hardware.
- [ ] Services are reachable through intended access paths and blocked elsewhere.
- [ ] Upstream releases are discovered and compatible updates are delivered automatically.
- [ ] Every stable app has tested configuration and documented recovery.
- [ ] Every persistent volume has an explicit backup inclusion/exclusion decision.
- [ ] An unchanged deployment can be reapplied without destructive changes.
- [ ] A backup can be verified and a supported restoration completed.
- [ ] Supported fresh deployments succeed without manual edits in at least 90% of test runs.
- [ ] Credentials never appear in website requests or deployment logs.

## How to use this checklist

Edit this file and change `- [ ]` to `- [x]` when a goal is complete. Use GitHub issues for implementation details, discussions, and smaller subtasks. Keep unfinished goals unchecked until their behavior is implemented and verified.

No installation commands are published here yet because the deployment tool has not been released.