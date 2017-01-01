#!/usr/bin/env zsh

# This file must be sourced in zsh:
#
#   source =env_parallel.zsh
#
# after which 'env_parallel' works
#
#
# Copyright (C) 2016,2017
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
    # env_parallel.zsh

    # Get the --env variables if set
    # --env _ should be ignored
    # and convert  a b c  to (a|b|c)
    # If --env not set: Match everything (.*)
    _grep_REGEXP="$(
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

    # --record-env
    if ! perl -e 'exit grep { /^--record-env$/ } @ARGV' -- "$@"; then
	(print -l ${(k)aliases};
	 print -l ${(k)functions};
	 print -l ${(k)parameters}) |
	    cat > $HOME/.parallel/ignored_vars
	return 0
    fi
    
    # Grep alias names
    _alias_NAMES="$(print -l ${(k)aliases} |
        grep -E "^$_grep_REGEXP"\$ | grep -vE "^$_ignore_UNDERSCORE"\$ )"
    _list_alias_BODIES="alias "$(echo $_alias_NAMES|xargs)" | perl -pe 's/^/alias /'"
    if [[ "$_alias_NAMES" = "" ]] ; then
	# no aliases selected
	_list_alias_BODIES="true"
    fi
    unset _alias_NAMES

    # Grep function names
    _function_NAMES="$(print -l ${(k)functions} |
        grep -E "^$_grep_REGEXP\$" | grep -vE "^$_ignore_UNDERSCORE\$" |
        grep -v '='
        )"
    _list_function_BODIES="typeset -f "$(echo $_function_NAMES|xargs)
    if [[ "$_function_NAMES" = "" ]] ; then
	# no functions selected
	_list_function_BODIES="true"
    fi
    unset _function_NAMES

    # Grep variable names
    # The grep -Ev is crap and should be better
    _variable_NAMES="$(print -l ${(k)parameters} |
        grep -E "^$_grep_REGEXP"\$ | grep -vE "^$_ignore_UNDERSCORE"\$ |
        grep -Ev '^([-?#!$*@_0]|zsh_eval_context|ZSH_EVAL_CONTEXT|LINENO|IFS|commands|functions|options|aliases|EUID|EGID|UID|GID)$' |
        grep -Ev '^(dis_patchars|patchars|terminfo|funcstack|galiases|keymaps|parameters|jobdirs|dirstack|functrace|funcsourcetrace|zsh_scheduled_events|dis_aliases|dis_reswords|dis_saliases|modules|reswords|saliases|widgets|userdirs|historywords|nameddirs|termcap|dis_builtins|dis_functions|jobtexts|funcfiletrace|dis_galiases|builtins|history|jobstates)$'
        )"
    _list_variable_VALUES="typeset -p "$(echo $_variable_NAMES|xargs)" |
        grep -aFvf <(typeset -pr)
    "
    if [[ "$_variable_NAMES" = "" ]] ; then
	# no variables selected
	_list_variable_VALUES="true"
    fi
    unset _variable_NAMES
    export PARALLEL_ENV="$(
        eval $_list_alias_BODIES;
        eval $_list_function_BODIES;
        eval $_list_variable_VALUES;
    )";
    unset _list_alias_BODIES
    unset _list_variable_VALUES
    unset _list_function_BODIES
    `which parallel` "$@";
    _parallel_exit_CODE=$?
    unset PARALLEL_ENV;
    return $_parallel_exit_CODE
}
