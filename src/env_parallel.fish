# This file must be sourced in fish:
#
#   source (which env_parallel.fish)
#
# after which 'env_parallel' works
#
#
# Copyright (C) 2007,2008,2009,2010,2011,2012,2013,2014,2015,2016
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

function env_parallel
  setenv PARALLEL_ENV (begin; functions -n | perl -pe 's/,/\n/g' | while read d; functions $d; end; perl -e 'print map { "$_///$ENV{$_}\n"} grep !/^(PWD|SHLVL|PATH)$/, keys %ENV'| sh -c 'parallel --shellquote' | perl -pe 's:^([^/]+)///:setenv $1 :'; end |perl -pe 's/\001/\\cb/g;s/\n/\001/')
  parallel $argv;
  set -e PARALLEL_ENV
end
