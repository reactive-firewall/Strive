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
#ifndef STRIVE_H
#if defined(__clang__) && __clang__
#pragma mark - StriveHeader
#endif /* !__clang__ */
///Defined whenever ``Strive`` is imported.
#define STRIVE_H "Strive.h"

#if defined(__clang__) || defined(__GNUC__)
# define STRIVE_UNUSED __attribute__((unused))
#else
# define STRIVE_UNUSED
#endif

#if defined(__clang__) && __clang__
#pragma mark - Imports
#endif /* !__clang__ */
/* Always include the project's minimal_types header via quoted include.
 We compile with -IStrive so "minimal_types.h" resolves to Strive/minimal_types.h. */
#include "minimal_types.h"

#if defined(__clang__) && __clang__
#pragma mark - Exports
#endif /* !__clang__ */
/* Public prototypes */
#ifdef __cplusplus
extern "C" {
#endif

size_t strlcpy(char *dst, const char *src, size_t dstsize);
size_t strlcat(char *dst, const char *src, size_t dstsize);

#ifdef __cplusplus
}
#endif

#endif /* STRIVE_H */

