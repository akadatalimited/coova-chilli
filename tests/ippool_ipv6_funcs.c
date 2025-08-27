#include "../src/ippool.h"
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static void in6_addr_add(const struct in6_addr *base, int n, struct in6_addr *out) {
  int i; unsigned int carry = n; *out = *base;
  for (i = 15; i >= 0 && carry; i--) {
    unsigned int sum = out->s6_addr[i] + (carry & 0xff);
    out->s6_addr[i] = sum & 0xff;
    carry = (carry >> 8) + (sum >> 8);
  }
}

uint32_t ippool_hash6(struct in6_addr *addr) {
  return lookup((unsigned char *)addr->s6_addr, sizeof(addr->s6_addr), 0);
}

int ippool_new6(struct ippool_t **this, struct in6_addr *start, int size) {
  if (!(*this = calloc(1, sizeof(struct ippool_t))))
    return -1;
  (*this)->base6 = *start;
  (*this)->pool6_size = size;
  (*this)->pool6_used = calloc(size, sizeof(char));
  if (!(*this)->pool6_used) {
    free(*this);
    *this = NULL;
    return -1;
  }
  return 0;
}

int ippool_getip6(struct ippool_t *this, struct in6_addr *addr) {
  for (int i = 0; i < this->pool6_size; i++) {
    if (!this->pool6_used[i]) {
      this->pool6_used[i] = 1;
      in6_addr_add(&this->base6, i, addr);
      return 0;
    }
  }
  return -1;
}

int ippool_returnip6(struct ippool_t *this, struct in6_addr *addr) {
  struct in6_addr tmp;
  for (int i = 0; i < this->pool6_size; i++) {
    in6_addr_add(&this->base6, i, &tmp);
    if (!memcmp(&tmp, addr, sizeof(struct in6_addr))) {
      this->pool6_used[i] = 0;
      return 0;
    }
  }
  return -1;
}

int ippool_free(struct ippool_t *this) {
  free(this->pool6_used);
  free(this);
  return 0;
}
