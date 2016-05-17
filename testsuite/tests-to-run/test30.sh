#!/bin/bash

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj10 -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test of --eta'
  seq 1 10 | stdout parallel --eta "sleep 1; echo {}" | wc -l

echo '### Test of --eta with no jobs'
  stdout parallel --eta "sleep 1; echo {}" < /dev/null

echo '### Test of --progress'
  seq 1 10 | stdout parallel --progress "sleep 1; echo {}" | wc -l

echo '### Test of --progress with no jobs'
  stdout parallel --progress "sleep 1; echo {}" < /dev/null

echo '### --timeout --onall on remote machines: 2*slept 1, 2 jobs failed'
  parallel -j0 --timeout 6 --onall -S localhost,parallel@parallel-server1 'sleep {}; echo slept {}' ::: 1 8 9 ; echo jobs failed: $?
EOF
