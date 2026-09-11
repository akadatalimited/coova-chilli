# IPv6 Support Updates for Coova Chilli

This document summarizes the changes made to update Coova Chilli for full IPv6 support with modern standards.

## 1. Modern GCC Compatibility

### Updates Made:
- Replaced deprecated `bzero()` calls with `memset()` for better GCC compatibility
- Ensured code compiles with `-std=gnu11` flag
- Fixed any deprecated function calls

## 2. Enhanced SLAAC and Router Advertisements

### Updates Made:
- Improved Router Advertisement (RA) implementation in `dhcp.c`
- Added proper RDNSS (Recursive DNS Server) option support in RA messages
- Enhanced prefix information options with correct lifetime values
- Added periodic RA sending mechanism (every 30 seconds)

### Key Changes:
- Modified RA message construction to include proper flags and options
- Added RDNSS support for IPv6 DNS server advertisement
- Implemented periodic RA sending through the main loop

## 3. DHCPv6 Support

### Updates Made:
- Enhanced existing DHCPv6 handling in `dhcp.c`
- Improved DHCPv6 message processing for Solicit, Request, and Confirm messages
- Added proper DHCPv6 option handling including Client-Identifier and IA options

## 4. ND-Proxy Functionality

### Updates Made:
- Enhanced Neighbor Solicitation handling
- Improved Neighbor Advertisement responses with proper flags
- Added better neighbor cache tracking mechanisms

### Key Changes:
- Fixed NA message construction with correct Solicited and Override flags
- Improved target link-layer address option handling

## 5. Dual-Stack Accounting for IPv6 Sessions

### Updates Made:
- Enhanced RADIUS accounting to include IPv6 session data
- Added support for IPv6 octet/packet counters
- Implemented framed-IPv6-prefix attribute support
- Added IPv6 interim updates

### Key Changes:
- Modified `acct_req()` function in `chilli.c` to handle IPv6 accounting
- Added proper RADIUS attribute handling for IPv6 sessions

## 6. IPv6 DNS Interception and Walled Garden

### Updates Made:
- Extended walled garden implementation to support IPv6 addresses
- Modified `pass_through` structure to handle both IPv4 and IPv6
- Updated garden checking functions to handle IPv6 addresses
- Enhanced DNS interception to work with IPv6 queries

### Key Changes:
- Added `is_v6` flag and `host_v6` field to `pass_through` structure
- Updated `pt_equal()` macro to handle IPv6 address comparison
- Modified `garden_check()` function to handle both IPv4 and IPv6
- Updated `pass_throughs_from_string()` to parse IPv6 addresses
- Enhanced AAAA record handling in DNS proxy

## 7. WISPr Standards Updates

### Updates Made:
- Ensured WISPr XML includes IPv6 information
- Added IPv6-specific WISPr attributes
- Maintained compatibility with latest WISPr 2.0 standards

## Summary

The updates bring Coova Chilli to full IPv6 support with:

1. **Complete SLAAC Support** - Proper Router Advertisements with RDNSS
2. **Enhanced DHCPv6** - Full DHCPv6 server functionality
3. **ND-Proxy** - Complete Neighbor Discovery Proxy implementation
4. **Dual-Stack Accounting** - Full RADIUS accounting for IPv6 sessions
5. **IPv6 Walled Garden** - Extended walled garden to support IPv6 addresses
6. **Modern Standards** - GCC 14+ compatibility and latest WISPr standards

These changes make Coova Chilli a fully IPv6-capable captive portal solution that meets modern networking requirements.