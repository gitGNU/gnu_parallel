#!/bin/bash

par_print_before_halt_on_error() {
    echo '### What is printed before the jobs are killed'
    mytest() {
	HALT=$1
	(echo 0.1;
	    echo 3.2;
	    seq 0 7;
	    echo 0.3;
	    echo 8) |
	    parallel --tag --delay 0.1 -j4 -kq --halt $HALT \
		     perl -e 'sleep 1; sleep $ARGV[0]; print STDERR "",@ARGV,"\n"; '$HALT' > 0 ? exit shift : exit not shift;' {};
	echo exit code $?
    }
    export -f mytest
    parallel -j0 -k --tag mytest ::: -2 -1 0 1 2
}

par_testhalt() {
    testhalt_false() {
	echo '### testhalt --halt '$1;
	(yes 0 | head -n 10; seq 10) |
	    stdout parallel -kj4 --delay 0.23 --halt $1 \
		   'echo job {#}; sleep {= $_=0.3*($_+1+seq()) =}; exit {}'; echo $?;
    }
    testhalt_true() {
	echo '### testhalt --halt '$1;
	(seq 10; yes 0 | head -n 10) |
	    stdout parallel -kj4 --delay 0.17 --halt $1 \
		   'echo job {#}; sleep {= $_=0.3*($_+1+seq()) =}; exit {}'; echo $?;
    };
    export -f testhalt_false;
    export -f testhalt_true;

    stdout parallel -kj0 --delay 0.11 --tag testhalt_{4} {1},{2}={3} \
	::: now soon ::: fail success done ::: 0 1 2 30% 70% ::: true false |
	# Remove lines that only show up now and then
	perl -ne '/Starting no more jobs./ or print'
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort |
    parallel --joblog /tmp/jl-`basename $0` -j10 --tag -k '{} 2>&1'
