#!/usr/bin/fish

# This file must be sourced in fish:
#
#   source (which env_parallel.fish)
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

# If you are a fisherman feel free to improve the code
#
# The code needs to deal with variables like:
#   set funky (perl -e 'print pack "c*", 2..254')
#
# Problem:
#   Tell the difference between:
#     set tmp "a'  'b'  'c"
#     set tmparr1 "a'  'b"  'c'
#     set tmparr2 'a'  "b'  'c"
#   The output from `set` is exactly the same.
# Solution:
#   for-loop for each variable. Each value is separated with a
#   separator.

function env_parallel
  setenv PARALLEL_ENV (
    begin;
      # Export function definitions
      functions -n | perl -pe 's/,/\n/g' | while read d; functions $d; end;
      # Convert scalar vars to fish \XX quoting
      eval (set -L | perl -ne 'chomp;
        ($name,$val)=split(/ /,$_,2);
        $name=~/^(COLUMNS|FISH_VERSION|LINES|PWD|SHLVL|_|history|status|version)$/ and next;
        if($val=~/^'"'"'/) { next; }
        print "set $name \"\$$name\";\n";
      ')
      # Generate commands to set scalar variables
      begin;
        for v in (set -n);
          # Separate variables with the string: \000
          eval "for i in \$$v;
            echo -n $v \$i;
    	    perl -e print\\\"\\\\0\\\";
          end;"
        end;
        # A final line to flush the last variable in Perl
        perl -e print\"\\0\";
      end | perl -0 -ne '
          # Remove separator string
          chop;
          ($name,$val)=split(/ /,$_,2);
          # Ignore read-only vars
          $name=~/^(COLUMNS|FISH_VERSION|LINES|PWD|SHLVL|_|history|status|version)$/ and next;
          # Quote $val
          $val=~s/[\002-\011\013-\032\\\#\?\`\(\)\{\}\[\]\^\*\<\=\>\~\|\; \"\!\$\&\202-\377]/\\\$&/go;
          # Quote single quote
          $val=~s/'"'"'/\\\$&/go;
          # Quote newline as '\n'
          $val =~ s/[\n]/\\\n/go;
 	  # Empty => 2 single quotes = \047\047
	  $val=~s/^$/\047\047/o;
          if($name ne $last and $last) {
            # The $name is different, so this is a new variable.
            # Print the last one.
            # Separate list elements by 2 spaces
            $"="  ";
            print "set $last @qval;\n";
            @qval=();
          }
          push @qval,$val;
          $last=$name;
        ';
    end |perl -pe 's/\001/\\cb/g and print STDERR "env_parallel: Warning: ASCII value 1 in variables is not supported\n";
                   s/\n/\001/'
    )
  parallel $argv;
  set -e PARALLEL_ENV
end
