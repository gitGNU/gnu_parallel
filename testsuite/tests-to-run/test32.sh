#!/bin/bash

#cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | nice timeout -k 1 40 parallel -j0 -k -L1
echo '### Test of --retries - it should run 13 jobs in total'; 
  seq 0 12 | stdout parallel --retries 1 -S 12/localhost,1/:,parallel@parallel-server1 -uq \
  perl -e 'print "job{}\n";exit({})' | wc -l

echo '### Test of --retries - it should run 25 jobs in total'; 
  seq 0 12 | stdout parallel --retries 2 -S 12/localhost,1/:,parallel@parallel-server1 -uq \
  perl -e 'print "job{}\n";exit({})' | wc -l


echo '### Test of --retries - it should run 49 jobs in total'; 
  seq 0 12 | stdout parallel --retries 4 -S 12/localhost,1/:,parallel@parallel-server1 -uq \
  perl -e 'print "job{}\n";exit({})' | wc -l

#EOF
echo '### Bug with --retries'
seq 1 8 | parallel --retries 2 --sshlogin 8/localhost,8/: -j+0 "hostname; false" | wc -l
seq 1 8 | parallel --retries 2 --sshlogin 8/localhost,8/: -j+1 "hostname; false" | wc -l
seq 1 2 | parallel --retries 2 --sshlogin 8/localhost,8/: -j-1 "hostname; false" | wc -l
seq 1 1 | parallel --retries 2 --sshlogin 1/localhost,1/: -j1 "hostname; false"	 | wc -l
seq 1 1 | parallel --retries 2 --sshlogin 1/localhost,1/: -j9 "hostname; false"	 | wc -l
seq 1 1 | parallel --retries 2 --sshlogin 1/localhost,1/: -j0 "hostname; false"	 | wc -l
# Fails due to 0 jobslots
# seq 1 1 | parallel --retries 2 --sshlogin 1/localhost,1/: -j-1 "hostname; false" | wc -l

echo '### These were not affected by the bug'
seq 1 8 | parallel --retries 2 --sshlogin 1/localhost,9/: -j-1 "hostname; false" | wc -l
seq 1 8 | parallel --retries 2 --sshlogin 8/localhost,8/: -j-1 "hostname; false" | wc -l
seq 1 1 | parallel --retries 2 --sshlogin 1/localhost,1/:  "hostname; false"	 | wc -l
seq 1 4 | parallel --retries 2 --sshlogin 2/localhost,2/: -j-1 "hostname; false" | wc -l
seq 1 4 | parallel --retries 2 --sshlogin 2/localhost,2/: -j1 "hostname; false"	 | wc -l
seq 1 4 | parallel --retries 2 --sshlogin 1/localhost,1/: -j1 "hostname; false"	 | wc -l
seq 1 2 | parallel --retries 2 --sshlogin 1/localhost,1/: -j1 "hostname; false"  | wc -l

