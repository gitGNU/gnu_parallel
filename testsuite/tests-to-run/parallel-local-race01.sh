#!/bin/bash

par_print_before_halt_on_error() {
    echo '### What is printed before the jobs are killed'
    mytest() {
	HALT=$1
	(echo 0;
	    echo 3;
	    seq 0 7;
	    echo 0;
	    echo 8) |
	parallel --tag -j10 -kq --halt $HALT perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; '$HALT' > 0 ? exit shift : exit not shift;';
	echo exit code $?
    }
    export -f mytest
    parallel -j0 -k --tag mytest ::: -2 -1 0 1 2
}

par_testhalt() {
    testhalt_false() {
	echo '### testhalt --halt '$1;
	(yes 0 | head -n 10; seq 10) |
	    stdout parallel -kj4 --halt $1 \
		   'sleep {= $_=0.3*($_+1+seq()) =}; exit {}'; echo $?;
    }
    testhalt_true() {
	(seq 10; yes 0 | head -n 10) |
	    stdout parallel -kj4 --halt $1 \
		   'sleep {= $_=0.3*($_+1+seq()) =}; exit {}'; echo $?;
    };
    export -f testhalt_false;
    export -f testhalt_true;

    stdout parallel -kj0 testhalt_{4} {1},{2}={3} \
	::: now soon ::: fail success ::: 0 1 2 30% 70% ::: true false |
    # Remove lines that only show up now and then
    perl -ne '/Starting no more jobs./ or print'
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort |
    parallel --joblog /tmp/jl-`basename $0` -j10 --tag -k '{} 2>&1'
