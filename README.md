CoovaChilli is a feature rich software access controller that provides a
captive portal / walled-garden environment and uses RADIUS or a HTTP protocol
for access provisioning and accounting.
Released under the GNU General Public License (GPL).

Visit website for documentation and archived content

[https://coova.github.io/](https://coova.github.io/)

Please use the [Github issues](https://github.com/coova/coova-chilli/issues) section for bug reports only.

There are now mailing lists for general support / discussion as well as an
announcement list for notices.

[General discussion / support mailing list](https://www.brightonchilli.org.uk/mailman/listinfo/coovachilli)

[Announcement mailing list](https://www.brightonchilli.org.uk/mailman/listinfo/coovachilli-announce)

[![Build Status](https://travis-ci.org/coova/coova-chilli.svg?branch=master)](https://travis-ci.org/coova/coova-chilli)

To get started after cloning git repository:

  `sh bootstrap`
  
  `./configure` 
  
  `make`

More details about the build process and dependencies are covered in the [INSTALL file](/INSTALL)

## IPv6 Support

CoovaChilli now provides full IPv6 support including:

- **SLAAC Support** - Complete Router Advertisement with RDNSS
- **DHCPv6** - Full DHCPv6 server functionality for address assignment
- **ND-Proxy** - Neighbor Discovery Proxy for proper IPv6 neighbor handling
- **Dual-Stack Accounting** - Full RADIUS accounting for both IPv4 and IPv6 sessions
- **IPv6 Walled Garden** - Extended walled garden support for IPv6 addresses and networks
- **DNS Interception** - IPv6 DNS query interception and handling

### IPv6 Prefix Delegation

CoovaChilli now sends IPv6 router advertisements and can delegate a
configurable `/64` prefix. Clients obtain addresses via SLAAC, including
Android devices. Use `--ipv6prefix` to set the base prefix and choose
between a shared `/64` (`--ipv6shared`) or per-client delegation
(`--ipv6perclient`).

Example enabling per-client prefixes:

```
chilli --ipv6 --ipv6prefix 2001:db8:: --ipv6perclient
```

### IPv6 Configuration Options

Additional IPv6 configuration options include:
- `--ipv6only` - Enable IPv6-only mode
- `--ipv6to4` - Enable IPv6-to-IPv4 translation
- `--ipv4to6` - Enable IPv4-to-IPv6 translation
- `--ipv6mode` - Set IPv6 mode (6and4, 4to6, or 6to4)
