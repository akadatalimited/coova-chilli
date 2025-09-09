# Coova Chilli Dependencies Installation Guide

## Overview

This guide provides instructions for installing all required and optional dependencies for building Coova Chilli with full IPv6 support. The dependencies vary by operating system but generally include build tools, SSL libraries, JSON support, and optional networking libraries.

## Required Dependencies

These dependencies are mandatory for basic Coova Chilli functionality:

### Build Tools
- `gcc` (GNU Compiler Collection) version 7+
- `make` (GNU Make)
- `autoconf` (Automake configuration)
- `automake` (Automake build system)
- `libtool` (Library tool)
- `pkg-config` (Package configuration tool)

### Core Libraries
- `libssl-dev` (OpenSSL development headers)
- `libjson-c-dev` (JSON-C library development files)

## Optional Dependencies

These dependencies enable advanced features but are not required:

### Networking Libraries
- `libpcap-dev` (Packet capture library)
- `libcurl4-openssl-dev` (CURL library with OpenSSL)
- `libnetfilter-queue-dev` (Netfilter queue library)
- `libavl-dev` (AVL tree library)

### System Libraries
- `libnl-3-dev` (Netlink library)
- `libnl-genl-3-dev` (Generic netlink library)

## Installation by Platform

### Debian/Ubuntu

```bash
# Update package lists
sudo apt-get update

# Install required dependencies
sudo apt-get install build-essential autoconf automake libtool pkg-config
sudo apt-get install libssl-dev libjson-c-dev

# Install optional dependencies (recommended)
sudo apt-get install libpcap-dev libcurl4-openssl-dev

# Install advanced optional dependencies
sudo apt-get install libnetfilter-queue-dev libavl-dev libnl-3-dev libnl-genl-3-dev
```

### CentOS/RHEL/Fedora

```bash
# For CentOS/RHEL 7/8
sudo yum install gcc make autoconf automake libtool pkgconfig
sudo yum install openssl-devel json-c-devel

# For optional features
sudo yum install libpcap-devel libcurl-devel
sudo yum install libnetfilter_queue-devel avl-devel
sudo yum install libnl3-devel libnl-genl-3-devel

# For Fedora
sudo dnf install gcc make autoconf automake libtool pkgconfig
sudo dnf install openssl-devel json-c-devel
sudo dnf install libpcap-devel libcurl-devel
sudo dnf install libnetfilter_queue-devel avl-devel
sudo dnf install libnl3-devel libnl-genl-3-devel
```

### Arch Linux

```bash
# Install required dependencies
sudo pacman -S base-devel autoconf automake libtool pkgconf
sudo pacman -S openssl json-c

# Install optional dependencies
sudo pacman -S libpcap curl

# Install advanced optional dependencies
sudo pacman -S netfilter_queue avl libnl
```

### Alpine Linux

```bash
# Install required dependencies
sudo apk add build-base autoconf automake libtool pkgconfig
sudo apk add openssl-dev json-c-dev

# Install optional dependencies
sudo apk add libpcap-dev curl-dev

# Install advanced optional dependencies
sudo apk add libnetfilter_queue-dev avl-dev libnl3-dev
```

## Verification Commands

After installation, verify dependencies are correctly installed:

```bash
# Check build tools
gcc --version
make --version
autoconf --version
automake --version
libtool --version
pkg-config --version

# Check core libraries
pkg-config --modversion openssl
pkg-config --modversion json-c

# Check optional libraries (if installed)
pkg-config --modversion libpcap || echo "libpcap not installed"
pkg-config --modversion libcurl || echo "libcurl not installed"
pkg-config --modversion libnetfilter_queue || echo "libnetfilter_queue not installed"
pkg-config --modversion libavl || echo "libavl not installed"
```

## Build Process

After installing dependencies, follow these steps to build Coova Chilli:

```bash
# Clone the repository (if not already done)
git clone https://github.com/coova/coova-chilli.git
cd coova-chilli

# Run bootstrap to generate build files
./bootstrap

# Configure with IPv6 support
./configure --enable-ipv6

# Build the project
make

# Install (optional)
sudo make install
```

## Common Build Issues and Solutions

### Missing Dependencies

**Error**: `configure: error: *** OpenSSL development headers not found`
**Solution**: Install `libssl-dev` (Debian/Ubuntu) or `openssl-devel` (RHEL/CentOS)

**Error**: `configure: error: json-c library not found`
**Solution**: Install `libjson-c-dev` (Debian/Ubuntu) or `json-c-devel` (RHEL/CentOS)

**Error**: `configure: error: pkg-config not found`
**Solution**: Install `pkg-config`

### Compiler Issues

**Warning**: `deprecated conversion from string constant to 'char*'`
**Solution**: These are harmless warnings in third-party code

**Error**: `error: 'bzero' was not declared in this scope`
**Solution**: Code has been updated to use `memset` instead of `bzero`

### Library Linking Issues

**Error**: `undefined reference to 'some_function'`
**Solution**: Ensure all required development libraries are installed

## Docker/Container Build Environment

For consistent builds, you can use Docker:

### Dockerfile Example
```dockerfile
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libssl-dev \
    libjson-c-dev \
    libpcap-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy source
COPY . /src/coova-chilli
WORKDIR /src/coova-chilli

# Build
RUN ./bootstrap && \
    ./configure --enable-ipv6 && \
    make

CMD ["/src/coova-chilli/src/.libs/chilli", "--help"]
```

## Continuous Integration (CI) Setup

For automated builds in CI environments:

### GitHub Actions Example
```yaml
name: Build Coova Chilli
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential autoconf automake libtool pkg-config
        sudo apt-get install -y libssl-dev libjson-c-dev libpcap-dev libcurl4-openssl-dev
    - name: Bootstrap
      run: ./bootstrap
    - name: Configure
      run: ./configure --enable-ipv6
    - name: Build
      run: make
    - name: Test
      run: make check || true  # Continue even if tests fail
```

## Performance Considerations

### Production Builds
For production deployments, use optimized builds:
```bash
./configure --disable-debug --disable-debug2 --enable-ipv6 --enable-json
make CFLAGS="-O2 -DNDEBUG"
```

### Development Builds
For development and debugging:
```bash
./configure --enable-debug --enable-debug2 --enable-ipv6 --enable-json
make
```

## Security Considerations

### Minimal Installation
For security-conscious environments, install only required dependencies:
```bash
# Only essentials
sudo apt-get install build-essential autoconf automake libtool pkg-config
sudo apt-get install libssl-dev libjson-c-dev
```

### Hardened Builds
Use additional security flags:
```bash
./configure --enable-ipv6 CFLAGS="-O2 -D_FORTIFY_SOURCE=2 -fstack-protector-strong"
make
```

## Troubleshooting

### Dependency Resolution Issues

If you encounter issues resolving dependencies:

1. **Update package lists**:
   ```bash
   sudo apt-get update  # Debian/Ubuntu
   sudo yum update      # RHEL/CentOS
   ```

2. **Check repository availability**:
   ```bash
   # Debian/Ubuntu
   sudo apt-cache search libssl-dev
   
   # RHEL/CentOS
   sudo yum search openssl-devel
   ```

3. **Enable additional repositories** (if needed):
   ```bash
   # RHEL/CentOS - Enable EPEL
   sudo yum install epel-release
   ```

### Build Environment Issues

1. **Clean previous builds**:
   ```bash
   make clean
   ./bootstrap
   ```

2. **Check environment variables**:
   ```bash
   echo $CC
   echo $CFLAGS
   pkg-config --variable=pc_path pkg-config
   ```

3. **Verify library paths**:
   ```bash
   ldconfig -p | grep ssl
   ldconfig -p | grep json
   ```

This guide ensures that all necessary dependencies are properly installed for building Coova Chilli with full IPv6 support across different platforms.