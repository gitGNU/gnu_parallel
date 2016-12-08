#!/bin/bash

# Simple jobs that never fails
# Each should be taking 3-10s and be possible to run in parallel
# I.e.: No race conditions, no logins
cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo '### bug #42089: --results with arg > 256 chars (should be 1 char shorter)'
  parallel --results parallel_test_dir echo ::: 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456; 
  ls parallel_test_dir/1/
  rm -rf parallel_test_dir

echo '**'

echo '### Test slow arguments generation - https://savannah.gnu.org/bugs/?32834'; 
  seq 1 3 | parallel -j1 "sleep 2; echo {}" | parallel -kj2 echo

echo '**'

echo '### Are children killed if GNU Parallel receives TERM twice? There should be no sleep at the end'

  parallel -q bash -c 'sleep 120 & pid=$!; wait $pid' ::: 1 & 
    T=$!; 
    sleep 5; 
    pstree $$; 
    kill -TERM $T; 
    sleep 1; 
    pstree $$; 
    kill -TERM $T; 
    sleep 1; 
    pstree $$;

echo '**'

echo '### Are children killed if GNU Parallel receives INT twice? There should be no sleep at the end'

  parallel -q bash -c 'sleep 120 & pid=$!; wait $pid' ::: 1 & 
    T=$!; 
    sleep 5; 
    pstree $$; 
    kill -INT $T; 
    sleep 1; 
    pstree $$;

echo '**'

echo '### Do children receive --termseq signals'

  show_signals() { 
    perl -e 'for(keys %SIG) { $SIG{$_} = eval "sub { print STDERR \"Got $_\\n\"; }";} while(1){sleep 1}'; 
  }; 
  export -f show_signals; 
  echo | stdout parallel --termseq TERM,200,TERM,100,TERM,50,KILL,25 -u --timeout 1 show_signals; 
  echo | stdout parallel --termseq INT,200,TERM,100,KILL,25 -u --timeout 1 show_signals; 
  sleep 3;

echo '**'

echo '### bug #47644: Wrong slot number replacement when resuming'
  seq 0 20 | parallel -kj 4 --delay 0.2 --joblog /tmp/parallel-bug-47558 'sleep 1; echo {%} {=$_==10 and exit =}'; 
  seq 0 20 | parallel -kj 4 --resume --delay 0.2 --joblog /tmp/parallel-bug-47558 'sleep 1; echo {%} {=$_==110 and exit =}'

echo '**'

echo '### --pipepart --block -# (# < 0)'

  seq 1000 > /run/shm/parallel$$; 
    parallel -j2 -k --pipepart echo {#} :::: /run/shm/parallel$$; 
    parallel -j2 -k --block -1 --pipepart echo {#}-2 :::: /run/shm/parallel$$; 
    parallel -j2 -k --block -2 --pipepart echo {#}-4 :::: /run/shm/parallel$$; 
    parallel -j2 -k --block -10 --pipepart echo {#}-20 :::: /run/shm/parallel$$; 
    rm /run/shm/parallel$$

echo '**'

EOF
