#!/usr/bin/env ash

# This file must be sourced in ash:
#
#   . `which env_parallel.ash`
#
# after which 'env_parallel' works
#
#
# Copyright (C) 2017
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
    # env_parallel.ash

    # Get the --env variables if set
    # --env _ should be ignored
    # and convert  a b c  to (a|b|c)
    # If --env not set: Match everything (.*)
    local _grep_REGEXP="$(
        perl -e '
            for(@ARGV){
                /^_$/ and $next_is_env = 0;
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env = /^--env$/;
            }
            $vars = join "|",map { quotemeta $_ } @envvar;
            print $vars ? "($vars)" : "(.*)";
            ' -- "$@"
    )"
    # Deal with --env _
    local _ignore_UNDERSCORE="$(
        perl -e '
            for(@ARGV){
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env=/^--env$/;
            }
            if(grep { /^_$/ } @envvar) {
                if(not open(IN, "<", "$ENV{HOME}/.parallel/ignored_vars")) {
             	    print STDERR "parallel: Error: ",
            	    "Run \"parallel --record-env\" in a clean environment first.\n";
                } else {
            	    chomp(@ignored_vars = <IN>);
            	    $vars = join "|",map { quotemeta $_ } "env_parallel", @ignored_vars;
	    print $vars ? "($vars)" : "(,,nO,,VaRs,,)";
                }
            }
            ' -- "$@"
    )"

    _list_aliases() {
	alias | perl -pe 's/=.*//'
    }
    _body_aliases() {
	alias "$@" | perl -pe 's/^/alias /'
    }
    _list_functions() {
	# TODO see http://unix.stackexchange.com/questions/343297/dash-list-declared-functions
	true;
    }
    _list_variables() {
	# This may screw up if variables contain \n and =
	set | perl -ne 's/=.*// and print;'
    }
    _body_variables() {
	# Crappy typeset -p
	for _i in "$@"
	do
	    echo -n "$_i"=
	    eval echo -n \"\$$_i\" |
		perl -pe 's/[\002-\011\013-\032\\\#\?\`\(\)\{\}\[\]\^\*\<\=\>\~\|\; \"\!\$\&\202-\377]/\\$&/go;'"s/'/\\\'/g; s/[\n]/'\\n'/go;";
	    echo
	done
    }

    # --record-env
    if ! perl -e 'exit grep { /^--record-env$/ } @ARGV' -- "$@"; then
	(_list_aliases;
	 _list_functions;
	 _list_variables) |
	    cat > $HOME/.parallel/ignored_vars
	return 0
    fi
    
    # Grep alias names
    local _alias_NAMES="$(_list_aliases |
        grep -E "^$_grep_REGEXP"\$ | grep -vE "^$_ignore_UNDERSCORE"\$ )"
    local _list_alias_BODIES="_body_aliases $_alias_NAMES"
    if [ "$_alias_NAMES" = "" ] ; then
	# no aliases selected
	_list_alias_BODIES="true"
    fi
    unset _alias_NAMES

    # Grep function names
    local _function_NAMES="$(_list_functions |
        grep -E "^$_grep_REGEXP"\$ | grep -vE "^$_ignore_UNDERSCORE"\$ )"
    local _list_function_BODIES="typeset -f $_function_NAMES"
    if [ "$_function_NAMES" = "" ] ; then
	# no functions selected
	_list_function_BODIES="true"
    fi
    unset _function_NAMES

    # Grep variable names
    local _variable_NAMES="$(_list_variables |
        grep -E "^$_grep_REGEXP"\$ | grep -vE "^$_ignore_UNDERSCORE"\$ |
#        grep -vFf <(readonly -p) |
        grep -Ev '^(BASHOPTS|BASHPID|EUID|GROUPS|FUNCNAME|DIRSTACK|_|PIPESTATUS|PPID|SHELLOPTS|UID|USERNAME|BASH_[A-Z_]+)$')"
    local _list_variable_VALUES="_body_variables $_variable_NAMES"
    if [ "$_variable_NAMES" = "" ] ; then
	# no variables selected
	_list_variable_VALUES="true"
    fi
    unset _variable_NAMES

    # Copy shopt (so e.g. extended globbing works)
    # But force expand_aliases as aliases otherwise do not work
    export PARALLEL_ENV="$(
        $_list_alias_BODIES;
        $_list_variable_VALUES;
        $_list_function_BODIES)";
    unset _list_alias_BODIES
    unset _list_variable_VALUES
    unset _list_function_BODIES
    `which parallel` "$@";
    _parallel_exit_CODE=$?
    unset PARALLEL_ENV;
    return $_parallel_exit_CODE
}
