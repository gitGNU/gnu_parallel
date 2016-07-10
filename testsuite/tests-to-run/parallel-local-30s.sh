#!/bin/bash

# Simple jobs that never fails
# Each should be taking 30-100s and be possible to run in parallel
# I.e.: No race conditions, no logins

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
    sudo umount -l $SHM
    sudo mount -t tmpfs -o size=10% none $SHM

    echo "### Test --tmpdir running full. bug #40733 was caused by this"
    stdout parallel -j1 --tmpdir $SHM cat /dev/zero ::: dummy
}

par_bug_48290() {
    echo "### bug #48290: round-robin does not distribute data based on business"
    echo "Jobslot 1 is 256 times slower than jobslot 4 and should get much less data"
    yes "$(seq 1000|xargs)" | head -c 30M |
    parallel --tagstring {%} --linebuffer --compress -j4 --roundrobin --pipe --block 10k \
      pv -qL '{= $_=int( $job->slot()**4/2+1) =}'0000 |
      perl -ne '/^\d+/ and $s{$&}++; END { print map { "$_\n" } sort { $s{$b} <=> $s{$a} } keys %s}'
}

par_memory_leak() {
    a_run() {
	seq $1 |time -v parallel true 2>&1 |
	grep 'Maximum resident' |
	field 6;
    }
    export -f a_run
    echo "### Test for memory leaks"
    echo "Of 10 runs of 1 job at least one should be bigger than a 3000 job run"
    small_max=$(seq 10 | parallel a_run 1 | jq -s max)
    big=$(a_run 3000)
    if [ $small_max -lt $big ] ; then
	echo "Bad: Memleak likely."
    else
	echo "Good: No memleak detected."	
    fi
}


export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort | parallel -j6 --tag -k '{} 2>&1'
