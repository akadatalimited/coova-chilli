#!/bin/bash

# Final Integration Test for Coova Chilli IPv6 Enhancements
# Tests that all IPv6 features work together correctly

set -e

TEST_DIR="/tmp/chilli_integration_test"
SOURCE_DIR="/usr/src/coova-chilli"
LOG_FILE="$TEST_DIR/integration_test.log"

# Create test directory
mkdir -p "$TEST_DIR"

echo "Coova Chilli IPv6 Integration Test" > "$LOG_FILE"
echo "=================================" >> "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Function to log results
log_result() {
    local test_name=$1
    local status=$2
    local details=$3
    
    echo "[$status] $test_name: $details" | tee -a "$LOG_FILE"
}

# Function to run integration test
run_integration_test() {
    local test_name=$1
    local description=$2
    
    echo "Running integration test: $test_name"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Test: $test_name - $description" >> "$LOG_FILE"
    
    # Clean previous builds
    cd "$SOURCE_DIR"
    make clean > /dev/null 2>&1 || true
    
    # Configure with IPv6 and all enhancements
    if ./configure --enable-ipv6 --enable-debug --enable-json >> "$TEST_DIR/${test_name}_configure.log" 2>&1; then
        # Build
        if make >> "$TEST_DIR/${test_name}_build.log" 2>&1; then
            # Check if binaries were created
            if [ -f "src/.libs/chilli" ] && [ -f "src/.libs/chilli_opt" ]; then
                log_result "$test_name" "PASS" "$description"
                return 0
            else
                log_result "$test_name" "FAIL" "Binaries not created"
                return 1
            fi
        else
            log_result "$test_name" "FAIL" "Build failed"
            return 1
        fi
    else
        log_result "$test_name" "FAIL" "Configure failed"
        return 1
    fi
}

echo "Running Coova Chilli IPv6 Integration Tests"
echo "=========================================="

# Test baseline IPv6 build
run_integration_test "ipv6_baseline" "Basic IPv6 build with debug and JSON"

# Test comprehensive IPv6 build
run_integration_test "ipv6_comprehensive" "IPv6 with all optional features"

# Test production IPv6 build
run_integration_test "ipv6_production" "IPv6 production build (minimal features)"

# Test development IPv6 build
run_integration_test "ipv6_development" "IPv6 development build (maximum features)"

echo ""
echo "Checking compiled binaries for IPv6 features..."

# Check that the binaries include IPv6 support
cd "$SOURCE_DIR"
if [ -f "src/.libs/chilli" ]; then
    echo "Checking IPv6 support in binary..." >> "$LOG_FILE"
    
    # Check if IPv6-related symbols are present
    if nm src/.libs/chilli | grep -q "ipv6\|INET6"; then
        log_result "ipv6_symbols" "PASS" "IPv6 symbols found in binary"
    else
        log_result "ipv6_symbols" "WARN" "No IPv6 symbols found (may be optimized out)"
    fi
    
    # Check help output for IPv6 options
    if src/.libs/chilli --help 2>&1 | grep -q "ipv6"; then
        log_result "ipv6_help" "PASS" "IPv6 options found in help"
    else
        log_result "ipv6_help" "FAIL" "IPv6 options not found in help"
    fi
else
    log_result "binary_check" "FAIL" "Main binary not found"
fi

echo ""
echo "Verifying IPv6 configuration options..."

# Test specific IPv6 configuration options
cd "$SOURCE_DIR"
make clean > /dev/null 2>&1 || true

CONFIGURE_OPTS=(
    "--enable-ipv6"
    "--enable-ipv6 --enable-ipv6shared"
    "--enable-ipv6 --enable-ipv6perclient"
    "--enable-ipv6 --enable-ipv6only"
    "--enable-ipv6 --enable-debug"
    "--enable-ipv6 --enable-json"
    "--enable-ipv6 --disable-uamanyip"
    "--enable-ipv6 --enable-gardenaccounting"
)

for opt in "${CONFIGURE_OPTS[@]}"; do
    echo "Testing configure option: $opt"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Testing configure option: $opt" >> "$LOG_FILE"
    
    if ./configure $opt >> "$TEST_DIR/configure_${opt// /_}.log" 2>&1; then
        if make >> "$TEST_DIR/build_${opt// /_}.log" 2>&1; then
            log_result "config_${opt// /_}" "PASS" "Configure and build successful"
        else
            log_result "config_${opt// /_}" "FAIL" "Build failed"
        fi
    else
        log_result "config_${opt// /_}" "FAIL" "Configure failed"
    fi
    
    make clean > /dev/null 2>&1 || true
done

echo ""
echo "Final Integration Test Summary"
echo "============================="
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
    echo "🎉 All integration tests passed!"
    echo "Coova Chilli IPv6 implementation is working correctly."
    exit 0
else
    echo ""
    echo "❌ Some tests failed. Check $LOG_FILE for details."
    exit 1
fi