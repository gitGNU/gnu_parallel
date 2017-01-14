#!/bin/bash

par_load_more_10s() {
    echo '### Test --load locally - should take >10s'
    echo '# This will run 10 processes in parallel for 10s'; 
    seq 10 | parallel --nice 19 --timeout 13 -j0 -N0 "gzip < /dev/zero > /dev/null" &
    sleep 2; stdout /usr/bin/time -f %e parallel --load 10 sleep ::: 1 | perl -ne '$_ > 10 and print "OK\n"'
}

par_load_file_less_10s() {
    echo '### Test --load read from a file - less than 10s'
    echo '# This will run 10 processes in parallel for 10s'
    seq 10 | parallel --nice 19 --timeout 10 -j0 -N0 "gzip < /dev/zero > /dev/null" &
    ( echo 8 > /tmp/parallel_load_file2; sleep 10; echo 1000 > /tmp/parallel_load_file2 ) &
    sleep 1
    stdout /usr/bin/time -f %e parallel --load /tmp/parallel_load_file2 sleep ::: 1 |
	perl -ne '$_ > 0.1 and $_ < 20 and print "OK\n"'
    rm /tmp/parallel_load_file2
}

par_load_file_more_10s() {
    echo '### Test --load read from a file - more than 10s'
    echo '# This will run 10 processes in parallel for 10s'
    seq 10 | parallel --nice 19 --timeout 10 -j0 -N0 "gzip < /dev/zero > /dev/null" &
    ( echo 8 > /tmp/parallel_load_file; sleep 10; echo 1000 > /tmp/parallel_load_file ) &
    sleep 1
    stdout /usr/bin/time -f %e parallel --load /tmp/parallel_load_file sleep ::: 1 |
	perl -ne '$_ > 9 and print "OK\n"'
    rm /tmp/parallel_load_file
}

export -f $(compgen -A function | grep par_)
#compgen -A function | grep par_ | sort | parallel --delay $D -j$P --tag -k '{} 2>&1'
compgen -A function | grep par_ | sort |
    parallel --joblog /tmp/jl-`basename $0` -j200% --tag -k '{} 2>&1'
