# QWEN.md — CoovaChilli (Breath Fork) Modernization Plan

**Purpose**
Guide Qwen Coder to modernize a CoovaChilli fork into an IPv6‑first captive portal with SLAAC, current WISPr interoperability, a clean signup/login API, a responsive walled garden, and an admin backend integrated with FreeRADIUS v3 (passwords, vouchers/tickets, OTP), plus optional WPA3 (Enterprise or Personal) modes. This document defines architecture, tasks, tests, build steps, and coverage.

---

## 1) Vision & Scope

* **IPv6‑first**: Native dual‑stack; complete support for SLAAC (RAs), DHCPv6 (optional), ND‑proxy, IPv6 firewalling and accounting.
* **Modern captive experience**: Responsive portal UI, standards‑based redirection/handshake, WISPr‑compatible flows, internationalization, and accessibility.
* **Admin & APIs**: JSON REST admin API for users, vouchers, OTP, device registration, and session control; webhook/RADIUS event sinks.
* **RADIUS v3 integration**: PAP/CHAP/MSCHAPv2, EAP‑TTLS/PEAP for Enterprise Wi‑Fi; attributes for bandwidth caps, quotas, and session limits.
* **Security**: WPA3‑Enterprise (802.1X + RADIUS) and WPA3‑Personal (SAE) support with hostapd; hardened defaults; rate limiting; CSRF/ACLs; full audit.
* **Compliance**: GDPR‑aligned data handling, clear consent UX, portable exports, deletion requests, and traceable policy revocation.

**Non‑Goals (initial)**

* Proprietary WISPr extensions unique to vendors unless a clear interop need exists.
* Building a full marketing CMS; the portal renders via templates/components.

---

## 2) High‑Level Architecture

```
+----------------------------+
|  Admin UI (Web)            |
|  - Tailwind/HTMX or React  |
+--------------+-------------+
               |
               v
+--------------+-------------+          +---------------------+
|  Admin/API Service (Go)    |<-------->|  FreeRADIUS v3      |
|  - REST + JWT, OIDC        | RADIUS   |  - users/OTP/voucher|
|  - Voucher & OTP flows     | acct/auth|  - rlm_sql, rlm_rest|
|  - Device registry         |          +---------------------+
|  - Policy/ACL mgmt         |
+--------------+-------------+
               |
               v
+--------------+-------------+          +---------------------+
|  CoovaChilli Core (Fork)   |<-------->| hostapd (WPA3 opt.) |
|  - IPv6 (SLAAC/RA/ND)      | control  |  - SAE / 802.1X     |
|  - WISPr redir/login       | socket   +---------------------+
|  - Session/NAT/accounting  |
|  - Walled garden gateways  |
+--------------+-------------+
               |
               v
+--------------+-------------+
| nftables/OVS/bridge layer  |
|  - dual-stack filters       |
|  - walled-garden IP/FQDN   |
+----------------------------+
```

---

## 3) IPv6 & SLAAC Requirements

**Core tasks**

1. Add Router Advertisement (RA) emission in captive interface context.
2. Support **SLAAC** client address assignment; maintain per‑client IPv6 bindings.
3. Optional **DHCPv6** (IA\_NA; IA\_PD not required on captive interface) with DNS option (RDNSS via RA or DHCPv6 option 23).
4. **ND‑Proxy** for L2 segments when isolation is required; neighbor cache tracking per session.
5. Dual‑stack accounting (Octets, Packets), framed‑IPv6‑prefix attributes, Interim‑Updates.
6. IPv6 DNS interception / walled‑garden exceptions (AAAA, HTTPS RR support).

**Acceptance**

* Clients receive a global or ULA address via SLAAC; DNS works; captive redirection triggers on both v4 and v6; accounting sent to RADIUS.
* RA and DHCPv6 configurations are mutually compatible; no duplicate address detection failures caused by the gateway.

---

## 4) WISPr & Portal Interop

**Targets**

* Support legacy WISPr 1.0/2.0 attributes and common vendor interop fields.
* Redirection endpoints and success codes compatible with: Cisco/Meraki, Aruba, MikroTik, Ubiquiti, OpenNDS, pfSense packages.

**Endpoints (portal)**

* `GET /login` → portal form; returns WISPr XML/JSON where required.
* `POST /login` → credentials/voucher/OTP submit; returns redirect to success URL or error.
* `GET /logout` → end session.
* `GET /status` → client state summary.
* `GET /wispr` → WISPr handshake (XML) for clients expecting XML.

**Acceptance**

* Auto‑launch on Android Captive Portal API, iOS CNA, Windows NCSI, macOS CNA.
* Round‑trip success for username/password, voucher, OTP; XML and JSON profiles verified in interop tests.

---

## 5) Admin Backend & Public API

**Service**: Go (chi/fiber/echo), Postgres or MariaDB.

**Auth**

* Admin: OIDC (optional), JWT w/ short TTL + refresh.
* Clients: session tokens bound to MAC/IPv6 DUID where applicable.

**Entities**

* Users (username, email, password hash, roles)
* Devices (MAC, optional DUID/IPv6, owner, trust state)
* Vouchers/Tickets (code, quota/time, expiry)
* OTP secrets (TOTP, step, backup codes)
* Policies (rate limits, walled garden sets, time windows)
* Sessions (start/stop, octets, IPs, AP/node)

**Key REST endpoints (v1)**

* `POST /api/v1/signup` → create user; email verify webhook.
* `POST /api/v1/login` → issue JWT for admin UI.
* `POST /api/v1/vouchers` → create/bulk import; `GET /.../validate?code=...`.
* `POST /api/v1/otp/seed` → create TOTP seed; `POST /api/v1/otp/verify`.
* `GET /api/v1/sessions?mac=...` → active session lookup; `POST /api/v1/sessions/:id/disconnect`.
* `PUT /api/v1/policies/:id` → update shaping/walled garden sets.
* `GET /api/v1/export/gdpr` → user export; `DELETE /api/v1/gdpr/:user` → right to erasure.

**RADIUS Integration**

* Use FreeRADIUS v3 with `rlm_sql` for users/vouchers; `rlm_totp` or `rlm_rest` for OTP.
* Map policy to standard attributes: `Session-Timeout`, `Idle-Timeout`, `Rate-Limit` (vendor/Cisco/Chilli variants), `Acct-Interim-Interval`.

---

## 6) WPA3 Modes

* **Enterprise**: 802.1X with hostapd; EAP‑TTLS/PEAP to FreeRADIUS v3; captive portal optional for device onboarding.
* **Personal**: WPA3‑SAE for small/private deployments (not typical captive); portal optional for policy acceptance/walled garden content only.

**hostapd flags** (illustrative)

```ini
ieee80211w=2
sae_require_mfp=1
wpa=2
wpa_key_mgmt=SAE WPA-PSK WPA-EAP
rsn_pairwise=CCMP
ieee8021x=1
auth_server_addr=127.0.0.1
auth_server_port=1812
auth_server_shared_secret=radiussecret
```

---

## 7) Walled Garden & UI

* **Responsive UI**: Tailwind + Alpine/HTMX (or React) templates; works on Android/iOS CNA, Windows, macOS.
* **Allow‑lists**: FQDN and IP6/IP4 CIDRs; supports HTTPS (SNI/CONNECT) via domain‑based exceptions.
* **Accessibility**: WCAG 2.2 AA; language switch; high‑contrast.

---

## 8) Build & Packaging (Alpine / Arch preferred)

**Dependencies (core)**

* C toolchain, libnl3, OpenSSL/mbedTLS (choose one), json‑c, libev/epoll, cmocka (tests), gcov/lcov (coverage).

**Alpine (apk)**

```sh
apk add --no-cache build-base autoconf automake libtool git \
  libnl3-dev openssl-dev linux-headers json-c-dev cmocka-dev \
  pkgconf nftables-dev iproute2
```

**Arch (pacman)**

```sh
pacman -S --needed base-devel autoconf automake libtool git \
  libnl openssl json-c cmocka pkgconf nftables iproute2
```

**Configure & build (autotools)**

```sh
autoreconf -fi
./configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --with-openssl \
  --enable-ipv6 \
  --enable-json
make -j$(nproc)
make install
```

**Optional Meson transition**

* Provide `meson.build` for faster CI; keep autotools for compatibility until parity.

---

## 9) System Services

**systemd (Arch)**: `coovachilli.service`

```ini
[Unit]
Description=CoovaChilli (Fork) Captive Portal
After=network-online.target

[Service]
ExecStart=/usr/sbin/chilli --config /etc/chilli/config
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**OpenRC (Alpine)**: `/etc/init.d/coovachilli`

```sh
#!/sbin/openrc-run
command="/usr/sbin/chilli"
command_args="--config /etc/chilli/config"
pidfile="/run/chilli.pid"
depend() {
  need net
}
```

---

## 10) nftables (dual‑stack skeleton)

```nft
flush ruleset

table inet captive {
  chain input {
    type filter hook input priority 0;
    ct state established,related accept
    iifname "chilli0" tcp dport { 80,443 } accept  # portal
    iifname "chilli0" udp dport { 53,67,68,546,547 } accept # DNS/DHCPv4/v6
    iifname "chilli0" icmp type { echo-request, echo-reply } accept
    iifname "chilli0" icmpv6 accept
    counter drop
  }
  chain forward {
    type filter hook forward priority 0;
    ct state established,related accept
    # allow to walled-garden sets here (ip/ip6 sets)
    counter drop
  }
}
```

---

## 11) Testing & Coverage

**Unit tests (C)**

* Framework: **cmocka**
* Coverage: **gcov/lcov** → HTML + CI artifact; fail build if coverage < 85% for new/changed lines.

**Integration tests**

* Python **pytest** harness using **ip netns** to emulate STA <-> chilli0 <-> uplink.
* Launch `dnsmasq`/`radvd` test doubles if needed; or use built‑in RA logic.
* Validate: SLAAC assignment, captive redirect, login (voucher/password/OTP), quota/timeouts, accounting Interim‑Updates.

**Interop tests**

* WISPr XML/JSON contracts; canned traces from multiple vendors.
* FreeRADIUS v3 container with seeded users, vouchers, OTP secrets; verify Access‑Accept/Reject and attribute mapping.

**Security tests**

* `clang -fsanitize=address,undefined` builds; **valgrind** leak checks.
* Fuzz critical parsers (WISPr, RADIUS attribute decode) with **libFuzzer**.

**CI matrix (GitHub Actions or Forgejo/Drone)**

* Alpine edge, Arch stable; kernels 6.6 LTS & latest; GCC and Clang.
* Jobs: lint → build → unit → integ → interop → fuzz (nightly) → coverage upload.

---

## 12) Coding Standards

* C99, pedantic warnings `-Wall -Wextra -Werror -Wpedantic`.
* Avoid UB; strict aliasing off; secure string ops; bounded copies.
* No blocking DNS or HTTP calls in packet path.
* Config via `/etc/chilli/*.conf` + environment overrides.
* Structured logs (JSON) optional for admin ingestion.

---

## 13) Data & Privacy (GDPR)

* Minimal retention; configurable TTLs for session logs and auth traces.
* Export endpoint returns user data (JSON + CSV); erasure scrubs PII while preserving aggregate counters.
* DPO contact & policy version included in portal footer.

---

## 14) Deliverables & Milestones

**M1: Build & CI baseline (2 weeks)**

* Autotools cleaned; Alpine/Arch builds pass; unit test scaffold; 60% coverage baseline.

**M2: IPv6 + SLAAC (3 weeks)**

* RA emission; ND handling; dual‑stack accounting; captive redirection on v6.

**M3: WISPr & Portal (3 weeks)**

* Interop XML/JSON; responsive UI; CNA auto‑launch verified.

**M4: Admin API & RADIUS (3 weeks)**

* Users/vouchers/OTP; FreeRADIUS v3 interop; session control endpoints.

**M5: WPA3 options & hardening (2 weeks)**

* Hostapd integration examples; security tests; rate limiting; audit logs.

**M6: Coverage ≥ 85% & Docs (1 week)**

* Integration/interop suites complete; lcov published; admin manual and deploy guides.

---

## 15) Quick Start (Dev)

```sh
# Alpine
apk add --no-cache build-base autoconf automake libtool libnl3-dev openssl-dev \
  linux-headers json-c-dev cmocka-dev pkgconf nftables iproute2 git

# Arch
pacman -S --needed base-devel autoconf automake libtool libnl openssl \
  json-c cmocka pkgconf nftables iproute2 git

git clone https://example.com/akadata/coovachilli-fork.git
cd coovachilli-fork
autoreconf -fi && ./configure --enable-ipv6 --with-openssl && make -j$(nproc)
ctest || make check   # if using CTest; otherwise `make check`
```

---

## 16) Configuration Stubs

**/etc/chilli/config** (excerpt)

```ini
# Interface
HS_WANIF=eth0
HS_LANIF=chilli0

# IPv6
HS_IPV6=1
HS_RA_ENABLE=1
HS_RDNSS=2001:4860:4860::8888 2001:4860:4860::8844

# Portal
HS_UAMFORMAT=https://portal.example.com/login
HS_UAMHOMEPAGE=https://portal.example.com/status

# RADIUS
HS_RADIUS=127.0.0.1
HS_RADIUS2=127.0.0.1
HS_RADIUSSECRET=radiussecret
HS_RADCONF=/etc/raddb/clients.conf

# Accounting
HS_ACCT_INTERIM=300
```

---

## 17) Walled Garden Examples

```ini
# FQDN allow-list
garden.fqdn=*.example-cdn.com,*.stripe.com,*.paypal.com
# IPv4/IPv6 CIDRs
garden.ip=13.107.0.0/16,2a02:26f0::/32
```

---

## 18) Release Checklist

* [ ] Changelog and semantic version bump
* [ ] Alpine & Arch packages build
* [ ] CI green on matrix
* [ ] Coverage ≥ 85%, no new critical/static analyzer findings
* [ ] Interop test suite passes (WISPr/XML+JSON)
* [ ] GDPR docs updated; DPO contact in footer
* [ ] Security review notes archived

---

## 19) References (implementation guidance)

* WISPr XML profile, captive‑network detection behaviours (Android/iOS/Windows/macOS)
* FreeRADIUS v3 admin & `rlm_sql`, `rlm_rest`, OTP modules
* hostapd WPA3/SAE and 802.1X examples
* RFCs: SLAAC (4862), RDNSS (8106), Router Advertisements (4861), DHCPv6 (8415)

---

## 20) Next Actions for Qwen Coder

1. Set up CI with Alpine + Arch jobs; build, unit tests, and lcov artifacts.
2. Implement RA/SLAAC path with per‑session IPv6 bookkeeping; add unit tests.
3. Add WISPr XML/JSON handlers and interop fixtures; portal UI skeleton.
4. Wire Admin API to FreeRADIUS v3 (users/vouchers/OTP) and session control.
5. Provide hostapd example configs for WPA3‑E and WPA3‑SAE.
6. Finish nftables policy sets and walled‑garden domain/IP logic (dual‑stack).
7. Expand integration tests: CNA triggers, login flows, accounting, quotas.
8. Raise coverage to ≥ 85%; enable sanitizers; fuzz parsers nightly.
9. Add a /docs folder and for each improvement stage add docs , plan of action, roadmap and changes.
10. Add a /patches folder so we can always patch from scratch all the changes and keep this up to date.


# QWEN.md — Addendum: Portability, Firewalls, MDM, API & Ops

This addendum extends the modernization plan to cover cross‑platform targets (Linux/BSD/macOS), firewall backends (nftables/iptables/pf), mobile device onboarding (MDM/SCEP/EST), API evolutions, init/runtime scripts, testing matrices, and long‑term roadmap items such as CAPPORT/Passpoint and eBPF.

---

## 1) Support Tiers & Architectures

**Tier‑1 (production focus)**

* **Linux (Alpine, Arch)** on **x86\_64** and **aarch64**.
* Netfilter stack: **nftables** first; **iptables‑nft** compatibility; **ipset** optional.

**Tier‑2 (supported with caveats)**

* **FreeBSD 14+** (x86\_64, aarch64): firewall **pf(4)**; `libpfctl`.
* **OpenBSD 7.5+** (amd64, arm64): firewall **pf(4)**; stricter pledge/unveil—portal helpers must be split into least‑privileged daemons.

**Tier‑3 (dev/test only)**

* **macOS 13+ (arm64/x86\_64)**: PF is present but **System Extensions/NEFilterDataProvider** restrictions limit production use; captive workflows differ. Use for UI/API dev and interop tests only.

**Rationale**

* Tier‑1 aligns with target deployments and packaging preferences (apk/pacman).
* Tier‑2 broadens reach to ISP and campus environments where BSD is common.
* Tier‑3 enables developer convenience and limited field demos, not gateway‑grade service.

---

## 2) Firewall Backend Abstraction

Introduce a thin, testable abstraction layer `fwbackends/` with unified intents:

* Objects: {chains/tables, rules, sets, counters, NAT, redir hooks, walled‑garden FQDN/IP allowlists}.
* Backends: `nft`, `iptables`, `pf`. Runtime chooses via config or autodetect.

**Linux default**: `nft` with declarative rulesets generated from templates.
**Linux fallback**: `iptables` (legacy) only when `nft` is unavailable; warn loudly.
**BSD**: `pfctl` anchors under `com.akadata.chilli/*` with dedicated tables for allowlists and client state.

**Example anchors (pf)**

```
anchor "akadata/chilli"
load anchor "akadata/chilli" from "/etc/pf.anchors/akadata_chilli.conf"
```

Tables: `table <chilli_allow4>`, `table <chilli_allow6>`, `table <chilli_clients4>`, `table <chilli_clients6>`

**DNS/HTTPS realities**

* Support SNI‑based exemptions for HTTPS in both nft/pf via transparent proxy marks or CONNECT domain lists where feasible.
* Document limits: full SNI visibility may not exist for QUIC/DoH; provide DoH/DoT fallback capture or explicit allowlists.

---

## 3) CAPPORT, WISPr, Passpoint

**Immediate**: Maintain WISPr XML/JSON interop as in base document.

**Add**:

* **IETF CAPPORT** (RFC 8908/8906/8910) discovery and API: `/.well-known/captive-portal` advertisement; JSON API for portal status; HTTP 511 signaling where appropriate without breaking CNA.
* **Hotspot 2.0 / Passpoint** roadmap: ANQP/NaiRealm config via hostapd; OSU (Online Sign‑Up) integration path with external OSU server; long‑term direction.

---

## 4) Mobile Device Management & BYOD Onboarding

**Goals**

* Smooth enrollment to EAP‑TLS or WPA2/3‑Enterprise without manual profile hacks.
* Managed and unmanaged devices supported.

**Components**

* **SCEP/EST** enrollment for client certs (EAP‑TLS): integrate with FreeRADIUS + CA (akadata‑CA). Provide `/api/v1/enroll/scep` and `/api/v1/enroll/est` gateways.
* **ACME (RFC 8555)** for service cert automation (gateway/portal), using DNS‑01/HTTP‑01 as allowed.
* **MDM hooks**: optional connectors for Apple MDM (profiles), Android Enterprise (managed config), and generic **OMA‑DM** where available.

**Portal onboarding flow**

1. Guest lands on captive portal → chooses **Voucher**, **Password**, or **Certificate (recommended)**.
2. Certificate path issues one‑time token → device fetches mobileconfig (Apple) or PKCS#12/PEM bundle (Android/Windows) via SCEP/EST.
3. RADIUS authorizes via EAP‑TLS thereafter; portal no longer needed except for policy notices.

---

## 5) API Evolution & Governance

**Versioning**: `v1` (current), plan `v2` with non‑breaking additions; use SemVer; include `X‑Akadata‑Request‑Id` per call.

**Capabilities to add**

* **Idempotency** via `Idempotency-Key` on mutating endpoints.
* **Pagination**: `?page=1&per_page=50` with `Link` headers.
* **Rate limits**: `429` with `Retry-After`; expose `X‑RateLimit-*` headers.
* **Bulk ops**: vouchers/users import/export; session batch disconnect.
* **Webhooks**: signed (HMAC) events for `session.started`, `session.stopped`, `auth.accept`, `auth.reject`, `quota.exhausted`.
* **Tenancy**: `org_id` scoping for MSP operators; RBAC roles (viewer, operator, auditor, admin).

**Security**

* JWT with short TTL + rotating refresh tokens; optional mTLS for admin API.
* Audit log with tamper‑evident hashing (append‑only, merkle proof option later).

---

## 6) Build System, Toolchains & Crypto

**Build**

* Keep Autotools; add Meson as optional path.
* Validate with **musl** (Alpine) and **glibc** (Arch) toolchains.
* FreeBSD/OpenBSD: **clang** default; link against **LibreSSL** where OpenSSL not preferred.

**Crypto**

* Primary TLS: OpenSSL 3.x (Linux); LibreSSL (BSD) supported.
* Avoid deprecated ciphers; enable TLS 1.3 first; minimum TLS 1.2 for legacy CNA edge cases.

---

## 7) Init & Service Integration

**Linux**

* **systemd**: provided (service + tmpfiles + sysusers if needed).
* **OpenRC**: init script (provided) + conf.d defaults.
* **runit/s6**: example service directories under `contrib/`.

**BSD**

* **rc.d**: `/usr/local/etc/rc.d/chilli` with `chilli_enable=YES` and `chilli_flags="-c /usr/local/etc/chilli/config"`.
* **pf** anchors installed under `/etc/pf.anchors/` and loaded via `/etc/pf.conf` include block.

**Network scripts**

* Provide minimal examples for: `ifup` of captive interface, RA toggles, DHCPv6 toggle, and routing metrics where dual uplinks exist.

---

## 8) Packaging & Distribution

* **Alpine**: `APKBUILD` in `packaging/alpine/`.
* **Arch**: `PKGBUILD` in `packaging/arch/`.
* **FreeBSD**: `ports/net/coovachilli-akadata/Makefile` skeleton.
* **OpenBSD**: `port` outline with `WANTLIB` and `FLAVORS`.
* **Container images**: optionally **podman** (rootless) for the **admin API** only; the gateway dataplane remains host‑native for performance and interface control.

---

## 9) Observability & Ops

* **Metrics**: Prometheus exporter; counters for sessions, bandwidth, auth outcomes, portal latencies.
* **Tracing**: OpenTelemetry (HTTP spans on admin API); log correlation IDs.
* **SBOM**: produce SPDX/JSON; sign artifacts with cosign; publish checksums.
* **Reproducible builds**: fix timestamps; `SOURCE_DATE_EPOCH` honored.

---

## 10) Advanced Networking Roadmap

* **eBPF/XDP** fast path (Linux): optional module for accounting and flow tagging; keep feature‑parity with classic path.
* **OVS/TC** integration for QoS/shaping; expose primitives in policy model.
* **802.11r/k/v** advisory configs for roaming in enterprise deployments.
* **OWE (WPA3‑transition)**: open network with encrypted link; evaluate portal compatibility.

---

## 11) Cross‑Platform Pros & Cons (Concise)

**Linux (Alpine/Arch)**

* Pros: fastest path; nftables modern API; best driver support; easy CI.
* Cons: distro variance; legacy iptables detours on older kernels.

**FreeBSD**

* Pros: stable networking stack; pf powerful tables/anchors; ZFS native.
* Cons: different userland APIs; fewer CNA quirks covered in community docs; packaging work.

**OpenBSD**

* Pros: security model (pledge/unveil); pf first‑class; simple rc.
* Cons: stricter pledges mean more daemon split; performance lower on some NICs.

**macOS**

* Pros: dev convenience; PF present; solid testing for CNA behaviours.
* Cons: not a gateway OS; system extension constraints; limited kernel access without entitlements.

---

## 12) Redundancy & Fallback (iptables/nft/pf)

* Generate rules from a single intent model; renderers produce nft/iptables/pf.
* Ship both nft and iptables rulesets; detect kernel support at boot and select backend.
* For BSD, ensure pf anchors update atomically with `pfctl -f` on temp files.

---

## 13) Test Matrix Enhancements

* **Kernels**: Linux 6.6 LTS, latest stable; BSD 14.1‑RELEASE, OpenBSD 7.5.
* **Archs**: x86\_64, aarch64; run QEMU CI for aarch64 where hardware not present.
* **Backends**: nft, iptables, pf; run the same integration suite via backend flag.
* **CNA Devices**: scripted tests for Android, iOS, Windows, macOS using recorded traces and headless WebKit/Chromium where possible.

---

## 14) Configuration Additions

**Global config**

```
FW_BACKEND=nft|iptables|pf
PLATFORM=linux|freebsd|openbsd|macos
CAPPORT_ENABLE=1
PASSPOINT_ENABLE=0
SCEP_URL=https://ca.example/enroll/scep
EST_URL=https://ca.example/.well-known/est
MDM_WEBHOOK=https://mdm.example/hooks
PROMETHEUS_ENABLE=1
```

---

## 15) Action List for Qwen Coder (Delta)

1. Create `fwbackends/` abstraction and nft/iptables/pf renderers; add unit tests per backend.
2. Implement CAPPORT discovery + JSON API alongside WISPr; preserve CNA compatibility.
3. Add SCEP/EST endpoints and certificate onboarding flow; wire to FreeRADIUS EAP‑TLS.
4. Provide rc.d scripts for FreeBSD + pf anchors; provide OpenBSD rcctl sample.
5. Extend CI matrix to FreeBSD (vm‑image) and Linux aarch64; run interop suites per backend.
6. Add Prometheus exporter; expose standard counters; document scrape config.
7. Add API idempotency/pagination/rate‑limit semantics; sign webhooks; document examples.
8. Generate APKBUILD/PKGBUILD skeletons and publish SBOM/cosign signatures in releases.

