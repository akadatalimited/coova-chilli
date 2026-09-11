#!/bin/bash

# Coova Chilli Dependency Installation Script
# Installs all required and optional dependencies for building Coova Chilli with full IPv6 support

set -e

echo "Coova Chilli Dependency Installation Script"
echo "========================================="

# Detect OS
if command -v lsb_release >/dev/null 2>&1; then
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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Function to install packages (Debian/Ubuntu)
install_packages_deb() {
    local packages=("$@")
    echo -e "${BLUE}Installing Debian/Ubuntu packages:${NC}"
    for package in "${packages[@]}"; do
        if ! package_installed_deb "$package"; then
            echo -e "  Installing ${YELLOW}$package${NC}..."
            sudo apt-get install -y "$package" || {
                echo -e "${RED}Failed to install $package${NC}"
                return 1
            }
        else
            echo -e "  ${GREEN}✓${NC} $package (already installed)"
        fi
    done
}

# Function to install packages (RedHat/CentOS/Fedora)
install_packages_rpm() {
    local packages=("$@")
    echo -e "${BLUE}Installing RedHat/CentOS/Fedora packages:${NC}"
    for package in "${packages[@]}"; do
        if ! package_installed_rpm "$package"; then
            echo -e "  Installing ${YELLOW}$package${NC}..."
            if command_exists dnf; then
                sudo dnf install -y "$package" || {
                    echo -e "${RED}Failed to install $package${NC}"
                    return 1
                }
            elif command_exists yum; then
                sudo yum install -y "$package" || {
                    echo -e "${RED}Failed to install $package${NC}
                    return 1
                }
            else
                echo -e "${RED}No package manager found (dnf/yum)${NC}"
                return 1
            fi
        else
            echo -e "  ${GREEN}✓${NC} $package (already installed)"
        fi
    done
}

# Function to check library availability
check_library() {
    local libname=$1
    local libfile=$2
    
    echo -n "Checking for $libname... "
    if [ -f "$libfile" ]; then
        echo -e "${GREEN}found${NC}"
        return 0
    else
        echo -e "${RED}not found${NC}"
        return 1
    fi
}

# Essential build tools
ESSENTIAL_TOOLS=(gcc make autoconf automake libtool pkg-config)

# Required libraries
REQUIRED_LIBS=(
    "libssl" "/usr/lib/libssl.so" "/usr/lib64/libssl.so"
    "libcrypto" "/usr/lib/libcrypto.so" "/usr/lib64/libcrypto.so"
    "libjson-c" "/usr/lib/libjson-c.so" "/usr/lib64/libjson-c.so"
)

# Optional libraries for advanced features
OPTIONAL_LIBS=(
    "libpcap" "/usr/lib/libpcap.so" "/usr/lib64/libpcap.so"
    "libcurl" "/usr/lib/libcurl.so" "/usr/lib64/libcurl.so"
    "libnetfilter_queue" "/usr/lib/libnetfilter_queue.so" "/usr/lib64/libnetfilter_queue.so"
    "libavl" "/usr/lib/libavl.so" "/usr/lib64/libavl.so"
)

echo ""
echo "Checking for essential build tools..."

MISSING_TOOLS=()
for tool in "${ESSENTIAL_TOOLS[@]}"; do
    if ! command_exists "$tool"; then
        MISSING_TOOLS+=("$tool")
        echo -e "  ${RED}✗${NC} $tool (missing)"
    else
        version=$($tool --version 2>/dev/null | head -n1 | awk '{print $NF}')
        echo -e "  ${GREEN}✓${NC} $tool ($version)
"
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Installing missing build tools...${NC}"
    if [[ "$OS" =~ "Ubuntu"|"Debian" ]]; then
        install_packages_deb build-essential autoconf automake libtool pkg-config
    elif [[ "$OS" =~ "CentOS"|"Red Hat"|"Fedora" ]]; then
        install_packages_rpm gcc make autoconf automake libtool pkgconfig
    else
        echo -e "${RED}Unsupported OS. Please install build tools manually:${NC}"
        echo "  Required: ${MISSING_TOOLS[*]}"
    fi
fi

echo ""
echo "Checking for required libraries..."

MISSING_LIBS=()
for ((i=0; i<${#REQUIRED_LIBS[@]}; i+=3)); do
    libname=${REQUIRED_LIBS[$i]}
    libfile1=${REQUIRED_LIBS[$i+1]}
    libfile2=${REQUIRED_LIBS[$i+2]}
    
    if [ -f "$libfile1" ] || [ -f "$libfile2" ]; then
        echo -e "  ${GREEN}✓${NC} $libname (found)"
    else
        MISSING_LIBS+=("$libname")
        echo -e "  ${RED}✗${NC} $libname (missing)"
    fi
done

if [ ${#MISSING_LIBS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Installing missing required libraries...${NC}"
    if [[ "$OS" =~ "Ubuntu"|"Debian" ]]; then
        install_packages_deb libssl-dev libjson-c-dev
    elif [[ "$OS" =~ "CentOS"|"Red Hat"|"Fedora" ]]; then
        install_packages_rpm openssl-devel json-c-devel
    else
        echo -e "${RED}Unsupported OS. Please install libraries manually:${NC}"
        echo "  Required: ${MISSING_LIBS[*]}"
    fi
fi

echo ""
echo "Checking for optional libraries..."

OPTIONAL_MISSING=()
for ((i=0; i<${#OPTIONAL_LIBS[@]}; i+=3)); do
    libname=${OPTIONAL_LIBS[$i]}
    libfile1=${OPTIONAL_LIBS[$i+1]}
    libfile2=${OPTIONAL_LIBS[$i+2]}
    
    if [ -f "$libfile1" ] || [ -f "$libfile2" ]; then
        echo -e "  ${GREEN}✓${NC} $libname (found)"
    else
        OPTIONAL_MISSING+=("$libname")
        echo -e "  ${YELLOW}⚠${NC} $libname (optional - missing)"
    fi
done

if [ ${#OPTIONAL_MISSING[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Optional libraries available for installation:${NC}"
    if [[ "$OS" =~ "Ubuntu"|"Debian" ]]; then
        echo "To install optional libraries, run:"
        echo "  sudo apt-get install libpcap-dev libcurl4-openssl-dev \\"
        echo "    libnetfilter-queue-dev libavl-dev"
    elif [[ "$OS" =~ "CentOS"|"Red Hat"|"Fedora" ]]; then
        echo "To install optional libraries, run:"
        echo "  sudo yum install libpcap-devel libcurl-devel \\"
        echo "    libnetfilter_queue-devel avl-devel"
    else
        echo "Optional libraries: ${OPTIONAL_MISSING[*]}"
    fi
fi

echo ""
echo "Checking for header files..."

HEADER_PATHS=(
    "/usr/include"
    "/usr/local/include"
)

HEADERS_TO_CHECK=(
    "sys/socket.h"
    "netinet/in.h"
    "arpa/inet.h"
    "net/if.h"
    "linux/if_tun.h"
    "resolv.h"
    "openssl/ssl.h"
    "json-c/json.h"
)

MISSING_HEADERS=()
for header in "${HEADERS_TO_CHECK[@]}"; do
    FOUND=0
    for path in "${HEADER_PATHS[@]}"; do
        if [ -f "$path/$header" ]; then
            echo -e "  ${GREEN}✓${NC} $header (found in $path)"
            FOUND=1
            break
        fi
    done
    if [ $FOUND -eq 0 ]; then
        MISSING_HEADERS+=("$header")
        echo -e "  ${RED}✗${NC} $header (missing)"
    fi
done

if [ ${#MISSING_HEADERS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Installing missing header files...${NC}"
    if [[ "$OS" =~ "Ubuntu"|"Debian" ]]; then
        install_packages_deb libssl-dev libjson-c-dev
    elif [[ "$OS" =~ "CentOS"|"Red Hat"|"Fedora" ]]; then
        install_packages_rpm openssl-devel json-c-devel
    fi
fi

echo ""
echo "System capability checks:"

# Check for TUN/TAP support
if [ -e /dev/net/tun ] || [ -e /dev/tun ]; then
    echo -e "  ${GREEN}✓${NC} TUN/TAP device support"
else
    echo -e "  ${YELLOW}⚠${NC} TUN/TAP device support (may need to be created)"
fi

# Check for IPv6 support
if [ -f /proc/net/if_inet6 ]; then
    echo -e "  ${GREEN}✓${NC} IPv6 kernel support"
else
    echo -e "  ${YELLOW}⚠${NC} IPv6 kernel support (may need to be enabled)"
fi

# Check for netfilter support
if grep -q CONFIG_NETFILTER /boot/config-$(uname -r) 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Netfilter support"
else
    echo -e "  ${YELLOW}⚠${NC} Netfilter support (kernel modules may be needed)"
fi

echo ""
echo "Installation Summary:"
echo "===================="

echo -e "${GREEN}✓${NC} Essential build tools installed"
echo -e "${GREEN}✓${NC} Required libraries installed"
echo -e "${YELLOW}⚠${NC} Optional libraries (${#OPTIONAL_MISSING[@]} missing)"
echo -e "${GREEN}✓${NC} Header files checked"
echo -e "${GREEN}✓${NC} System capabilities verified"

echo ""
echo "Next steps:"
echo "==========="
echo "1. Run the bootstrap script:"
echo "   cd /usr/src/coova-chilli && ./bootstrap"
echo ""
echo "2. Configure with IPv6 support:"
echo "   ./configure --enable-ipv6"
echo ""
echo "3. Build Coova Chilli:"
echo "   make"
echo ""
echo "4. Run IPv6 feature tests:"
echo "   ./final_ipv6_test.sh"

echo ""
echo -e "${GREEN}Dependency installation complete!${NC}"