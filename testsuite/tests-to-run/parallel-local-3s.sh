#!/bin/bash

# Simple jobs that never fails
# Each should be taking 3-10s and be possible to run in parallel
# I.e.: No race conditions, no logins

par_results_arg_256() {
    echo '### bug #42089: --results with arg > 256 chars (should be 1 char shorter)'
    parallel --results parallel_test_dir echo ::: 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456;
    ls parallel_test_dir/1/
    rm -rf parallel_test_dir
}

par_slow_args_generation() {
    echo '### Test slow arguments generation - https://savannah.gnu.org/bugs/?32834'
    seq 1 3 | parallel -j1 "sleep 2; echo {}" | parallel -kj2 echo
}

par_kill_term_twice() {
    echo '### Are children killed if GNU Parallel receives TERM twice? There should be no sleep at the end'

    parallel -q bash -c 'sleep 120 & pid=$!; wait $pid' ::: 1 &
    T=$!
    sleep 5
    pstree $$
    kill -TERM $T
    sleep 1
    pstree $$
    kill -TERM $T
    sleep 1
    pstree $$
}

par_kill_int_twice() {
    echo '### Are children killed if GNU Parallel receives INT twice? There should be no sleep at the end'

    parallel -q bash -c 'sleep 120 & pid=$!; wait $pid' ::: 1 &
    T=$!
    sleep 5
    pstree $$
    kill -INT $T
    sleep 1
    pstree $$
}

par_children_receive_sig() {
    echo '### Do children receive --termseq signals'

    show_signals() {
	perl -e 'for(keys %SIG) { $SIG{$_} = eval "sub { print STDERR \"Got $_\\n\"; }";} while(1){sleep 1}';
    }
    export -f show_signals
    echo | stdout parallel --termseq TERM,200,TERM,100,TERM,50,KILL,25 -u \
	--timeout 1 show_signals

    echo | stdout parallel --termseq INT,200,TERM,100,KILL,25 -u \
	--timeout 1 show_signals
    sleep 3
}

par_wrong_slot_rpl_resume() {
    echo '### bug #47644: Wrong slot number replacement when resuming'
    seq 0 20 |
    parallel -kj 4 --delay 0.2 --joblog /tmp/parallel-bug-47558 \
	'sleep 1; echo {%} {=$_==10 and exit =}'
    seq 0 20 |
    parallel -kj 4 --resume --delay 0.2 --joblog /tmp/parallel-bug-47558 \
	'sleep 1; echo {%} {=$_==110 and exit =}'
}

par_pipepart_block() {
    echo '### --pipepart --block -# (# < 0)'

    seq 1000 > /run/shm/parallel$$
    parallel -j2 -k --pipepart echo {#} :::: /run/shm/parallel$$
    parallel -j2 -k --block -1 --pipepart echo {#}-2 :::: /run/shm/parallel$$
    parallel -j2 -k --block -2 --pipepart echo {#}-4 :::: /run/shm/parallel$$
    parallel -j2 -k --block -10 --pipepart echo {#}-20 :::: /run/shm/parallel$$
    rm /run/shm/parallel$$
}

par_keeporder_roundrobin() {
    echo 'bug #50081: --keep-order --round-robin should give predictable results'

    export PARALLEL="-j13 --block 1m --pipe --roundrobin"
    random500m() {
	< /dev/zero openssl enc -aes-128-ctr -K 1234 -iv 1234 2>/dev/null |
	    head -c 500m;
    }
    a=$(random500m | parallel -k 'echo {#} $(md5sum)' | sort)
    b=$(random500m | parallel -k 'echo {#} $(md5sum)' | sort)
    c=$(random500m | parallel    'echo {#} $(md5sum)' | sort)
    if [ "$a" == "$b" ] ; then
	# Good: -k should be == -k
	if [ "$a" == "$c" ] ; then
	    # Bad: without -k the command should give different output
	    echo 'Broken: a == c'
	    printf "$a\n$b\n$c\n"
	else
	    echo OK
	fi
    else
	echo 'Broken: a <> b'
	printf "$a\n$b\n$c\n"
    fi
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort | parallel -j6 --tag -k '{} 2>&1'
