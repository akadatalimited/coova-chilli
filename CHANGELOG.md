# Changelog

## [Unreleased]

### Added
- Full IPv6 support with SLAAC, DHCPv6, and ND-Proxy functionality
- Enhanced Router Advertisements with RDNSS (Recursive DNS Server) support
- Dual-stack accounting for IPv6 sessions with RADIUS
- IPv6 DNS interception and walled garden support
- IPv6 address handling in pass-through rules
- Periodic Router Advertisement sending mechanism
- Support for IPv6 prefix delegation (shared and per-client modes)

### Changed
- Updated code for modern GCC compatibility (GCC 14+)
- Replaced deprecated `bzero()` calls with `memset()`
- Enhanced Neighbor Discovery message handling
- Improved walled garden implementation to support IPv6 addresses
- Extended pass-through structure to handle both IPv4 and IPv6
- Updated garden checking functions for dual-stack support

### Fixed
- Minor compilation warnings related to packed structures
- Alignment issues in DNS packet handling
- String operation bounds checking in password handling

## [1.4] - 2015-01-20

### Added
- Initial IPv6 support (basic)
- Support for IPv6 prefix delegation
- Basic Router Advertisement functionality

### Changed
- Updated build system for better cross-platform support
- Improved error handling and logging
- Enhanced configuration file parsing

## [1.3.1] - 2014-06-09

### Added
- Support for latest OpenSSL versions
- Enhanced JSON support for status reporting
- Improved multi-language support

### Fixed
- Security vulnerabilities in HTTP handling
- Memory leaks in session management
- Issues with RADIUS attribute processing

## [1.3.0] - 2013-11-15

### Added
- Support for EAP-TTLS and PEAP authentication
- Enhanced accounting with interim updates
- Support for multiple RADIUS servers with failover
- Improved session management with keep-alive support

### Changed
- Major refactoring of the codebase for better maintainability
- Updated build system with improved autotools support
- Enhanced documentation and examples

### Fixed
- Numerous bug fixes in DHCP and RADIUS handling
- Issues with VLAN support
- Problems with concurrent session handling

## [1.2.9] - 2013-03-15

### Added
- Support for WISPr 2.0 standard
- Enhanced captive portal detection for mobile devices
- Support for voucher-based authentication
- Improved logging and debugging capabilities

### Changed
- Updated web interface with responsive design
- Enhanced security with improved session handling
- Better integration with FreeRADIUS

### Fixed
- Issues with IPv6 prefix delegation
- Problems with MAC authentication
- Various stability improvements

## [1.2.8] - 2012-09-20

### Added
- Support for EAP methods (EAP-MD5, EAP-GTC)
- Enhanced UAM (User Access Manager) functionality
- Support for multiple SSIDs and VLANs
- Improved bandwidth shaping capabilities

### Changed
- Updated documentation and installation guides
- Enhanced configuration file handling
- Better support for embedded systems

### Fixed
- Security vulnerabilities in web interface
- Issues with session timeouts
- Problems with concurrent user handling

## [1.2.7] - 2012-03-10

### Added
- Support for IEEE 802.1X authentication
- Enhanced logging with syslog support
- Support for custom RADIUS attributes
- Improved session accounting

### Changed
- Updated build system for better cross-compilation support
- Enhanced web interface with AJAX functionality
- Better integration with external authentication systems

### Fixed
- Issues with DHCP relay functionality
- Problems with MAC filtering
- Various memory management improvements

## [1.2.6] - 2011-11-15

### Added
- Support for WISPr (Wireless ISP Roaming) standard
- Enhanced captive portal with customizable templates
- Support for multiple languages
- Improved voucher system

### Changed
- Updated authentication mechanisms
- Enhanced security with improved encryption
- Better support for mobile device detection

### Fixed
- Issues with concurrent session handling
- Problems with bandwidth limiting
- Various stability improvements

## [1.2.5] - 2011-06-20

### Added
- Support for HTTPS redirection
- Enhanced logging capabilities
- Support for custom JavaScript in web interface

### Changed
- Improved performance with optimized packet processing
- Enhanced configuration file handling
- Better error reporting and recovery

### Fixed
- Security vulnerabilities in web interface
- Issues with session management
- Problems with DHCP server functionality

## [1.2.4] - 2011-02-10

### Added
- Support for voucher-based authentication
- Enhanced accounting with detailed session statistics
- Support for custom RADIUS attributes

### Changed
- Updated web interface with improved usability
- Enhanced security with stronger authentication
- Better integration with external databases

### Fixed
- Issues with concurrent user sessions
- Problems with bandwidth shaping
- Various stability improvements

## [1.2.3] - 2010-10-15

### Added
- Support for MAC authentication
- Enhanced logging with detailed session tracking
- Support for custom splash pages

### Changed
- Improved performance with optimized memory usage
- Enhanced security with improved encryption algorithms
- Better support for high-traffic environments

### Fixed
- Issues with DHCP lease management
- Problems with RADIUS server communication
- Various bug fixes and stability improvements