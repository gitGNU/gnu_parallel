#!/bin/bash

# Simple jobs that never fails
# Each should be taking 1-3s and be possible to run in parallel
# I.e.: No race conditions, no logins
cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test --fifo under csh'
  csh -c "seq 3000000 | parallel -k --pipe --fifo 'sleep .{#};cat {}|wc -c ; false; echo \$status; false'"; echo exit $?

EOF
