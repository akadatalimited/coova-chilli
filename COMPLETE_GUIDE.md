# Coova Chilli Complete Configuration and Testing Guide

## Table of Contents
1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Dependency Installation](#dependency-installation)
4. [Build Process](#build-process)
5. [Configure Options](#configure-options)
6. [IPv6 Support](#ipv6-support)
7. [Testing Framework](#testing-framework)
8. [Compatibility Matrix](#compatibility-matrix)
9. [Troubleshooting](#troubleshooting)

## Overview

This guide provides comprehensive instructions for building, configuring, and testing Coova Chilli with full IPv6 support. The enhanced version includes modern GCC compatibility, complete IPv6 implementation, and extensive testing frameworks.

## System Requirements

### Minimum Requirements
- Linux kernel 4.9 or higher
- GCC 7.0 or higher (GCC 14+ recommended)
- 512MB RAM
- 100MB disk space

### Recommended Specifications
- Linux kernel 5.4 or higher
- GCC 11+ or Clang 12+
- 1GB RAM
- 500MB disk space

## Dependency Installation

### Debian/Ubuntu Systems

```bash
# Update package lists
sudo apt-get update

# Install essential build tools
sudo apt-get install build-essential autoconf automake libtool pkg-config

# Install required libraries
sudo apt-get install libssl-dev libjson-c-dev

# Install optional libraries (recommended)
sudo apt-get install libpcap-dev libcurl4-openssl-dev

# Install advanced libraries (optional)
sudo apt-get install libnetfilter-queue-dev libavl-dev
```

### Red Hat/CentOS/Fedora Systems

```bash
# Install essential build tools
sudo yum install gcc make autoconf automake libtool pkgconfig

# Install required libraries
sudo yum install openssl-devel json-c-devel

# Install optional libraries (recommended)
sudo yum install libpcap-devel libcurl-devel

# Install advanced libraries (optional)
sudo yum install libnetfilter_queue-devel avl-devel
```

### Arch Linux Systems

```bash
# Install essential build tools
sudo pacman -S base-devel autoconf automake libtool pkgconf

# Install required libraries
sudo pacman -S openssl json-c

# Install optional libraries (recommended)
sudo pacman -S libpcap curl

# Install advanced libraries (optional)
sudo pacman -S netfilter_queue
```

## Build Process

### 1. Clone and Prepare Source

```bash
cd /usr/src
git clone https://github.com/coova/coova-chilli.git
cd coova-chilli
```

### 2. Bootstrap Build System

```bash
# Generate build files
./bootstrap

# Verify bootstrap success
ls -la configure Makefile.in
```

### 3. Configure Build Options

```bash
# Basic configuration
./configure

# IPv6-enabled configuration
./configure --enable-ipv6

# Production configuration
./configure --enable-ipv6 --disable-debug --disable-debug2

# Development configuration
./configure --enable-ipv6 --enable-debug --enable-debug2 --enable-json
```

### 4. Compile

```bash
# Clean previous builds
make clean

# Compile
make

# Check compilation results
ls -la src/.libs/
```

### 5. Install (Optional)

```bash
# Install to system (requires root)
sudo make install
```

## Configure Options

### Core IPv6 Options

| Option | Description | Status |
|--------|-------------|--------|
| `--enable-ipv6` | Enable IPv6 support | ✅ RECOMMENDED |
| `--disable-ipv6` | Disable IPv6 support (IPv4 only) | ⚠️ LEGACY |
| `--enable-ipv6mode=6and4` | IPv6 mode: dual-stack 6and4 | ✅ DEFAULT |
| `--enable-ipv6mode=4to6` | IPv6 mode: IPv4-to-IPv6 translation | ⚠️ EXPERIMENTAL |
| `--enable-ipv6mode=6to4` | IPv6 mode: IPv6-to-IPv4 translation | ⚠️ EXPERIMENTAL |
| `--enable-ipv6only` | Enable IPv6-only mode | ⚠️ SPECIALIZED |
| `--enable-ipv6shared` | Share single /64 among clients | ✅ DEFAULT |
| `--enable-ipv6perclient` | Unique /64 per client | ⚠️ SCALABLE |

### Debugging Options

| Option | Description | Status |
|--------|-------------|--------|
| `--enable-debug` | Enable debugging messages | ✅ DEVELOPMENT |
| `--enable-debug2` | Enable verbose debugging | ✅ DEVELOPMENT |
| `--disable-debug` | Disable debugging messages | ✅ PRODUCTION |
| `--disable-debug2` | Disable verbose debugging | ✅ PRODUCTION |

### Feature Toggle Options

| Option | Description | Status |
|--------|-------------|--------|
| `--disable-chilliquery` | Disable chilli_query utility | ✅ LIGHTWEIGHT |
| `--disable-leakybucket` | Disable leaky bucket shaping | ⚠️ PERFORMANCE |
| `--disable-uamanyip` | Disable UAM any IP access | ✅ SECURITY |
| `--disable-uamuiport` | Disable UAM UI port | ✅ SIMPLIFIED |
| `--disable-accounting-onoff` | Disable Accounting-On/Off | ✅ STANDARD |
| `--disable-tap` | TUN-only (no TAP support) | ✅ MINIMAL |
| `--disable-tcpreset` | Disable TCP reset filtering | ⚠️ CONNECTIVITY |
| `--disable-radproxy` | Disable RADIUS EAP Proxy | ✅ SIMPLE |
| `--disable-coa` | Disable CoA RADIUS support | ✅ STANDARD |
| `--disable-dhcpradius` | Disable DHCP/RADIUS integration | ⚠️ LIMITED |
| `--disable-ieee8021q` | Disable IEEE 802.1Q VLAN | ✅ NON-VLAN |

### Advanced Feature Options

| Option | Description | Status |
|--------|-------------|--------|
| `--enable-json` | Enable JSON support | ✅ MODERN |
| `--enable-wpad` | Enable WPAD support | ⚠️ BROWSERS |
| `--enable-gardenaccounting` | Enable walled garden accounting | ✅ BILLING |
| `--enable-gardenext` | Enable extended walled garden | ⚠️ ADVANCED |
| `--enable-inspect` | Enable cmdsock inspection | ⚠️ DEBUGGING |
| `--enable-sessgarden` | Enable session-based garden | ✅ PER-USER |
| `--enable-sessproxy` | Enable per-session proxy | ✅ ADVANCED |
| `--enable-sessdhcp` | Enable per-session DHCP | ⚠️ SCALABLE |
| `--enable-sessdns` | Enable per-session DNS | ✅ SECURITY |
| `--enable-chillixml` | Enable CoovaChilli XML | ✅ MODERN |
| `--enable-proxyvsa` | Enable VSA attribute proxy | ⚠️ ENTERPRISE |
| `--enable-ipwhitelist` | Enable IP whitelist file | ✅ SECURITY |
| `--enable-uamdomainfile` | Enable uamdomains file | ⚠️ MASSIVE |
| `--enable-redirdnsreq` | Enable DNS query on redirect | ✅ DISCOVERY |
| `--enable-largelimits` | Enable larger limits | ✅ HIGH-CAPACITY |
| `--enable-authedallowed` | Enable authorized garden | ✅ BILLING |
| `--enable-binstatusfile` | Enable binary status file | ✅ PERFORMANCE |
| `--enable-statusfile` | Enable status file | ✅ MONITORING |
| `--enable-chilliproxy` | Enable HTTP AAA Proxy | ⚠️ INTEGRATION |
| `--enable-multiroute` | Enable multiple routes | ⚠️ ADVANCED |
| `--enable-multilan` | Enable multiple LANs | ⚠️ SCALABLE |
| `--enable-chilliradsec` | Enable RadSec AAA Proxy | ⚠️ SECURE |
| `--enable-chilliredir` | Enable Redir server | ✅ PORTAL |
| `--enable-chilliscript` | Enable chilli_script | ⚠️ CUSTOMIZATION |
| `--enable-cluster` | Enable clustering | ⚠️ DISTRIBUTED |
| `--enable-sessionstate` | Enable Session-State attr | ✅ ADVANCED |
| `--enable-sessionid` | Enable Session-Id attribute | ✅ TRACING |
| `--enable-apsessionid` | Enable AP-Session-Id attr | ✅ LOCATION |
| `--disable-coovachilliconfig` | Disable CoovaChilli-Config | ⚠️ LIMITED |
| `--enable-mdns` | Enable MDNS support | ⚠️ DISCOVERY |
| `--enable-netbios` | Enable NetBIOS support | ⚠️ LEGACY |
| `--enable-ieee8023` | Enable IEEE 802.3 Ethernet | ✅ STANDARD |
| `--enable-pppoe` | Enable PPPoE support | ⚠️ BROADBAND |
| `--enable-l2tpppp` | Enable L2TP/PPP Tunneling | ⚠️ ENTERPRISE |
| `--enable-eapol` | Enable EAPOL support | ✅ ENTERPRISE |
| `--enable-miniportal` | Enable Coova miniportal | ✅ SIMPLE |
| `--enable-miniconfig` | Enable minimal cmdline config | ⚠️ EMBEDDED |
| `--enable-ewtapi` | Enable CoovaEWT API | ⚠️ PROPRIETARY |
| `--enable-libjson` | Enable libjson support | ✅ JSON |
| `--enable-ssdp` | Enable SSDP support | ⚠️ DISCOVERY |
| `--enable-layer3` | Enable Layer3 only operation | ⚠️ ROUTER |
| `--enable-modules` | Enable loadable modules | ⚠️ EXPERIMENTAL |
| `--enable-extadmvsa` | Enable admin-user VSA | ⚠️ ENTERPRISE |
| `--enable-redirinject` | Enable content injection | ⚠️ CUSTOMIZATION |
| `--enable-netnat` | Enable net interface NAT | ⚠️ EXPERIMENTAL |
| `--enable-useragent` | Enable user-agent recording | ✅ ANALYTICS |
| `--enable-acceptlanguage` | Enable Accept-Language | ✅ LOCALIZATION |
| `--enable-location` | Enable Location Awareness | ⚠️ ENTERPRISE |
| `--enable-forcedns` | Enable DNS forcing (NAT) | ✅ SECURITY |

### Library Integration Options

| Option | Description | Status |
|--------|-------------|--------|
| `--with-openssl` | Enable OpenSSL support | ✅ RECOMMENDED |
| `--with-matrixssl` | Enable MatrixSSL support | ⚠️ ALTERNATIVE |
| `--with-cyassl` | Enable CyaSSL support | ⚠️ DEPRECATED |
| `--with-nfqueue` | Enable netfilter_queue | ⚠️ ADVANCED |
| `--with-avl` | Enable AVL library | ⚠️ PERFORMANCE |
| `--with-nfcoova` | Enable coova netfilter | ⚠️ KERNEL |
| `--without-sfhash` | Disable SuperFastHash | ⚠️ ALTERNATIVE |
| `--with-lookup3` | Enable Jenkins lookup3 | ⚠️ PERFORMANCE |
| `--with-patricia` | Enable Patricia trie | ✅ IPv6 |
| `--with-pcap` | Enable PCAP support | ⚠️ DEBUGGING |
| `--with-curl` | Enable CURL support | ⚠️ INTEGRATION |
| `--with-mmap` | Enable MMAP support | ⚠️ PERFORMANCE |
| `--with-poll` | Enable POLL support | ✅ STANDARD |
| `--with-ipc-msg` | Enable SV IPC messages | ⚠️ SYSTEM-V |

## IPv6 Support

### IPv6 Architecture Components

1. **SLAAC (Stateless Address Autoconfiguration)**
   - Router Advertisement (RA) messages
   - RDNSS (Recursive DNS Server) option
   - Prefix Information with proper lifetimes

2. **DHCPv6 (Dynamic Host Configuration Protocol for IPv6)**
   - DHCPv6 server functionality
   - Identity Association (IA_NA, IA_TA, IA_PD)
   - DNS server option distribution

3. **ND-Proxy (Neighbor Discovery Proxy)**
   - Neighbor Solicitation handling
   - Neighbor Advertisement responses
   - Duplicate Address Detection (DAD) proxying

4. **Dual-Stack Accounting**
   - IPv6 session accounting with RADIUS
   - IPv6 octet/packet counters
   - framed-IPv6-prefix attribute support

5. **IPv6 Walled Garden**
   - IPv6 address/pass-through rules
   - IPv6 DNS interception
   - AAAA record handling

### IPv6 Configuration Examples

#### Basic IPv6 Setup
```bash
./configure --enable-ipv6
make
```

#### IPv6 with Shared Prefix (Default)
```bash
./configure --enable-ipv6 --enable-ipv6shared
make
```

#### IPv6 with Per-Client Prefixes
```bash
./configure --enable-ipv6 --enable-ipv6perclient
make
```

#### IPv6-Only Mode
```bash
./configure --enable-ipv6 --enable-ipv6only
make
```

#### IPv6 with Debugging
```bash
./configure --enable-ipv6 --enable-debug --enable-debug2
make
```

#### IPv6 Production Build
```bash
./configure --enable-ipv6 --disable-debug --disable-debug2 --enable-gardenaccounting
make
```

## Testing Framework

### Automated Test Scripts

Located in `/usr/src/coova-chilli/`:

1. **`check_dependencies.sh`** - Pre-build dependency checker
2. **`focused_test_suite.sh`** - Core configure option tests
3. **`ipv6_feature_tests.sh`** - IPv6-specific feature tests

### Running Tests

#### Dependency Check
```bash
cd /usr/src/coova-chilli
./check_dependencies.sh
```

#### Configure Options Test
```bash
cd /usr/src/coova-chilli
./focused_test_suite.sh
```

#### IPv6 Features Test
```bash
cd /usr/src/coova-chilli
./ipv6_feature_tests.sh
```

### Manual Testing Procedures

#### 1. Basic Build Test
```bash
cd /usr/src/coova-chilli
make clean
./bootstrap
./configure --enable-ipv6
make
```

#### 2. Feature Verification
```bash
# Check compiled features
src/.libs/chilli --help | grep -i ipv6

# Verify IPv6 binaries
ls -la src/.libs/chilli*
```

#### 3. Runtime Testing
```bash
# Test configuration generation
src/.libs/chilli --help

# Check version
src/.libs/chilli --version
```

## Compatibility Matrix

### ✅ Fully Compatible Combinations

| Combination | Purpose | Status |
|-------------|---------|--------|
| `--enable-ipv6` | Basic IPv6 | ✅ PASS |
| `--enable-ipv6 --enable-debug` | IPv6 debugging | ✅ PASS |
| `--enable-ipv6 --enable-json` | IPv6 with JSON | ✅ PASS |
| `--enable-ipv6 --enable-gardenaccounting` | IPv6 accounting | ✅ PASS |
| `--enable-ipv6 --enable-chillixml` | IPv6 with XML | ✅ PASS |
| `--enable-ipv6 --enable-sessgarden` | IPv6 session garden | ✅ PASS |
| `--enable-ipv6 --disable-uamanyip` | IPv6 secure mode | ✅ PASS |
| `--enable-ipv6 --disable-tap` | IPv6 TUN-only | ✅ PASS |

### ⚠️ Partially Compatible

| Combination | Issue | Solution |
|-------------|-------|----------|
| `--enable-cluster` | Compilation errors | Fix unused functions |
| `--enable-chilliradsec` | Missing dependencies | Install libgnutls |
| `--with-nfcoova` | Kernel module needed | Load coova kernel module |
| `--enable-modules` | Experimental | Use with caution |

### ❌ Incompatible Combinations

| Combination | Reason | Alternative |
|-------------|--------|-------------|
| `--enable-ipv6 --enable-ipv6only --disable-ipv6` | Contradictory options | Choose one |
| `--enable-ipv6perclient --enable-ipv6shared` | Conflicting delegation | Choose one |

## Troubleshooting

### Common Build Issues

#### 1. Missing Dependencies
**Error**: `configure: error: *** OpenSSL development headers not found`
**Solution**: Install OpenSSL development packages

#### 2. Compiler Too Old
**Error**: `configure: error: GCC 4.8 or later required`
**Solution**: Upgrade to GCC 7+ or use Clang

#### 3. Missing pkg-config
**Error**: `configure: error: pkg-config not found`
**Solution**: Install pkg-config package

### Runtime Issues

#### 1. IPv6 Not Working
**Check**: 
- Kernel IPv6 support: `cat /proc/net/if_inet6`
- Interface configuration: `ip -6 addr show`
- Firewall rules: `ip6tables -L`

#### 2. Router Advertisements Not Sent
**Check**:
- Interface permissions: Requires root
- Network configuration: Check subnet settings
- Logs: Enable debug mode

#### 3. DHCPv6 Not Responding
**Check**:
- Port 547 accessibility
- DHCPv6 configuration options
- Client-server communication logs

### Debugging Tips

#### 1. Enable Verbose Logging
```bash
./configure --enable-ipv6 --enable-debug --enable-debug2
make
```

#### 2. Check Configuration
```bash
src/.libs/chilli --help
```

#### 3. Monitor Network Traffic
```bash
# Monitor Router Advertisements
sudo tcpdump -i wlan0 icmp6 and ip6[40] == 134

# Monitor DHCPv6
sudo tcpdump -i wlan0 port 547 or port 546

# Monitor Neighbor Discovery
sudo tcpdump -i wlan0 icmp6
```

### Performance Tuning

#### 1. Optimize for High Load
```bash
./configure --enable-ipv6 --enable-largelimits --with-avl --with-patricia
make
```

#### 2. Reduce Memory Footprint
```bash
./configure --enable-ipv6 --disable-chilliquery --disable-radproxy --disable-coa
make
```

#### 3. Enable Performance Features
```bash
./configure --enable-ipv6 --with-mmap --with-poll --enable-json
make
```

This comprehensive guide provides everything needed to successfully build, configure, and deploy Coova Chilli with full IPv6 support. The enhanced version maintains backward compatibility while adding modern features and ensuring compatibility with contemporary development environments.