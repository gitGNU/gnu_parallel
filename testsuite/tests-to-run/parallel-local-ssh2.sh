#!/bin/bash

# /tmp/parallel-local-ssh2 will by default be owned by me and should be writable by *@localhost
chmod 777 "$TMPDIR" 2>/dev/null

par_obey_servers_capacity_slf_reload() {
    echo "### bug #43518: GNU Parallel doesn't obey servers' jobs capacity when an ssh login file is reloaded"
    # Pre-20141106 Would reset the number of jobs run on all sshlogin if --slf changed
    # Thus must take at least 25 sec to run
    echo -e '1/lo\n1/csh@lo\n1/tcsh@lo\n1/parallel@lo\n' > /tmp/parallel.bug43518
    parallel --delay 0.1 -N0 echo 1/: '>>' /tmp/parallel.bug43518 ::: {1..100} &
    seq 30 |
	stdout /usr/bin/time -f %e parallel --slf /tmp/parallel.bug43518 'sleep {=$_=$_%3?0:10=}.{%}' |
	perl -ne '$_ > 25 and print "OK\n"'
    rm /tmp/parallel.bug43518
}

par_filter_hosts_slf() {
    echo '### --filter-hosts --slf <()'
    parallel --nonall --filter-hosts --slf <(echo localhost) echo OK
}

par_wd_no_such_dir() {
    echo '### --wd no-such-dir - csh'
    stdout parallel --wd /no-such-dir -S csh@localhost echo ::: "ERROR IF PRINTED"
    echo Exit code $?
    echo '### --wd no-such-dir - tcsh'
    stdout parallel --wd /no-such-dir -S tcsh@localhost echo ::: "ERROR IF PRINTED"
    echo Exit code $?
    echo '### --wd no-such-dir - bash'
    stdout parallel --wd /no-such-dir -S parallel@localhost echo ::: "ERROR IF PRINTED"
    echo Exit code $?
}

par_csh_newline_var() {
    echo '### bug #42725: csh with \n in variables'
    not_csh() { echo This is not csh/tcsh; }
    export -f not_csh
    parallel --env not_csh -S csh@lo not_csh ::: 1
    parallel --env not_csh -S tcsh@lo not_csh ::: 1
    parallel --env not_csh -S parallel@lo not_csh ::: 1
}


par_pipepart_remote() {
    echo '### bug #42999: --pipepart with remote does not work'
    seq 100 > /tmp/bug42999; chmod 600 /tmp/bug42999
    parallel --sshdelay 0.3 --pipepart --block 31 -a /tmp/bug42999 -k -S parallel@lo wc
    parallel --sshdelay 0.2 --pipepart --block 31 -a /tmp/bug42999 -k --fifo -S parallel@lo wc |
	perl -pe 's:(/tmp\S+par)\S+:${1}XXXXX:'
    parallel --sshdelay 0.1 --pipepart --block 31 -a /tmp/bug42999 -k --cat -S parallel@lo wc |
	perl -pe 's:(/tmp\S+par)\S+:${1}XXXXX:'
    rm /tmp/bug42999
}

par_cat_incorrect_exit_csh() {
    echo '### --cat gives incorrect exit value in csh'
    echo false | parallel --pipe --cat   -Scsh@lo 'cat {}; false' ; echo $?
    echo false | parallel --pipe --cat  -Stcsh@lo 'cat {}; false' ; echo $?
    echo true  | parallel --pipe --cat   -Scsh@lo 'cat {}; true' ; echo $?
    echo true  | parallel --pipe --cat  -Stcsh@lo 'cat {}; true' ; echo $?
}

par_cat_fifo_exit() {
    echo '### --cat and --fifo exit value in bash'
    echo true  | parallel --pipe --fifo -Slo 'cat {}; true' ; echo $?
    echo false | parallel --pipe --fifo -Slo 'cat {}; false' ; echo $?
}

par_env_parallel_fifo() {
    echo '### bug #50386: --fifo does not export function, --cat does'
    . `which env_parallel.bash`
    myfunc() {
	echo transferred non-exported func;
    }
    echo data from stdin |
	env_parallel --pipe -S lo --fifo 'cat {};myfunc'
    echo data from stdin |
	env_parallel --pipe -S lo --cat 'cat {};myfunc'
}

export -f $(compgen -A function | grep par_)
#compgen -A function | grep par_ | sort | parallel --delay $D -j$P --tag -k '{} 2>&1'
compgen -A function | grep par_ | sort |
    parallel --joblog /tmp/jl-`basename $0` --retries 3 -j300% --tag -k '{} 2>&1'
