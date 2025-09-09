#!/bin/bash

# IPv6 Feature Combination Tests for Coova Chilli
# Tests critical IPv6 features and their combinations

set -e

TEST_DIR="/tmp/chilli_ipv6_tests"
SOURCE_DIR="/usr/src/coova-chilli"
RESULTS_FILE="$TEST_DIR/ipv6_test_results.txt"

# Create test directory
mkdir -p "$TEST_DIR"

# Initialize results file
echo "Coova Chilli IPv6 Feature Combination Tests" > "$RESULTS_FILE"
echo "Date: $(date)" >> "$RESULTS_FILE"
echo "============================================" >> "$RESULTS_FILE"

# Function to log results
log_result() {
    local test_name=$1
    local status=$2
    local duration=$3
    local notes=$4
    
    printf "%-40s %-12s %-10s %s\n" "$test_name" "$status" "${duration}s" "$notes" | tee -a "$RESULTS_FILE"
}

# Function to run IPv6 feature test
run_ipv6_test() {
    local test_name=$1
    local configure_args=$2
    local expected_features=$3
    
    echo "Running IPv6 test: $test_name"
    
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

echo "Coova Chilli IPv6 Feature Combination Tests"
echo "==========================================="
printf "%-40s %-12s %-10s %s\n" "Test Name" "Status" "Duration" "Features Tested"
echo "--------------------------------------------------------------------------------" | tee -a "$RESULTS_FILE"

# Test IPv6 base configurations
run_ipv6_test "ipv6_basic" "--enable-ipv6" "Basic IPv6 support"
run_ipv6_test "ipv6_debug" "--enable-ipv6 --enable-debug" "IPv6 with debug"
run_ipv6_test "ipv6_json" "--enable-ipv6 --enable-json" "IPv6 with JSON support"
run_ipv6_test "ipv6_full" "--enable-ipv6 --enable-debug --enable-json --enable-chillixml" "IPv6 full feature set"

# Test IPv6 accounting combinations
run_ipv6_test "ipv6_accounting" "--enable-ipv6 --enable-gardenaccounting" "IPv6 with garden accounting"
run_ipv6_test "ipv6_accounting_debug" "--enable-ipv6 --enable-gardenaccounting --enable-debug" "IPv6 accounting with debug"

# Test IPv6 session features
run_ipv6_test "ipv6_sessions" "--enable-ipv6 --enable-sessgarden --enable-sessproxy" "IPv6 session features"
run_ipv6_test "ipv6_sessions_full" "--enable-ipv6 --enable-sessgarden --enable-sessproxy --enable-sessdhcp --enable-sessdns" "IPv6 full session features"

# Test IPv6 security combinations
run_ipv6_test "ipv6_secure" "--enable-ipv6 --disable-uamanyip --disable-tap --enable-gardenaccounting" "IPv6 secure mode"
run_ipv6_test "ipv6_hardened" "--enable-ipv6 --disable-uamanyip --disable-tap --enable-gardenaccounting --enable-proxyvsa" "IPv6 hardened mode"

# Test IPv6 with different modes
run_ipv6_test "ipv6_6and4" "--enable-ipv6 --enable-ipv6mode=6and4" "IPv6 6and4 mode"
run_ipv6_test "ipv6_4to6" "--enable-ipv6 --enable-ipv6mode=4to6" "IPv6 4to6 mode"
run_ipv6_test "ipv6_6to4" "--enable-ipv6 --enable-ipv6mode=6to4" "IPv6 6to4 mode"

# Test IPv6 with advanced features
run_ipv6_test "ipv6_advanced" "--enable-ipv6 --enable-json --enable-chillixml --enable-gardenaccounting --enable-proxyvsa" "IPv6 advanced features"

# Test IPv6 with minimal footprint
run_ipv6_test "ipv6_minimal" "--enable-ipv6 --disable-chilliquery --disable-radproxy --disable-coa --disable-debug" "IPv6 minimal build"

# Test special IPv6 combinations that should work together
run_ipv6_test "ipv6_production" "--enable-ipv6 --disable-debug --disable-debug2 --enable-gardenaccounting" "IPv6 production build"
run_ipv6_test "ipv6_enterprise" "--enable-ipv6 --enable-json --enable-chillixml --enable-gardenaccounting --enable-proxyvsa --enable-cluster" "IPv6 enterprise build"

echo "--------------------------------------------------------------------------------" | tee -a "$RESULTS_FILE"
echo "IPv6 feature combination tests completed!" | tee -a "$RESULTS_FILE"

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

# Create a summary of working IPv6 configurations
echo ""
echo "Working IPv6 Configurations:"
echo "============================="
grep "PASS" "$RESULTS_FILE" | grep -E "(ipv6_|IPv6)" | cut -d' ' -f1 | sort | uniq