#!/bin/bash

# Focused Configure Options Test Suite for Coova Chilli
# Tests key configure options to verify compatibility

set -e

TEST_DIR="/tmp/chilli_config_tests"
SOURCE_DIR="/usr/src/coova-chilli"
RESULTS_FILE="$TEST_DIR/results_summary.txt"

# Create test directory
mkdir -p "$TEST_DIR"

# Initialize results file
echo "Coova Chilli Configure Options Test Results" > "$RESULTS_FILE"
echo "Date: $(date)" >> "$RESULTS_FILE"
echo "===========================================" >> "$RESULTS_FILE"

# Function to log results
log_result() {
    local test_name=$1
    local status=$2
    local duration=$3
    local notes=$4
    
    printf "%-30s %-12s %-10s %s\n" "$test_name" "$status" "${duration}s" "$notes" | tee -a "$RESULTS_FILE"
}

# Function to run a test
run_test() {
    local test_name=$1
    local configure_args=$2
    local expected_features=$3
    
    echo "Running test: $test_name"
    
    local start_time=$(date +%s)
    
    # Clean previous builds
    cd "$SOURCE_DIR"
    make clean > /dev/null 2>&1 || true
    
    # Run configure
    if ./configure $configure_args > "$TEST_DIR/${test_name}_configure.log" 2>&1; then
        # Try to build
        if make > "$TEST_DIR/${test_name}_build.log" 2>&1; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log_result "$test_name" "PASS" "$duration" "$expected_features"
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log_result "$test_name" "BUILD_FAIL" "$duration" "Configure passed, build failed"
            return 1
        fi
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_result "$test_name" "CONFIG_FAIL" "$duration" "Configure failed"
        return 1
    fi
}

echo "Coova Chilli Focused Configure Options Test Suite"
echo "================================================"
printf "%-30s %-12s %-10s %s\n" "Test Name" "Status" "Duration" "Notes"
echo "------------------------------------------------------------" | tee -a "$RESULTS_FILE"

# Test basic configuration first
run_test "baseline" "" "Basic build"

# Test IPv6 related options
run_test "ipv6_enabled" "--enable-ipv6" "IPv6 support enabled"
run_test "ipv6_disabled" "--disable-ipv6" "IPv6 support disabled"

# Test debug options
run_test "debug_enabled" "--enable-debug" "Debug messages enabled"
run_test "debug2_enabled" "--enable-debug2" "Verbose debugging enabled"

# Test major feature toggles
run_test "chilliquery_disabled" "--disable-chilliquery" "chilli_query disabled"
run_test "tap_disabled" "--disable-tap" "TAP support disabled (TUN only)"
run_test "radproxy_disabled" "--disable-radproxy" "RADIUS proxy disabled"
run_test "coa_disabled" "--disable-coa" "CoA support disabled"

# Test accounting features
run_test "accounting_onoff_disabled" "--disable-accounting-onoff" "Accounting On/Off disabled"
run_test "gardenaccounting_enabled" "--enable-gardenaccounting" "Walled garden accounting enabled"

# Test web/UI features
run_test "uamanyip_disabled" "--disable-uamanyip" "UAM any IP disabled"
run_test "uamuiport_disabled" "--disable-uamuiport" "UAM UI port disabled"
run_test "json_enabled" "--enable-json" "JSON support enabled"
run_test "chillixml_enabled" "--enable-chillixml" "Chilli XML enabled"

# Test advanced features
run_test "sessgarden_enabled" "--enable-sessgarden" "Session-based garden enabled"
run_test "sessproxy_enabled" "--enable-sessproxy" "Session proxy enabled"
run_test "proxyvsa_enabled" "--enable-proxyvsa" "Proxy VSA enabled"
run_test "cluster_enabled" "--enable-cluster" "Clustering enabled"

# Test protocol features
run_test "dhcpopt_enabled" "--enable-dhcpopt" "DHCP options enabled"
run_test "eapol_enabled" "--enable-eapol" "EAPOL enabled"
run_test "ieee8021q_disabled" "--disable-ieee8021q" "IEEE 802.1Q disabled"

# Test combination options that are commonly used together
run_test "production_minimal" "--disable-debug --disable-debug2 --enable-ipv6" "Production build"
run_test "development_full" "--enable-debug --enable-debug2 --enable-ipv6 --enable-json" "Development build"

# Test library integration
run_test "with_openssl" "--with-openssl" "OpenSSL support"
run_test "with_pcap" "--with-pcap" "PCAP support"

echo "------------------------------------------------------------" | tee -a "$RESULTS_FILE"
echo "Test suite completed!" | tee -a "$RESULTS_FILE"

# Count results
PASSED=$(grep -c "PASS" "$RESULTS_FILE" || echo "0")
FAILED=$(grep -c "FAIL" "$RESULTS_FILE" || echo "0")

echo "Summary: $PASSED passed, $FAILED failed" | tee -a "$RESULTS_FILE"

# Show failed tests if any
if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo "Failed tests:"
    grep "FAIL" "$RESULTS_FILE"
fi

echo ""
echo "Detailed logs available in: $TEST_DIR"
echo "Summary results in: $RESULTS_FILE"