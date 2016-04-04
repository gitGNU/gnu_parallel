#!/bin/bash

# This file must be sourced in bash:
#
#   source `which env_parallel.bash`
#
# after which 'env_parallel' works
#
#
# Copyright (C) 2016
# Ole Tange and Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>
# or write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301 USA

# Supports env of 127426 bytes
env_parallel() {
  export PARALLEL_ENV="$(echo "shopt -s expand_aliases 2>/dev/null"; alias;typeset -p |
    grep -vFf <(readonly) |
    grep -v 'declare .. (GROUPS|FUNCNAME|DIRSTACK|_|PIPESTATUS|USERNAME|BASH_[A-Z_]+) ';
    typeset -f)";
  `which parallel` "$@";
  unset PARALLEL_ENV;
}

# Supports env of 127375 bytes
#
# env_parallel() {
#   # Saving to a tempfile
#   export PARALLEL_ENV=`tempfile`;
#   (echo "shopt -s expand_aliases 2>/dev/null"; alias;typeset -p |
#     grep -vFf <(readonly) |
#     grep -v 'declare .. (GROUPS|FUNCNAME|DIRSTACK|_|PIPESTATUS|USERNAME|BASH_[A-Z_]+) ';
#     typeset -f) > $PARALLEL_ENV
#   `which parallel` "$@";
#   rm "$PARALLEL_ENV"
#   unset PARALLEL_ENV;
# }
