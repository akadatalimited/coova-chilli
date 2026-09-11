#!/bin/bash

# Enhanced dependency checker for Coova Chilli configure script
# This script enhances the configure output to show clear "yes/no" status for dependencies

# Function to check for a program and provide clear output
check_program_with_status() {
    local prog_name=$1
    local prog_var=$2
    local package_name=$3
    
    # Check if program exists in PATH
    if command -v "$prog_name" >/dev/null 2>&1; then
        # Get version if available
        local version=""
        if "$prog_name" --version >/dev/null 2>&1 2>&1; then
            version=$("$prog_name" --version 2>/dev/null | head -n1 | awk '{print $NF}')
        elif "$prog_name" -v >/dev/null 2>&1 2>&1; then
            version=$("$prog_name" -v 2>/dev/null | head -n1 | awk '{print $NF}')
        fi
        
        if [ -n "$version" ]; then
            echo "checking for $prog_name... yes ($version)"
        else
            echo "checking for $prog_name... yes"
        fi
        eval "$prog_var=\$(command -v $prog_name)"
        return 0
    else
        echo "checking for $prog_name... no"
        echo "  *** Missing $prog_name - please install $package_name ***"
        eval "$prog_var="
        return 1
    fi
}

# Function to check for a library and provide clear output
check_library_with_status() {
    local lib_name=$1
    local header_name=$2
    local package_name=$3
    
    # Check if header exists
    if pkg-config --exists "$lib_name" 2>/dev/null; then
        local version=$(pkg-config --modversion "$lib_name" 2>/dev/null)
        echo "checking for $lib_name library... yes ($version)"
        return 0
    else
        # Try to find header manually
        local header_paths=("/usr/include" "/usr/local/include")
        local found=0
        
        for path in "${header_paths[@]}"; do
            if [ -f "$path/$header_name" ]; then
                found=1
                break
            fi
        done
        
        if [ $found -eq 1 ]; then
            echo "checking for $lib_name library... yes (headers found)"
            return 0
        else
            echo "checking for $lib_name library... no"
            echo "  *** Missing $lib_name - please install $package_name ***"
            return 1
        fi
    fi
}

# Enhanced output for AWK check
check_program_with_status "awk" "AWK" "gawk"

# Enhanced output for C++ check
check_program_with_status "g++" "CXX" "g++"

# Enhanced output for GCC check
check_program_with_status "gcc" "CC" "gcc"

# Enhanced output for library checks
check_library_with_status "openssl" "openssl/ssl.h" "libssl-dev"

# Enhanced output for JSON library
check_library_with_status "json-c" "json-c/json.h" "libjson-c-dev"

# Enhanced output for PCAP library
check_library_with_status "libpcap" "pcap.h" "libpcap-dev"

# Enhanced output for CURL library
check_library_with_status "libcurl" "curl/curl.h" "libcurl4-openssl-dev"