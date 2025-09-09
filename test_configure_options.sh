#!/bin/bash

# Coova Chilli Configure Options Test Suite
# This script tests all configure options to verify compatibility and dependencies

TEST_DIR="/tmp/chilli_test"
SOURCE_DIR="/usr/src/coova-chilli"
LOG_FILE="$TEST_DIR/test_results.log"
MATRIX_FILE="$TEST_DIR/compatibility_matrix.csv"

# Create test directory
mkdir -p "$TEST_DIR"

# Initialize log and matrix files
echo "Coova Chilli Configure Options Test Results" > "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# Create CSV header for compatibility matrix
echo "Option,Status,Dependencies,Notes" > "$MATRIX_FILE"

# Function to log results
log_result() {
    local option=$1
    local status=$2
    local deps=$3
    local notes=$4
    
    echo "[$status] $option - $notes" >> "$LOG_FILE"
    echo "\"$option\",$status,\"$deps\",\"$notes\"" >> "$MATRIX_FILE"
}

# Function to test a configure option
test_configure_option() {
    local option=$1
    local description=$2
    local dependencies=$3
    
    echo "Testing: $option ($description)"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Testing: $option ($description)" >> "$LOG_FILE"
    
    # Clean previous builds
    cd "$SOURCE_DIR" && make clean > /dev/null 2>&1
    
    # Test configure with option
    if ./configure "$option" >> "$LOG_FILE" 2>&1; then
        # Try to build
        if make >> "$LOG_FILE" 2>&1; then
            log_result "$option" "PASS" "$dependencies" "Configure and build successful"
            echo "  [PASS]"
            return 0
        else
            log_result "$option" "BUILD_FAIL" "$dependencies" "Configure succeeded but build failed"
            echo "  [BUILD_FAIL]"
            return 1
        fi
    else
        log_result "$option" "CONFIG_FAIL" "$dependencies" "Configure failed"
        echo "  [CONFIG_FAIL]"
        return 1
    fi
}

# Function to test package dependencies
test_package_dependency() {
    local package=$1
    local pkg_manager_cmd=$2
    
    echo "Testing dependency: $package"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Testing dependency: $package" >> "$LOG_FILE"
    
    # Test if package manager command exists
    if command -v $pkg_manager_cmd > /dev/null 2>&1; then
        log_result "dependency_$package" "AVAILABLE" "" "Package manager available"
        echo "  [AVAILABLE]"
        return 0
    else
        log_result "dependency_$package" "MISSING" "" "Package manager not available"
        echo "  [MISSING]"
        return 1
    fi
}

echo "Starting Coova Chilli Configure Options Test Suite"
echo "=================================================="

# Test basic configure and build first
echo "Testing baseline configure and build..."
cd "$SOURCE_DIR" && make clean > /dev/null 2>&1
if ./configure >> "$LOG_FILE" 2>&1 && make >> "$LOG_FILE" 2>&1; then
    log_result "baseline" "PASS" "" "Basic configure and build successful"
    echo "[PASS] Baseline test"
else
    log_result "baseline" "FAIL" "" "Basic configure and build failed"
    echo "[FAIL] Baseline test - stopping further tests"
    exit 1
fi

# Test all disable options
echo -e "\nTesting disable options:"
test_configure_option "--disable-chilliquery" "Disable chilli_query" ""
test_configure_option "--disable-leakybucket" "disable use of leaky bucket shaping" ""
test_configure_option "--disable-uamanyip" "disable use of uamanyip" ""
test_configure_option "--disable-uamuiport" "disable use of uamuiport" ""
test_configure_option "--disable-accounting-onoff" "disable use of Accounting-On and Accounting-Off" ""
test_configure_option "--disable-tap" "Disable support for tap interface (tun only)" ""
test_configure_option "--disable-tcpreset" "Disable support for TCP reset of filtered connections" ""
test_configure_option "--disable-radproxy" "Disable support RADIUS (EAP) Proxy" ""
test_configure_option "--disable-debug" "Disable debugging messages" ""
test_configure_option "--disable-dhcpradius" "Disable support DHCP/RADIUS integration" ""
test_configure_option "--disable-coa" "Disable CoA RADIUS support" ""
test_configure_option "--disable-ieee8021q" "disable support for IEEE 802.1Q" ""
test_configure_option "--disable-coovachilliconfig" "Disable the use of the CoovaChilli-Config attribute" ""

# Test all enable options
echo -e "\nTesting enable options:"
test_configure_option "--enable-json" "Enable support for JSON" "json-c library"
test_configure_option "--enable-wpad" "Enable support WPAD" ""
test_configure_option "--enable-gardenaccounting" "Enable walled garden accounting" ""
test_configure_option "--enable-gardenext" "Enable extended walled garden features" ""
test_configure_option "--enable-inspect" "Enable inspect feature in cmdsock" ""
test_configure_option "--enable-debug2" "Enable verbose debugging" ""
test_configure_option "--enable-sessgarden" "Enable support for session-based walled garden" ""
test_configure_option "--enable-sessproxy" "Enable support for per session postauth proxy" ""
test_configure_option "--enable-sessdhcp" "Enable support for per session DHCP relay" ""
test_configure_option "--enable-sessdns" "Enable support for per session DNS enforcement" ""
test_configure_option "--enable-chillixml" "Enable use of chillixml" ""
test_configure_option "--enable-proxyvsa" "Enable support for VSA attribute proxy" ""
test_configure_option "--enable-ipwhitelist" "Enable file based IP white list" ""
test_configure_option "--enable-uamdomainfile" "Enable loading of mass uamdomains from file" ""
test_configure_option "--enable-redirdnsreq" "Enable the sending of a DNS query on redirect" ""
test_configure_option "--enable-largelimits" "Enable larger limits for use with non-embedded systems" ""
test_configure_option "--enable-authedallowed" "enable Authurized Garden" ""
test_configure_option "--enable-binstatusfile" "Enable support for binary status file" ""
test_configure_option "--enable-statusfile" "Enable support for status file" ""
test_configure_option "--enable-chilliproxy" "Enable support for HTTP AAA Proxy" ""
test_configure_option "--enable-multiroute" "Enable support for multiple routes" ""
test_configure_option "--enable-multilan" "Enable support for multiple LANs" ""
test_configure_option "--enable-chilliradsec" "Enable support for RadSec AAA Proxy" ""
test_configure_option "--enable-chilliredir" "Enable support for Redir server" ""
test_configure_option "--enable-chilliscript" "Enable support for chilli_script helper" ""
test_configure_option "--enable-cluster" "Enable support for clustering" ""
test_configure_option "--enable-sessionstate" "Enable extended use of the CoovaChilli-Session-State attribute" ""
test_configure_option "--enable-sessionid" "Enable the use of the CoovaChilli-Session-Id attribute" ""
test_configure_option "--enable-apsessionid" "Enable the use of the CoovaChilli-AP-Session-Id attribute" ""
test_configure_option "--enable-mdns" "Enable support for MDNS" ""
test_configure_option "--enable-netbios" "Enable support for NetBIOS" ""
test_configure_option "--enable-ieee8023" "Enable support for IEEE 802.3 Ethernet" ""
test_configure_option "--enable-pppoe" "Enable support for PPPoE" ""
test_configure_option "--enable-l2tpppp" "Enable support for L2TP/PPP Tunneling" ""
test_configure_option "--enable-eapol" "Enable support for EAPOL" ""
test_configure_option "--enable-miniportal" "Enable support Coova miniportal" ""
test_configure_option "--enable-miniconfig" "Enable support minimal cmdline config" ""
test_configure_option "--enable-ewtapi" "Enable support for CoovaEWT API" ""
test_configure_option "--enable-libjson" "Enable support for libjson" ""
test_configure_option "--enable-ssdp" "Enable support for Simple Service Discovery Protocol" ""
test_configure_option "--enable-layer3" "Enable support for Layer3 only operation" ""
test_configure_option "--enable-modules" "Enable dynamically loadable modules (experimental)" ""
test_configure_option "--enable-extadmvsa" "Enable admin-user VSA attribute support" ""
test_configure_option "--enable-redirinject" "Enable Redir content-injection support" ""
test_configure_option "--enable-netnat" "Enable net interface nat (experimental)" ""
test_configure_option "--enable-useragent" "Enable recording user-agent" ""
test_configure_option "--enable-acceptlanguage" "Enable recording Accept-Language" ""
test_configure_option "--enable-location" "Enable Location Awareness" ""
test_configure_option "--enable-forcedns" "Enable the forcing (NAT) of DNS" ""

# Test with-options
echo -e "\nTesting with-options:"
test_configure_option "--with-openssl" "enable support for openssl" "libssl-dev openssl"
test_configure_option "--with-matrixssl" "enable support for matrixssl" "matrixssl-dev"
test_configure_option "--with-cyassl" "enable support for cyassl" "cyassl-dev"
test_configure_option "--with-nfqueue" "enable support for netfilter_queue" "libnetfilter-queue-dev"
test_configure_option "--with-avl" "enable support for avl library" "libavl-dev"
test_configure_option "--with-nfcoova" "enable support for coova netfilter module" ""
test_configure_option "--without-sfhash" "disable SuperFastHash use" ""
test_configure_option "--with-lookup3" "enable Jenkins lookup3 use" ""
test_configure_option "--with-patricia" "enable Patricia use" ""
test_configure_option "--without-ipv6" "enable IPv6" ""
test_configure_option "--with-pcap" "enable support for pcap" "libpcap-dev"
test_configure_option "--with-curl" "enable support for curl" "libcurl4-openssl-dev"
test_configure_option "--with-mmap" "enable support for mmap" ""
test_configure_option "--with-poll" "enable support for poll" ""
test_configure_option "--with-ipc-msg" "enable support for msgsnd/msgrcv SV IPC" ""

# Test dependency availability
echo -e "\nTesting package dependencies:"
test_package_dependency "openssl" "openssl"
test_package_dependency "libssl" "gcc"
test_package_dependency "libjson" "json-c"
test_package_dependency "libpcap" "pcap-config"
test_package_dependency "libcurl" "curl-config"
test_package_dependency "libnetfilter_queue" "pkg-config"
test_package_dependency "libavl" "pkg-config"

# Test combination options
echo -e "\nTesting combination options:"
echo "Testing IPv6 combinations..." >> "$LOG_FILE"
test_configure_option "--enable-ipv6 --enable-debug" "IPv6 with debug" ""
test_configure_option "--enable-ipv6 --disable-tap" "IPv6 without TAP" ""
test_configure_option "--enable-ipv6 --enable-json" "IPv6 with JSON" "json-c library"
test_configure_option "--enable-ipv6 --enable-wpad" "IPv6 with WPAD" ""
test_configure_option "--enable-ipv6 --enable-gardenaccounting" "IPv6 with garden accounting" ""
test_configure_option "--enable-ipv6 --enable-chilliredir" "IPv6 with chilli_redir" ""

echo -e "\nTest suite completed!"
echo "Results saved to: $LOG_FILE"
echo "Compatibility matrix saved to: $MATRIX_FILE"

# Show summary
echo -e "\nSummary:"
grep "\[PASS\]" "$LOG_FILE" | wc -l | xargs echo "Passed:"
grep "\[CONFIG_FAIL\]\|\[BUILD_FAIL\]" "$LOG_FILE" | wc -l | xargs echo "Failed:"