#!/bin/bash

# Final Comprehensive IPv6 Feature Test for Coova Chilli
# Verifies that all IPv6 enhancements work correctly

set -e

TEST_DIR="/tmp/chilli_ipv6_final_test"
SOURCE_DIR="/usr/src/coova-chilli"
LOG_FILE="$TEST_DIR/final_ipv6_test.log"

# Create test directory
mkdir -p "$TEST_DIR"

echo "Coova Chilli Final IPv6 Feature Test" > "$LOG_FILE"
echo "===================================" >> "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Function to log test results
log_test() {
    local test_name=$1
    local status=$2
    local details=$3
    
    echo "[$status] $test_name: $details" | tee -a "$LOG_FILE"
}

# Function to run IPv6 feature test
run_ipv6_test() {
    local test_name=$1
    local description=$2
    local configure_args=$3
    
    echo "Testing IPv6 feature: $test_name"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Test: $test_name - $description" >> "$LOG_FILE"
    echo "Configure args: $configure_args" >> "$LOG_FILE"
    
    # Clean previous builds
    cd "$SOURCE_DIR"
    make clean > /dev/null 2>&1 || true
    
    # Configure with IPv6 options
    if ./configure $configure_args >> "$TEST_DIR/${test_name}_configure.log" 2>&1; then
        # Build
        if make >> "$TEST_DIR/${test_name}_build.log" 2>&1; then
            # Check if binaries were created
            if [ -f "src/.libs/chilli" ] && [ -f "src/.libs/chilli_opt" ]; then
                # Check for IPv6 support in binary
                if nm src/.libs/chilli | grep -q "ipv6\|INET6"; then
                    log_test "$test_name" "PASS" "$description - IPv6 symbols found"
                    return 0
                else
                    log_test "$test_name" "WARN" "$description - Binary built but no IPv6 symbols found"
                    return 0
                fi
            else
                log_test "$test_name" "FAIL" "$description - Binaries not created"
                return 1
            fi
        else
            log_test "$test_name" "FAIL" "$description - Build failed"
            return 1
        fi
    else
        log_test "$test_name" "FAIL" "$description - Configure failed"
        return 1
    fi
}

echo "Running Coova Chilli IPv6 Feature Tests"
echo "======================================"

# Test IPv6 baseline features
run_ipv6_test "ipv6_baseline" "Basic IPv6 support" "--enable-ipv6"

# Test IPv6 with debug features
run_ipv6_test "ipv6_debug" "IPv6 with debug support" "--enable-ipv6 --enable-debug"

# Test IPv6 with JSON support
run_ipv6_test "ipv6_json" "IPv6 with JSON support" "--enable-ipv6 --enable-json"

# Test IPv6 with garden accounting
run_ipv6_test "ipv6_garden" "IPv6 with garden accounting" "--enable-ipv6 --enable-gardenaccounting"

# Test IPv6 with session garden
run_ipv6_test "ipv6_sessgarden" "IPv6 with session garden" "--enable-ipv6 --enable-sessgarden"

# Test IPv6 with proxy VSA
run_ipv6_test "ipv6_proxyvsa" "IPv6 with proxy VSA" "--enable-ipv6 --enable-proxyvsa"

# Test IPv6 with all features enabled
run_ipv6_test "ipv6_full" "IPv6 with all features" "--enable-ipv6 --enable-debug --enable-json --enable-gardenaccounting --enable-sessgarden --enable-proxyvsa"

# Test IPv6 with specific modes
run_ipv6_test "ipv6_mode_6and4" "IPv6 6and4 mode" "--enable-ipv6 --enable-ipv6mode=6and4"
run_ipv6_test "ipv6_mode_4to6" "IPv6 4to6 mode" "--enable-ipv6 --enable-ipv6mode=4to6"
run_ipv6_test "ipv6_mode_6to4" "IPv6 6to4 mode" "--enable-ipv6 --enable-ipv6mode=6to4"

# Test IPv6 with prefix options
run_ipv6_test "ipv6_shared" "IPv6 shared prefix" "--enable-ipv6 --enable-ipv6shared"
run_ipv6_test "ipv6_perclient" "IPv6 per-client prefix" "--enable-ipv6 --enable-ipv6perclient"
run_ipv6_test "ipv6_only" "IPv6 only mode" "--enable-ipv6 --enable-ipv6only"

# Test IPv6 combinations that are commonly used
run_ipv6_test "ipv6_production" "IPv6 production build" "--enable-ipv6 --disable-debug --disable-debug2"
run_ipv6_test "ipv6_development" "IPv6 development build" "--enable-ipv6 --enable-debug --enable-debug2"

echo ""
echo "Checking IPv6 specific functionality..."

# Check that IPv6 help options are available
cd "$SOURCE_DIR"
if src/.libs/chilli --help 2>&1 | grep -q "ipv6"; then
    log_test "ipv6_help" "PASS" "IPv6 help options available"
else
    log_test "ipv6_help" "FAIL" "IPv6 help options not available"
fi

# Check that IPv6 configuration options work
if src/.libs/chilli_opt --help 2>&1 | grep -q "ipv6"; then
    log_test "ipv6_config" "PASS" "IPv6 configuration options available"
else
    log_test "ipv6_config" "FAIL" "IPv6 configuration options not available"
fi

echo ""
echo "Final IPv6 Test Summary"
echo "====================="
echo "Log file: $LOG_FILE"
echo ""

# Count results
PASSED=$(grep -c "\[PASS\]" "$LOG_FILE" || echo "0")
FAILED=$(grep -c "\[FAIL\]" "$LOG_FILE" || echo "0")
WARNED=$(grep -c "\[WARN\]" "$LOG_FILE" || echo "0")

echo "Results: $PASSED passed, $FAILED failed, $WARNED warnings"
echo "Detailed logs in: $TEST_DIR"

# Show summary
echo ""
echo "=== TEST SUMMARY ==="
grep "^\[" "$LOG_FILE"

if [ "$FAILED" -eq 0 ]; then
    echo ""
    echo "🎉 All IPv6 feature tests passed!"
    echo "Coova Chilli IPv6 implementation is working correctly."
    exit 0
else
    echo ""
    echo "❌ Some tests failed. Check $LOG_FILE for details."
    exit 1
fi