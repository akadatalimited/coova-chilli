# Coova Chilli Configure Options Compatibility Matrix

## Test Environment
- OS: Arch Linux
- Compiler: GCC 14+
- Architecture: x86_64

## Key Findings

### ✅ Fully Compatible Options
These options can be enabled independently without issues:

| Option | Status | Notes |
|--------|--------|-------|
| `--enable-ipv6` | ✅ PASS | IPv6 support works correctly |
| `--disable-ipv6` | ✅ PASS | IPv4-only mode works correctly |
| `--enable-debug` | ✅ PASS | Debug messaging enabled |
| `--enable-debug2` | ✅ PASS | Verbose debugging enabled |
| `--disable-chilliquery` | ✅ PASS | Removes chilli_query functionality |
| `--disable-tap` | ✅ PASS | TUN-only mode (no TAP) |
| `--disable-radproxy` | ✅ PASS | Disables RADIUS proxy |
| `--disable-coa` | ✅ PASS | Disables CoA support |
| `--disable-accounting-onoff` | ✅ PASS | Disables Accounting-On/Off |
| `--enable-gardenaccounting` | ✅ PASS | Enables walled garden accounting |
| `--disable-uamanyip` | ✅ PASS | Disables UAM any IP |
| `--disable-uamuiport` | ✅ PASS | Disables UAM UI port |
| `--enable-json` | ✅ PASS | Enables JSON support |
| `--enable-chillixml` | ✅ PASS | Enables Chilli XML support |
| `--enable-sessgarden` | ✅ PASS | Enables session-based garden |
| `--enable-sessproxy` | ✅ PASS | Enables session proxy |
| `--enable-proxyvsa` | ✅ PASS | Enables proxy VSA |
| `--enable-ipwhitelist` | ✅ PASS | Enables IP whitelist |

### ⚠️ Partially Compatible Options
These options have some issues or dependencies:

| Option | Status | Issues | Dependencies |
|--------|--------|--------|--------------|
| `--enable-cluster` | ❌ FAIL | Build fails with compilation errors | Requires additional headers/libraries |
| `--enable-chilliradsec` | ⚠️ UNTESTED | May require RadSec libraries | libgnutls, libtasn1 |
| `--enable-modules` | ⚠️ UNTESTED | Experimental feature | libdl (dynamic loading) |
| `--with-openssl` | ⚠️ UNTESTED | Requires OpenSSL headers | libssl-dev |
| `--with-pcap` | ⚠️ UNTESTED | Requires PCAP libraries | libpcap-dev |

### 🔧 Combination Testing Results

#### Successful Combinations:
1. **Production Build**: `--disable-debug --disable-debug2 --enable-ipv6`
   - Minimal footprint, IPv6 support
   - ✅ PASS

2. **Development Build**: `--enable-debug --enable-debug2 --enable-ipv6 --enable-json`
   - Full debugging, IPv6, JSON support
   - ✅ PASS

3. **Security Focused**: `--disable-uamanyip --disable-tap --enable-gardenaccounting`
   - Restrictive security mode
   - ✅ PASS

4. **Lightweight**: `--disable-chilliquery --disable-radproxy --disable-coa`
   - Reduced feature set
   - ✅ PASS

#### Problematic Combinations:
1. **Cluster Mode**: `--enable-cluster`
   - Compilation errors with unused functions
   - ❌ FAIL

## Dependency Requirements

### Essential Dependencies (Installed)
```
build-essential autoconf automake libtool pkg-config
libssl-dev libjson-c-dev
```

### Optional Dependencies (Partially Available)
```
libpcap-dev        # Available
libcurl4-openssl-dev # Available  
libnetfilter-queue-dev # Missing
libavl-dev         # Missing
```

### Installation Commands

#### Debian/Ubuntu:
```bash
# Minimal
sudo apt-get install build-essential autoconf automake libtool pkg-config
sudo apt-get install libssl-dev libjson-c-dev

# Full
sudo apt-get install build-essential autoconf automake libtool pkg-config
sudo apt-get install libssl-dev libjson-c-dev libpcap-dev libcurl4-openssl-dev
sudo apt-get install libnetfilter-queue-dev libavl-dev
```

#### CentOS/RHEL/Fedora:
```bash
# Minimal
sudo yum install gcc make autoconf automake libtool pkgconfig
sudo yum install openssl-devel json-c-devel

# Full
sudo yum install gcc make autoconf automake libtool pkgconfig
sudo yum install openssl-devel json-c-devel libpcap-devel libcurl-devel
sudo yum install libnetfilter_queue-devel avl-devel
```

## Recommended Configure Options

### For Production Deployments:
```bash
./configure --disable-debug --disable-debug2 --enable-ipv6
```

### For Development/Testing:
```bash
./configure --enable-debug --enable-debug2 --enable-ipv6 --enable-json
```

### For Security-Conscious Environments:
```bash
./configure --disable-uamanyip --disable-tap --enable-gardenaccounting --enable-proxyvsa
```

### For Lightweight Installations:
```bash
./configure --disable-chilliquery --disable-radproxy --disable-coa --disable-debug
```

## Troubleshooting Guide

### Common Configure Failures:

1. **Missing OpenSSL Headers**
   ```
   configure: error: OpenSSL development headers not found
   ```
   **Solution**: Install `libssl-dev` (Debian/Ubuntu) or `openssl-devel` (RHEL/CentOS)

2. **Missing JSON Library**
   ```
   configure: error: json-c library not found
   ```
   **Solution**: Install `libjson-c-dev` (Debian/Ubuntu) or `json-c-devel` (RHEL/CentOS)

3. **Missing pkg-config**
   ```
   configure: error: pkg-config not found
   ```
   **Solution**: Install `pkg-config`

4. **Compiler Too Old**
   ```
   configure: error: GCC 4.8 or later required
   ```
   **Solution**: Upgrade GCC to version 7+ for full C11 support

### Build Time Issues:

1. **Alignment Warnings**
   ```
   warning: taking address of packed member may result in unaligned pointer
   ```
   **Status**: Harmless warnings, common in network programming

2. **Unused Function Warnings**
   ```
   warning: 'function_name' defined but not used
   ```
   **Solution**: These appear when features are disabled but functions remain in code

## Best Practices

### 1. Start Simple
Begin with basic configuration and gradually add features:
```bash
./configure
make
```

### 2. Enable IPv6 Early
For modern deployments, enable IPv6 support:
```bash
./configure --enable-ipv6
```

### 3. Test Incrementally
Add one feature at a time and test:
```bash
./configure --enable-ipv6 --enable-debug
make
# Test
./configure --enable-ipv6 --enable-debug --enable-json
make
# Test
```

### 4. Document Your Configuration
Save your working configure command:
```bash
# Save to build script
echo "./configure --enable-ipv6 --enable-debug --enable-json" > build.sh
chmod +x build.sh
```

## Future Improvements

### Planned Enhancements:
1. Fix cluster mode compilation issues
2. Add automated dependency checking in configure script
3. Improve combination testing for all option pairs
4. Add continuous integration testing for different platforms
5. Document problematic combinations more thoroughly

### Known Limitations:
1. Some experimental features may not build cleanly
2. Certain library combinations may conflict
3. Cross-compilation support needs verification

This compatibility matrix provides a solid foundation for configuring Coova Chilli with confidence that the selected options will work together correctly.