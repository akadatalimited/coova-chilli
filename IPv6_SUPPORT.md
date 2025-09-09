# IPv6 Support in Coova Chilli

Coova Chilli now provides full IPv6 support with modern standards compliance.

## IPv6 Features

### 1. SLAAC Support
- Complete Router Advertisement (RA) implementation
- RDNSS (Recursive DNS Server) option support
- Prefix delegation with configurable /64 networks
- Periodic RA sending for stable IPv6 connectivity

### 2. DHCPv6 Support
- Full DHCPv6 server functionality
- IA_NA (Identity Association for Non-temporary Addresses) support
- DNS server option (RDNSS) distribution
- Proper DHCPv6 message handling (Solicit, Request, Confirm)

### 3. ND-Proxy Functionality
- Complete Neighbor Discovery Proxy implementation
- Neighbor Solicitation handling
- Neighbor Advertisement responses with proper flags
- Neighbor cache tracking per session

### 4. Dual-Stack Accounting
- Full RADIUS accounting for IPv6 sessions
- IPv6 octet/packet counters
- framed-IPv6-prefix attribute support
- IPv6 interim updates

### 5. IPv6 Walled Garden
- Extended walled garden to support IPv6 addresses and networks
- IPv6 DNS interception and handling
- AAAA record support in DNS proxy
- Dual-stack pass-through rule processing

## Configuration Options

### Basic IPv6 Enablement
```
chilli --ipv6
```

### IPv6 Prefix Configuration
```
chilli --ipv6 --ipv6prefix 2001:db8:: --ipv6perclient
```

### IPv6 Mode Selection
- `--ipv6only` - Enable IPv6-only mode
- `--ipv6to4` - Enable IPv6-to-IPv4 translation
- `--ipv4to6` - Enable IPv4-to-IPv6 translation
- `--ipv6mode` - Set IPv6 mode (6and4, 4to6, or 6to4)

### Prefix Delegation Options
- `--ipv6shared` - Share a single /64 among clients
- `--ipv6perclient` - Delegate unique /64 per client

## Building with IPv6 Support

IPv6 support is enabled by default in modern builds. To explicitly enable:

```
./configure --enable-ipv6
make
make install
```

## Runtime Requirements

For full IPv6 functionality, ensure your system has:
- IPv6 kernel support enabled
- Proper network interface configuration
- Appropriate firewall rules for IPv6 traffic
- RADIUS server with IPv6 attribute support

## Testing IPv6 Features

### Router Advertisements
Monitor network traffic to verify proper RA messages:
- Correct prefix information with valid lifetimes
- RDNSS options with DNS server addresses
- Proper flags for managed and other-config bits

### DHCPv6 Operation
Verify DHCPv6 message exchange:
- Solicit/Advertise/Request/Reply sequence
- Proper IA_NA option handling
- DNS server option distribution

### Neighbor Discovery
Check ND-Proxy functionality:
- Neighbor Solicitation proxying
- Proper Neighbor Advertisement responses
- Neighbor cache maintenance

### Accounting Verification
Monitor RADIUS accounting:
- IPv6 session start/stop messages
- Proper framed-IPv6-prefix attributes
- Octet/packet counters for IPv6 traffic

## Troubleshooting

### Common Issues

1. **RA Messages Not Received**
   - Check interface configuration
   - Verify IPv6 forwarding is enabled
   - Confirm RA daemon is not conflicting

2. **DHCPv6 Address Assignment Failures**
   - Verify prefix delegation configuration
   - Check DHCPv6 server logs
   - Ensure proper subnet configuration

3. **Neighbor Discovery Problems**
   - Monitor ND cache entries
   - Check for duplicate address detection conflicts
   - Verify MAC address learning

### Log Analysis

Enable debug logging for detailed IPv6 diagnostics:
```
chilli --debug --foreground
```

Look for IPv6-related messages in system logs:
- Router Advertisement processing
- DHCPv6 message handling
- Neighbor Discovery exchanges
- Accounting record generation

## Security Considerations

### IPv6-Specific Security
- Monitor for IPv6 tunneling bypass attempts
- Validate RA messages from unauthorized sources
- Control DHCPv6 server spoofing
- Protect against ND cache exhaustion attacks

### Best Practices
- Use randomized IPv6 interface identifiers
- Implement proper prefix delegation controls
- Monitor for rogue IPv6 router advertisements
- Apply appropriate firewall rules for IPv6 traffic

## Performance Optimization

### Scaling Considerations
- Optimize neighbor cache sizes for large deployments
- Configure appropriate RA interval timers
- Tune DHCPv6 lease times for performance
- Monitor IPv6 routing table sizes

### Resource Management
- Control IPv6 address pool utilization
- Monitor memory usage for ND cache entries
- Optimize RADIUS accounting for IPv6 sessions
- Balance load across multiple IPv6 prefixes

## Integration with Existing Infrastructure

### RADIUS Integration
- Configure IPv6-specific RADIUS attributes
- Update accounting record processing
- Adapt session management for dual-stack
- Modify authentication policies for IPv6

### Network Management
- Coordinate with existing IPv6 infrastructure
- Integrate with IPv6 address management systems
- Align with enterprise IPv6 deployment strategies
- Ensure compatibility with security appliances