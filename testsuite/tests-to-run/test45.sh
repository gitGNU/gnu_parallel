#!/bin/bash

SERVER1=parallel-server3
SERVER2=parallel-server1

# -L1 will join lines ending in ' '
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj10 -k --joblog /tmp/jl-`basename $0` -L1
echo '### bug #32191: Deep recursion on subroutine main::get_job_with_sshlogin'
  seq 1 150 | stdout nice parallel -j9 --retries 2 -S localhost,: "/bin/non-existant 2>/dev/null"

EOF
