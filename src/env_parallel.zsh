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
    # env_parallel.zsh

    # Get the --env variables if set
    # and convert  a b c  to (a|b|c)
    # If --env not set: Match everything (.*)
    grep_REGEXP="$(
        perl -e 'for(@ARGV){
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env=/^--env$/;
            }
            $vars = join "|",map { quotemeta $_ } @envvar;
            print $vars ? "($vars)" : "(.*)";
            ' -- "$@"
    )"

    # Grep alias names
    _alias_NAMES="$(print -l ${(k)aliases} |
        egrep "^${grep_REGEXP}\$")"
    _list_alias_BODIES="alias "$(echo $_alias_NAMES|xargs)" | perl -pe 's/^/alias /'"
    if [[ "$_alias_NAMES" = "" ]] ; then
	# no aliases selected
	_list_alias_BODIES="true"
    fi

    # Grep function names
    _function_NAMES="$(print -l ${(k)functions} |
        egrep "^${grep_REGEXP}\$" |
        grep -v '='
        )"
    _list_function_BODIES="typeset -f "$(echo $_function_NAMES|xargs)
    if [[ "$_function_NAMES" = "" ]] ; then
	# no functions selected
	_list_function_BODIES="true"
    fi

    # Grep variable names
    # The egrep -v is crap and should be better
    _variable_NAMES="$(print -l ${(k)parameters} |
        egrep "^${grep_REGEXP}\$" |
        egrep -v '^([-?#!$*@_0]|zsh_eval_context|ZSH_EVAL_CONTEXT|LINENO|IFS|commands|functions|options|aliases|EUID|EGID|UID|GID)$' |
        egrep -v 'terminfo|funcstack|galiases|keymaps|parameters|jobdirs|dirstack|functrace|funcsourcetrace|zsh_scheduled_events|dis_aliases|dis_reswords|dis_saliases|modules|reswords|saliases|widgets|userdirs|historywords|nameddirs|termcap|dis_builtins|dis_functions|jobtexts|funcfiletrace|dis_galiases|builtins|history|jobstates'
        )"
    _list_variable_VALUES="typeset -p "$(echo $_variable_NAMES|xargs)" |
        grep -aFvf <(typeset -pr)
    "
    if [[ "$_variable_NAMES" = "" ]] ; then
	# no variables selected
	_list_variable_VALUES="true"
    fi
    export PARALLEL_ENV="$(
        eval $_list_alias_BODIES;
        eval $_list_function_BODIES;
        eval $_list_variable_VALUES;

    )";

    `which parallel` "$@";
    unset PARALLEL_ENV;
}

_old_env_parallel() {
  # env_parallel.zsh
  export PARALLEL_ENV="$(alias | perl -pe 's/^/alias /'; typeset -p |
    grep -aFvf <(typeset -pr) |
    egrep -iav 'ZSH_EVAL_CONTEXT|LINENO=| _=|aliases|^typeset [a-z_]+$'|
    egrep -av '^(typeset -A (commands|functions|options)|typeset IFS=|..$)|cyan';
    typeset -f)";
  parallel "$@";
  unset PARALLEL_ENV;
}
