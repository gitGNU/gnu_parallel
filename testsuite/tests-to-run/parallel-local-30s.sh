#!/bin/bash

# Simple jobs that never fails
# Each should be taking 30-100s and be possible to run in parallel
# I.e.: No race conditions, no logins

par_testhalt() {
    testhalt() {
	echo '### testhalt --halt '$1;
	# Append "00$_" so we can see the original value
	(yes 0 | head -n 10; seq 10) |
	    stdout parallel -kj4 --halt $1 'sleep {= $_=0.2*($_+1+seq()) =}; exit {}'; echo $?;
	(seq 10; yes 0 | head -n 10) |
	    stdout parallel -kj4 --halt $1 'sleep {= $_=0.2*($_+1+seq()) =}; exit {}'; echo $?;
    };
    export -f testhalt;

    stdout parallel -kj0 testhalt {1},{2}={3} \
	::: now soon ::: fail success ::: 0 1 2 30% 70% |
    # Remove lines that only show up now and then
    perl -ne '/Starting no more jobs./ or print'
}

par_race_condition1() {
    echo '### Test race condition on 8 CPU (my laptop)'
    seq 1 5000000 > /tmp/parallel_race_cond
    seq 1 10 | parallel -k "cat /tmp/parallel_race_cond | parallel --pipe --recend '' -k gzip >/dev/null; echo {}"
    rm /tmp/parallel_race_cond
}

par_tmp_full() {
    # Assume /tmp/shm is easy to fill up
    export SHM=/tmp/shm/parallel
    mkdir -p $SHM
    sudo umount -l $SHM 2>/dev/null
    sudo mount -t tmpfs -o size=10% none $SHM

    echo "### Test --tmpdir running full. bug #40733 was caused by this"
    stdout parallel -j1 --tmpdir $SHM cat /dev/zero ::: dummy
}

par_memory_leak() {
    a_run() {
	seq $1 |time -v parallel true 2>&1 |
	grep 'Maximum resident' |
	field 6;
    }
    export -f a_run
    echo "### Test for memory leaks"
    echo "Of 100 runs of 1 job at least one should be bigger than a 3000 job run"
    small_max=$(seq 100 | parallel a_run 1 | jq -s max)
    big=$(a_run 3000)
    if [ $small_max -lt $big ] ; then
	echo "Bad: Memleak likely."
    else
	echo "Good: No memleak detected."	
    fi
}

par_linebuffer_matters_compress_tag() {
    echo "### (--linebuffer) --compress --tag should give different output"
    nolbfile=$(mktemp)
    lbfile=$(mktemp)
    controlfile=$(mktemp)
    randomfile=$(mktemp)
    # Random data because it does not compress well
    # forcing the compress tool to spit out compressed blocks
    head -c 10000000 /dev/urandom > $randomfile 

    parallel -j0 --compress --tag --delay 1 "shuf $randomfile; sleep 1; shuf $randomfile; true" ::: {0..9} |
	perl -ne '/^(\S+)\t/ and print "$1\n"' | uniq > $nolbfile &
    parallel -j0 --compress --tag --delay 1 "shuf $randomfile; sleep 1; shuf $randomfile; true" ::: {0..9} |
	perl -ne '/^(\S+)\t/ and print "$1\n"' | uniq > $controlfile &
    parallel -j0 --line-buffer --compress --tag --delay 1 "shuf $randomfile; sleep 1; shuf $randomfile; true" ::: {0..9} |
	perl -ne '/^(\S+)\t/ and print "$1\n"' | uniq > $lbfile &
    wait

    nolb="$(cat $nolbfile)"
    control="$(cat $controlfile)"
    lb="$(cat $lbfile)"
    rm $nolbfile $lbfile $controlfile $randomfile

    if [ "$nolb" == "$control" ] ; then
	if [ "$lb" == "$nolb" ] ; then
	    echo "BAD: --linebuffer makes no difference"
	else
	    echo "OK: --linebuffer makes a difference"
	fi
    else
	echo "BAD: control and nolb are not the same"
    fi
}

par_linebuffer_matters_compress() {
    echo "### (--linebuffer) --compress should give different output"
    random_data_with_id_prepended() {
	perl -pe 's/^/'$1'/' /dev/urandom |
	  pv -qL 300000 | head -c 1000000
    }
    export -f random_data_with_id_prepended

    nolb=$(seq 10 |
      parallel -j0 --compress random_data_with_id_prepended {#} |
      field 1 | uniq)
    lb=$(seq 10 |
      parallel -j0 --linebuffer --compress random_data_with_id_prepended {#} |
      field 1 | uniq)
    if [ "$lb" == "$nolb" ] ; then
	echo "BAD: --linebuffer makes no difference"
    else
	echo "OK: --linebuffer makes a difference"
    fi
}

par_memfree() {
    echo '### test memfree'
    parallel --memfree 1k echo Free mem: ::: 1k
    stdout parallel --timeout 20 --argsep II parallel --memfree 1t echo Free mem: ::: II 1t
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort |
    parallel -j0 --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1'
