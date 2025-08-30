/*
 Strive.c - a tiny, stage0-safe collection of overlap-safe, minimal strlcpy/strlcat
 replacements and tiny type fallbacks for bootstrapping small C toolchains.

 Copyright 2025 Mr. Walls <reactive-firewall@users.noreply.github.com>

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 https://github.com/reactive-firewall/Strive?tab=Apache-2.0-1-ov-file

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 Created by Mr. Walls on 2025.08.29.
 */

#include "Strive.h"

/* Helper: compute length of NUL-terminated string up to maxlen.
   Returns length (<= maxlen). */
static size_t STRIVE_UNUSED safe_strnlen(const char *s, size_t maxlen) {
	const char *p = s;
	size_t n = 0;
	while (n < maxlen && *p) {
		++p;
		++n;
	}
	return n;
}

/* Helper: memmove-like safe copy handling overlap.
   Copies n bytes from src to dst. dst and src may overlap.
   Returns dst. */
static void *safe_memmove(void *dst, const void *src, size_t n) {
	unsigned char *d = (unsigned char *)dst;
	const unsigned char *s = (const unsigned char *)src;

	if (d == s || n == 0) return dst;

	if (d < s) {
		/* forward copy */
		while (n--) *d++ = *s++;
	} else {
		/* backward copy */
		d += n;
		s += n;
		while (n--) *--d = *--s;
	}
	return dst;
}

/* Minimal, overlap-safe strlcpy:
	Copies up to dstsize-1 bytes from src to dst, NUL-terminates when dstsize>0.
	Returns strlen(src) (the length it tried to create). */
size_t strlcpy(char *dst, const char *src, size_t dstsize) {
	size_t src_len = 0;
	const char *s = src;
	while (*s++) ++src_len; /* full src length */

	if (dstsize == 0) return src_len;

	size_t copy_len = (src_len >= dstsize) ? dstsize - 1 : src_len;
	/* Use safe_memmove to handle potential overlap */
	safe_memmove(dst, src, copy_len);
	dst[copy_len] = '\0';
	return src_len;
}

/* Minimal, overlap-safe strlcat:
	Appends src to dst of total buffer size dstsize (including NUL).
	At most dstsize-1 bytes in dst after operation. NUL-terminates if dstsize>0.
	Returns initial_dst_len + strlen(src) (the length it tried to create). */
size_t strlcat(char *dst, const char *src, size_t dstsize) {
	size_t dst_len = 0;
	/* compute dst length but not beyond dstsize */
	while (dst_len < dstsize && dst[dst_len]) ++dst_len;

	size_t src_len = 0;
	const char *s = src;
	while (*s++) ++src_len;

	if (dst_len == dstsize) {
		/* dst was not NUL-terminated within dstsize */
		return dstsize + src_len;
	}

	size_t space = dstsize - dst_len - 1; /* room for chars excluding NUL */
	size_t to_copy = (src_len > space) ? space : src_len;

	/* Append using safe_memmove in case src overlaps the region being written.
	Note: src may point into dst; compute source pointer accordingly. */
	safe_memmove(dst + dst_len, src, to_copy);
	dst[dst_len + to_copy] = '\0';

	return dst_len + src_len;
}
