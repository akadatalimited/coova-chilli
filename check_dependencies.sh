#!/bin/bash

# Dependency Checker for Coova Chilli
# Checks for required packages and libraries before building

echo "Coova Chilli Dependency Checker"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed (Debian/Ubuntu)
package_installed_deb() {
    dpkg -l | grep -q "^ii.*$1"
}

# Function to check if a package is installed (RedHat/CentOS/Fedora)
package_installed_rpm() {
    rpm -q "$1" >/dev/null 2>&1
}

# Function to check library with pkg-config
check_library() {
    if command_exists pkg-config; then
        if pkg-config --exists "$1" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $1 ($(pkg-config --modversion "$1" 2>/dev/null))"
            return 0
        else
            echo -e "${RED}✗${NC} $1 (not found)"
            return 1
        fi
    else
        # Try to find the library manually
        if ldconfig -p 2>/dev/null | grep -q "$1"; then
            echo -e "${GREEN}✓${NC} $1 (found via ldconfig)"
            return 0
        else
            echo -e "${RED}✗${NC} $1 (not found)"
            return 1
        fi
    fi
}

# Detect OS
if command_exists lsb_release; then
    OS=$(lsb_release -si)
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
elif [ -f /etc/redhat-release ]; then
    OS=$(cat /etc/redhat-release | cut -d' ' -f1)
else
    OS="Unknown"
fi

echo "Detected OS: $OS"
echo ""

# Essential build tools
echo "Essential Build Tools:"
echo "----------------------"

ESSENTIAL_TOOLS=(gcc make autoconf automake libtool pkg-config)
MISSING_ESSENTIAL=0

for tool in "${ESSENTIAL_TOOLS[@]}"; do
    if command_exists "$tool"; then
        version=$($tool --version 2>/dev/null | head -n1 | awk '{print $NF}')
        echo -e "${GREEN}✓${NC} $tool ($version)"
    else
        echo -e "${RED}✗${NC} $tool (missing)"
        MISSING_ESSENTIAL=1
    fi
done

if [ $MISSING_ESSENTIAL -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}Warning:${NC} Missing essential build tools!"
    echo "Install with:"
    if [[ "$OS" =~ "Ubuntu"|"Debian" ]]; then
        echo "  sudo apt-get install build-essential autoconf automake libtool pkg-config"
    elif [[ "$OS" =~ "CentOS"|"Red Hat"|"Fedora" ]]; then
        echo "  sudo yum install gcc make autoconf automake libtool pkgconfig"
    fi
fi

echo ""
echo "Required Libraries:"
echo "-------------------"

# Required libraries for basic Coova Chilli
REQUIRED_LIBS=(
    "libssl"        # OpenSSL
    "json-c"        # JSON support
)

MISSING_REQUIRED=0
for lib in "${REQUIRED_LIBS[@]}"; do
    if check_library "$lib"; then
        true
    else
        MISSING_REQUIRED=1
    fi
done

if [ $MISSING_REQUIRED -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}Warning:${NC} Missing required libraries!"
    echo "Install with:"
    if [[ "$OS" =~ "Ubuntu"|"Debian" ]]; then
        echo "  sudo apt-get install libssl-dev libjson-c-dev"
    elif [[ "$OS" =~ "CentOS"|"Red Hat"|"Fedora" ]]; then
        echo "  sudo yum install openssl-devel json-c-devel"
    fi
fi

echo ""
echo "Optional Libraries (for advanced features):"
echo "-------------------------------------------"

# Optional libraries
OPTIONAL_LIBS=(
    "libpcap"           # PCAP support
    "libcurl"           # CURL support
    "libnetfilter_queue" # Netfilter queue support
    "libavl"            # AVL tree support
)

for lib in "${OPTIONAL_LIBS[@]}"; do
    check_library "$lib"
done

echo ""
echo "Header Files Check:"
echo "------------------"

# Check for specific header files
HEADERS_TO_CHECK=(
    "sys/socket.h"
    "netinet/in.h"
    "arpa/inet.h"
    "net/if.h"
    "linux/if_tun.h"
    "resolv.h"
)

HEADER_PATHS=(
    "/usr/include"
    "/usr/local/include"
    "/usr/include/linux"
)

for header in "${HEADERS_TO_CHECK[@]}"; do
    FOUND=0
    for path in "${HEADER_PATHS[@]}"; do
        if [ -f "$path/$header" ]; then
            echo -e "${GREEN}✓${NC} $header (found in $path)"
            FOUND=1
            break
        fi
    done
    if [ $FOUND -eq 0 ]; then
        echo -e "${RED}✗${NC} $header (not found)"
    fi
done

echo ""
echo "System Capabilities:"
echo "--------------------"

# Check for TUN/TAP support
if [ -e /dev/net/tun ] || [ -e /dev/tun ]; then
    echo -e "${GREEN}✓${NC} TUN/TAP device support"
else
    echo -e "${YELLOW}?${NC} TUN/TAP device support (may need to be created)"
fi

# Check for IPv6 support
if [ -f /proc/net/if_inet6 ]; then
    echo -e "${GREEN}✓${NC} IPv6 kernel support"
else
    echo -e "${YELLOW}?${NC} IPv6 kernel support (may need to be enabled)"
fi

# Check for netfilter support
if grep -q CONFIG_NETFILTER /boot/config-$(uname -r) 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Netfilter support"
else
    echo -e "${YELLOW}?${NC} Netfilter support (kernel modules may be needed)"
fi

echo ""
echo "Recommended Installation Commands:"
echo "----------------------------------"

if [[ "$OS" =~ "Ubuntu"|"Debian" ]]; then
    echo "Minimal installation:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install build-essential autoconf automake libtool pkg-config"
    echo "  sudo apt-get install libssl-dev libjson-c-dev"
    echo ""
    echo "Full installation (with optional features):"
    echo "  sudo apt-get install build-essential autoconf automake libtool pkg-config"
    echo "  sudo apt-get install libssl-dev libjson-c-dev libpcap-dev libcurl4-openssl-dev"
    echo "  sudo apt-get install libnetfilter-queue-dev libavl-dev"
elif [[ "$OS" =~ "CentOS"|"Red Hat"|"Fedora" ]]; then
    echo "Minimal installation:"
    echo "  sudo yum install gcc make autoconf automake libtool pkgconfig"
    echo "  sudo yum install openssl-devel json-c-devel"
    echo ""
    echo "Full installation (with optional features):"
    echo "  sudo yum install gcc make autoconf automake libtool pkgconfig"
    echo "  sudo yum install openssl-devel json-c-devel libpcap-devel libcurl-devel"
    echo "  sudo yum install libnetfilter_queue-devel avl-devel"
fi

echo ""
echo "After installing dependencies, run:"
echo "  cd /usr/src/coova-chilli"
echo "  ./bootstrap"
echo "  ./configure [options]"
echo "  make"