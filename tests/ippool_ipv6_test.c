#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <time.h>
#include <stdint.h>

/* Stubs for globals used by ippool.c */
struct options_t {
  int leaseplus;
  int debug;
  int uamanyip;
  struct in_addr uamlisten;
  struct in_addr dhcplisten;
} _options;

struct dhcp_t {
  time_t lease;
} *dhcp;

time_t mainclock_now(void) { return time(NULL); }
int safe_write(int fd, void *buf, size_t count) { (void)fd; (void)buf; return (int)count; }

uint32_t lookup(uint8_t *k, size_t length, uint32_t level) {
  uint32_t hash = level;
  for (size_t i = 0; i < length; i++)
    hash = hash * 33 + k[i];
  return hash;
}

#include "../src/ippool.h"

int main(void) {
  struct ippool_t *pool = NULL;
  struct in6_addr start;
  inet_pton(AF_INET6, "2001:db8::1", &start);

  assert(ippool_new6(&pool, &start, 3) == 0);

  struct in6_addr a1, a2, a3;
  assert(ippool_getip6(pool, &a1) == 0);
  assert(ippool_getip6(pool, &a2) == 0);
  assert(ippool_returnip6(pool, &a1) == 0);
  assert(ippool_getip6(pool, &a3) == 0);
  /* a3 should equal a1 */
  assert(memcmp(&a1, &a3, sizeof(a1)) == 0);

  ippool_free(pool);
  printf("IPv6 pool lease/release test passed\n");
  return 0;
}
