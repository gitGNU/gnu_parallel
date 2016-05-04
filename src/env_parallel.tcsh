#!/bin/csh

# This file must be sourced in tcsh:
#
#   source `which env_parallel.tcsh`
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

if ("`alias env_parallel`" == '') then
  # Activate alias
  alias env_parallel 'setenv PARALLEL "\!*"; source `which env_parallel.tcsh`'
else
  # Get the scalar and array variable names
  set _vARnAmES=(`set | awk -e '{print $1}' |grep -vE '^(_|killring|prompt2)$'`)

  # Make a tmpfile for the variable definitions
  set _tMpvARfILe=`tempfile`
  
  # Make a tmpfile for the variable definitions + alias
  set _tMpaLLfILe=`tempfile`
  foreach _vARnAmE ($_vARnAmES);
    # if $?myvar && $#myvar <= 1 echo scalar_myvar=$var
    eval if'($?'$_vARnAmE' && ${#'$_vARnAmE'} <= 1) echo scalar_'$_vARnAmE'='\"\$$_vARnAmE\" >> $_tMpvARfILe;
    # if $?myvar && $#myvar > 1 echo array_myvar=$var
    eval if'($?'$_vARnAmE' && ${#'$_vARnAmE'} > 1) echo array_'$_vARnAmE'="$'$_vARnAmE'"' >> $_tMpvARfILe;
  end

  # shell quote variables (--plain needed due to $PARALLEL abuse)
  # Convert 'scalar_myvar=...' to 'set myvar=...'
  # Convert 'array_myvar=...' to 'set array=(...)'
  cat $_tMpvARfILe | parallel --plain --shellquote |  perl -pe 's/^scalar_(\S+).=/set $1=/ or s/^array_(\S+).=(.*)/set $1=($2)/ && s/\\ / /g;' > $_tMpaLLfILe
  # Cleanup
  rm $_tMpvARfILe; unset _tMpvARfILe _vARnAmE _vARnAmES

# ALIAS TO EXPORT ALIASES:

#   Quote ' by putting it inside "
#   s/'/'"'"'/g;
#   ' => \047 " => \042
#   s/\047/\047\042\047\042\047/g;
#   Quoted: s/\\047/\\047\\042\\047\\042\\047/g\;

#   Remove () from second column
#   s/^(\S+)(\s+)\((.*)\)/\1\2\3/;
#   Quoted: s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;

#   Add ' around second column
#   s/^(\S+)(\s+)(.*)/\1\2'\3'/
#   \047 => '
#   s/^(\S+)(\s+)(.*)/\1\2\047\3\047/;
#   Quoted: s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;

#   Quote ! as \!
#   s/\!/\\\!/g;
#   Quoted: s/\\\!/\\\\\\\!/g;

#   Prepend with "\nalias "
#   s/^/\001alias /;
#   Quoted: s/\^/\\001alias\ /\;
  alias | perl -pe s/\\047/\\047\\042\\047\\042\\047/g\;s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;s/\^/\\001alias\ /\;s/\\\!/\\\\\\\!/g >> $_tMpaLLfILe 
  
  setenv PARALLEL_ENV "`cat $_tMpaLLfILe; rm $_tMpaLLfILe`";
  unset _tMpaLLfILe;
  # Use $PARALLEL set in calling alias
  parallel
  setenv PARALLEL_ENV
  setenv PARALLEL
endif

# Tested working for aliases
# alias env_parallel 'setenv PARALLEL_ENV "`alias | perl -pe s/\\047/\\047\\042\\047\\042\\047/g\;s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;s/\^/\\001alias\ /\;s/\\\!/\\\\\\\!/g;`";parallel \!*; setenv PARALLEL_ENV'

