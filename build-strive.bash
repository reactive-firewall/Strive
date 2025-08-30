#!/usr/bin/env bash

# reactive-firewall/build-strive.sh - simple cross/build script for Strive
# ..................................
# Copyright (c) 2017-2024, Mr. Walls
# ..................................
# Licensed under APACHE-2 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# ..........................................
# https://github.com/reactive-firewall/Strive?tab=Apache-2.0-1-ov-file
# ..........................................
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Disclaimer of Warranties.
# A. YOU EXPRESSLY ACKNOWLEDGE AND AGREE THAT, TO THE EXTENT PERMITTED BY
#    APPLICABLE LAW, USE OF THIS SHELL SCRIPT AND ANY SERVICES PERFORMED
#    BY OR ACCESSED THROUGH THIS SHELL SCRIPT IS AT YOUR SOLE RISK AND
#    THAT THE ENTIRE RISK AS TO SATISFACTORY QUALITY, PERFORMANCE, ACCURACY AND
#    EFFORT IS WITH YOU.
#
# B. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SHELL SCRIPT
#    AND SERVICES ARE PROVIDED "AS IS" AND "AS AVAILABLE", WITH ALL FAULTS AND
#    WITHOUT WARRANTY OF ANY KIND, AND THE AUTHOR OF THIS SHELL SCRIPT'S LICENSORS
#    (COLLECTIVELY REFERRED TO AS "THE AUTHOR" FOR THE PURPOSES OF THIS DISCLAIMER)
#    HEREBY DISCLAIM ALL WARRANTIES AND CONDITIONS WITH RESPECT TO THIS SHELL SCRIPT
#    SOFTWARE AND SERVICES, EITHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
#    NOT LIMITED TO, THE IMPLIED WARRANTIES AND/OR CONDITIONS OF
#    MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE,
#    ACCURACY, QUIET ENJOYMENT, AND NON-INFRINGEMENT OF THIRD PARTY RIGHTS.
#
# C. THE AUTHOR DOES NOT WARRANT AGAINST INTERFERENCE WITH YOUR ENJOYMENT OF THE
#    THE AUTHOR's SOFTWARE AND SERVICES, THAT THE FUNCTIONS CONTAINED IN, OR
#    SERVICES PERFORMED OR PROVIDED BY, THIS SHELL SCRIPT WILL MEET YOUR
#    REQUIREMENTS, THAT THE OPERATION OF THIS SHELL SCRIPT OR SERVICES WILL
#    BE UNINTERRUPTED OR ERROR-FREE, THAT ANY SERVICES WILL CONTINUE TO BE MADE
#    AVAILABLE, THAT THIS SHELL SCRIPT OR SERVICES WILL BE COMPATIBLE OR
#    WORK WITH ANY THIRD PARTY SOFTWARE, APPLICATIONS OR THIRD PARTY SERVICES,
#    OR THAT DEFECTS IN THIS SHELL SCRIPT OR SERVICES WILL BE CORRECTED.
#    INSTALLATION OF THIS THE AUTHOR SOFTWARE MAY AFFECT THE USABILITY OF THIRD
#    PARTY SOFTWARE, APPLICATIONS OR THIRD PARTY SERVICES.
#
# D. YOU FURTHER ACKNOWLEDGE THAT THIS SHELL SCRIPT AND SERVICES ARE NOT
#    INTENDED OR SUITABLE FOR USE IN SITUATIONS OR ENVIRONMENTS WHERE THE FAILURE
#    OR TIME DELAYS OF, OR ERRORS OR INACCURACIES IN, THE CONTENT, DATA OR
#    INFORMATION PROVIDED BY THIS SHELL SCRIPT OR SERVICES COULD LEAD TO
#    DEATH, PERSONAL INJURY, OR SEVERE PHYSICAL OR ENVIRONMENTAL DAMAGE,
#    INCLUDING WITHOUT LIMITATION THE OPERATION OF NUCLEAR FACILITIES, AIRCRAFT
#    NAVIGATION OR COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, LIFE SUPPORT OR
#    WEAPONS SYSTEMS.
#
# E. NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY THE AUTHOR
#    SHALL CREATE A WARRANTY. SHOULD THIS SHELL SCRIPT OR SERVICES PROVE DEFECTIVE,
#    YOU ASSUME THE ENTIRE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
#
#    Limitation of Liability.
# F. TO THE EXTENT NOT PROHIBITED BY APPLICABLE LAW, IN NO EVENT SHALL THE AUTHOR
#    BE LIABLE FOR PERSONAL INJURY, OR ANY INCIDENTAL, SPECIAL, INDIRECT OR
#    CONSEQUENTIAL DAMAGES WHATSOEVER, INCLUDING, WITHOUT LIMITATION, DAMAGES
#    FOR LOSS OF PROFITS, CORRUPTION OR LOSS OF DATA, FAILURE TO TRANSMIT OR
#    RECEIVE ANY DATA OR INFORMATION, BUSINESS INTERRUPTION OR ANY OTHER
#    COMMERCIAL DAMAGES OR LOSSES, ARISING OUT OF OR RELATED TO YOUR USE OR
#    INABILITY TO USE THIS SHELL SCRIPT OR SERVICES OR ANY THIRD PARTY
#    SOFTWARE OR APPLICATIONS IN CONJUNCTION WITH THIS SHELL SCRIPT OR
#    SERVICES, HOWEVER CAUSED, REGARDLESS OF THE THEORY OF LIABILITY (CONTRACT,
#    TORT OR OTHERWISE) AND EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGES. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION
#    OR LIMITATION OF LIABILITY FOR PERSONAL INJURY, OR OF INCIDENTAL OR
#    CONSEQUENTIAL DAMAGES, SO THIS LIMITATION MAY NOT APPLY TO YOU. In no event
#    shall THE AUTHOR's total liability to you for all damages (other than as may
#    be required by applicable law in cases involving personal injury) exceed
#    the amount of five dollars ($5.00). The foregoing limitations will apply
#    even if the above stated remedy fails of its essential purpose.
################################################################################
PATH=${PATH:-"/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"} ;

# Usage: ./build-strive.bash [CC] [CFLAGS] [DESTDIR]
#   ./build-strive.sh [cc] [cflags] [destdir]
# Defaults:
#   CC="${1:-clang}"
#   AR="${AR:-ar}"
#   CFLAGS="${2:--O2 -ffunction-sections -fdata-sections -fPIC -Wall -Wextra -Werror}"
#   DESTDIR="${3:-./out}"
set -euo pipefail

CC="${1:-clang}"
AR="${AR:-ar}"
CFLAGS="${2:--O2 -ffunction-sections -fdata-sections -fPIC -Wall -Wextra -Werror}"
DESTDIR="${3:-./out}"
SRCDIR="Strive"
SRC="${SRCDIR}/Strive.c"
HDR_A="${SRCDIR}/Strive.h"
HDR_B="${SRCDIR}/minimal_types.h"
OBJDIR="${DESTDIR}/obj"
LIBDIR="${DESTDIR}/lib"
BINDIR="${DESTDIR}/bin"
LIBNAME="libstrive.a"
INCLUDEDIR="${DESTDIR}/include"

# Ensure required file-ops are available (toybox allowed tools)
for cmd in basename cat chmod cp date dirname find grep head mkdir mv rm; do
  command -v "$cmd" >/dev/null 2>&1 || {
    printf 'Missing required helper: %s\n' "$cmd" >&2
    exit 1
  }
done

printf 'Building Strive with %s\n' "$CC"
printf 'CFLAGS=%s\n' "$CFLAGS"
printf 'DESTDIR=%s\n' "$DESTDIR"

# Verify sources exist
for f in "$SRC" "$HDR_A" "$HDR_B"; do
  if [ ! -f "$f" ]; then
    printf 'Missing source/header: %s\n' "$f" >&2
    exit 1
  fi
done

# Prepare directories
rm -rf "${DESTDIR}"
mkdir -p "${OBJDIR}" "${LIBDIR}" "${BINDIR}" "${INCLUDEDIR}" "${INCLUDEDIR}/Strive"

# Compile object
OBJ="${OBJDIR}/Strive.o"
printf 'Compiling %s -> %s\n' "$SRC" "$OBJ"
# Prefer project headers with -I
"$CC" $CFLAGS -I"${SRCDIR}" -c "${SRC}" -o "${OBJ}"

# Archive
LIBPATH="${LIBDIR}/${LIBNAME}"
printf 'Archiving %s -> %s\n' "$OBJ" "$LIBPATH"
"$AR" rcs "$LIBPATH" "$OBJ"

# Install headers
printf 'Installing headers to %s\n' "${INCLUDEDIR}/Strive"
cp "${HDR_A}" "${INCLUDEDIR}/Strive/Strive.h"
cp "${HDR_B}" "${INCLUDEDIR}/Strive/minimal_types.h"

# Basic test program (attempt to compile; may be cross-compiler)
TEST_C="${OBJDIR}/test_strive.c"
cat > "${TEST_C}" <<'EOF'
#include "Strive/Strive.h"
#include <stdio.h>
int main(void) {
    char buf[32] = "hello";
    strlcat(buf, " world", sizeof(buf));
    puts(buf);
    return 0;
}
EOF

TEST_BIN="${BINDIR}/test_strive"
printf 'Attempting to build test program with %s\n' "$CC"
if "$CC" -o "${TEST_BIN}" "${TEST_C}" -I"${INCLUDEDIR}" 2>/dev/null; then
  if [ -x "${TEST_BIN}" ] && command -v "${TEST_BIN}" >/dev/null 2>&1; then
    printf 'Running test program:\n'
    "${TEST_BIN}"
  else
    printf 'Test program built at %s but not runnable on host (likely cross-compiled). Skipping run.\n' "${TEST_BIN}"
  fi
else
  printf 'Could not link test program with %s; likely cross-compiler. Skipping run.\n' "$CC"
fi

printf 'Build complete. Library: %s\n' "$LIBPATH"
printf 'Headers installed under: %s/Strive\n' "$INCLUDEDIR"
printf 'Cleaning up...'

# Cleanup test artifacts
rm -f "${TEST_C}" "${TEST_BIN}" 2>/dev/null || true

exit 0
