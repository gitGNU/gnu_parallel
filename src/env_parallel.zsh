#!/usr/bin/zsh

# This file must be sourced in zsh:
#
#   source =env_parallel.zsh
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

env_parallel() {
  export PARALLEL_ENV="$(alias | perl -pe 's/^/alias /'; typeset -p |
    grep -aFvf <(typeset -pr) |
    egrep -iav 'ZSH_EVAL_CONTEXT|LINENO=| _=|aliases|^typeset [a-z_]+$'|
    egrep -av '^(typeset -A (commands|functions|options)|typeset IFS=|..$)|cyan';
    typeset -f)";
  parallel "$@";
  unset PARALLEL_ENV;
}
