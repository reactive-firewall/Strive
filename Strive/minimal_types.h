/*
	minimal_types.h - prefer system headers, fall back to minimal defs.

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
#ifndef MINIMAL_TYPES_H
#define MINIMAL_TYPES_H "minimal_types.h"

/* Prefer standard headers when available */
#if defined(__has_include)
#if defined(__clang__) && __clang__
#pragma mark - Imports
#endif /* !__clang__ */

#if __has_include(<stddef.h>)
#include <stddef.h>
#endif /* !__has_include(<stddef.h>) */

#if __has_include(<stdint.h>)
#include <stdint.h>
#endif /* !__has_include(<stdint.h>) */

#else /* No __has_include: attempt includes but guard against redefinition. */
#ifndef _STDDEF_H_INCLUDED
#if defined(__STDDEF_H__) || defined(_STDDEF_H_) || defined(_STDDEF_H)
/* assume some stddef-like header already included */
#define _STDDEF_H_INCLUDED 1
#else
#define _STDDEF_H_INCLUDED 0
/* try including a common location; include is safe if header exists */
#include <stddef.h>
#endif /* !_STDDEF_H */
/* We can't reliably detect all platforms; if stddef.h wasn't present this
 include will fail at compile time — acceptable for stage0 where MIT libc like musl headers
 are expected. */
#endif /* !_STDDEF_H_INCLUDED */

#ifndef _STDINT_H_INCLUDED
#if defined(__STDINT_H__) || defined(_STDINT_H_) || defined(_STDINT_H)
/* assume stdint already included */
#define _STDINT_H_INCLUDED 1
#else
#define _STDINT_H_INCLUDED 0
/* stdint.h is optional for our code; include if present */
#include <stdint.h>
#endif /* !_STDINT_H_ */
#endif /* !_STDINT_H_INCLUDED */
#endif /* !__has_include */

/* Basic fallbacks: define NULL, size_t, ptrdiff_t, offsetof if not present. */

#ifndef NULL
#if defined(__cplusplus) && __cplusplus
#if __cplusplus >= 201103L
#define NULL nullptr
#else /* __cplusplus < 201103L */
#define NULL 0
#endif /* !__cplusplus (inner) */
#else
#define NULL ((void*)0)
#endif /* !__cplusplus (outer) */
#endif /* !NULL */

#ifndef STRIVE_HAS_SIZE_T
#if defined(__SIZE_TYPE__)
typedef __SIZE_TYPE__ size_t;
#define STRIVE_HAS_SIZE_T 1
#else
typedef unsigned long size_t;
#define STRIVE_HAS_SIZE_T 1
#endif /* !__SIZE_TYPE__ */
#endif /* !STRIVE_HAS_SIZE_T */

#ifndef STRIVE_HAS_PTRDIFF_T
#if defined(__PTRDIFF_TYPE__)
typedef __PTRDIFF_TYPE__ ptrdiff_t;
#define STRIVE_HAS_PTRDIFF_T 1
#else
typedef long ptrdiff_t;
#define STRIVE_HAS_PTRDIFF_T 1
#endif /* !__PTRDIFF_TYPE__ */
#endif /* !ptrdiff_t */

/* offsetof fallback using Clang builtin when available */
#ifndef offsetof
#if defined(__has_builtin)
#if __has_builtin(__builtin_offsetof)
#define offsetof(type, member) __builtin_offsetof(type, member)
#else
#define offsetof(type, member) ((size_t)&(((type *)0)->member))
#endif
#else
/* No __has_builtin: try to detect Clang via predefined macro */
#if defined(__clang__)
#define offsetof(type, member) __builtin_offsetof(type, member)
#else
#define offsetof(type, member) ((size_t)&(((type *)0)->member))
#endif
#endif
#endif

#endif /* MINIMAL_TYPES_H */

