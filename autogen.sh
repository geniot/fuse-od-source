#!/bin/sh

# autogen.sh: autotools invocation
# Copyright (c) 2004 Philip Kendall
# Copyright (c) 2014 Sergio Baldoví

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Author contact information:

# E-mail: Philip Kendall <philip-fuse@shadowmagic.org.uk>

# Exit on errors
set -e

autoreconf -f -i -I m4 -v

./configure \
PKG_CONFIG_PATH="$HOME/CLionProjects/libspectrum-od-source/libspectrum-install/lib/pkgconfig" \
LIBSPECTRUM_CFLAGS="-I$HOME/CLionProjects/libspectrum-od-source/libspectrum-install/include" \
LIBSPECTRUM_LIBS="-L$HOME/CLionProjects/libspectrum-od-source/libspectrum-install/lib \
-l:libspectrum.a \
-lbz2" \
CC=mipsel-gcw0-linux-uclibc-gcc \
CXX=mipsel-gcw0-linux-uclibc-g++ \
--host=mipsel-gcw0-linux-uclibc \
--with-gcw0 \
--disable-sdl2 \
--with-sdl-prefix=/opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/usr \
CFLAGS='-g -mips32r2 -O3 -O0'
