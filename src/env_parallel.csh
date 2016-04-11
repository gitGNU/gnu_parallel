#!/bin/csh

# This file must be sourced in csh:
#
#   source `which env_parallel.csh`
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

alias env_parallel 'setenv PARALLEL_ENV "`alias | perl -pe s/\\047/\\047\\042\\047\\042\\047/g\;s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;s/\^/\\001alias\ /\;s/\\\!/\\\\\\\!/g;`";parallel \!*; setenv PARALLEL_ENV'
