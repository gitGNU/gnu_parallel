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

EOF
