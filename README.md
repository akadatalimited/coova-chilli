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

## IPv6 Prefix Delegation

CoovaChilli now sends IPv6 router advertisements and can delegate a
configurable `/64` prefix. Clients obtain addresses via SLAAC, including
Android devices. Use `--ipv6prefix` to set the base prefix and choose
between a shared `/64` (`--ipv6shared`) or per-client delegation
(`--ipv6perclient`).

Example enabling per-client prefixes:

```
chilli --ipv6 --ipv6prefix 2001:db8:: --ipv6perclient
```
