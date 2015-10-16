#!/bin/bash

# Simple jobs that never fails
# Each should be taking 10-30s and be possible to run in parallel
# I.e.: No race conditions, no logins
cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo '### bug #46214: Using --pipepart doesnt spawn multiple jobs in version 20150922'
  seq 1000000 > /tmp/num1000000; 
  stdout parallel --pipepart --progress -a /tmp/num1000000 --block 10k -j0 true |grep 1:local

echo '**'

testhalt() { 
  echo '### testhalt --halt '$1; 
  (yes 0 | head -n 10; seq 10) | stdout parallel -kj4 --halt $1 'sleep {= $_=$_*0.3+1 =}; exit {}'; echo $?; 
  (seq 10; yes 0 | head -n 10) | stdout parallel -kj4 --halt $1 'sleep {= $_=$_*0.3+1 =}; exit {}'; echo $?; 
}; 
export -f testhalt; 
  parallel -kj0 testhalt ::: now,fail=0 now,fail=1 now,fail=2 now,fail=30%  now,fail=70% 
    soon,fail=0 soon,fail=1 soon,fail=2 soon,fail=30% soon,fail=70% 
    now,success=0 now,success=1 now,success=2 now,success=30% now,success=70% 
    soon,success=0 soon,success=1 soon,success=2 soon,success=30% now,success=70%

echo '**'

echo '### Test --halt-on-error 0'; 
  (echo "sleep 1;true"; echo "sleep 2;false";echo "sleep 3;true") | parallel -j10 --halt-on-error 0; 
  echo $?; 

  (echo "sleep 1;true"; echo "sleep 2;false";echo "sleep 3;true";echo "sleep 4; non_exist") | parallel -j10 --halt 0; 
  echo $?

echo '**'

echo '### Test --halt-on-error 1'; 
  (echo "sleep 1;true"; echo "sleep 2;false";echo "sleep 3;true") | parallel -j10 --halt-on-error 1; 
  echo $?; 

  (echo "sleep 1;true"; echo "sleep 2; non_exist";echo "sleep 3;true";echo "sleep 4; false") | parallel -j10 --halt 1; 
  echo $?

echo '**'

echo '### Test --halt-on-error 2'; 
  (echo "sleep 1;true"; echo "sleep 2;false";echo "sleep 3;true") | parallel -j10 --halt-on-error 2; 
  echo $?; 

  (echo "sleep 1;true"; echo "sleep 2;false";echo "sleep 3;true";echo "sleep 4; non_exist") | parallel -j10 --halt 2; 
  echo $?

echo '**'

echo '### Test --halt -1'; 
  (echo "sleep 1;false"; echo "sleep 2;true";echo "sleep 3;false") | parallel -j10 --halt-on-error -1; 
  echo $?; 

  (echo "sleep 1;false"; echo "sleep 2;true";echo "sleep 3;false";echo "sleep 4; non_exist") | parallel -j10 --halt -1; 
  echo $?

echo '**'

echo '### Test --halt -2'; 
  (echo "sleep 1;false"; echo "sleep 2;true";echo "sleep 3;false") | parallel -j10 --halt-on-error -2; 
  echo $?; 

  (echo "sleep 1;false"; echo "sleep 2;true";echo "sleep 3;false";echo "sleep 4; non_exist") | parallel -j10 --halt -2; 
  echo $?

echo '**'

echo '### Test first dying print --halt-on-error 1'; 
  (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt 1 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit shift'; 
  echo exit code $?

echo '### Test last dying print --halt-on-error 2'; 
  (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt 2 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit shift'; 
  echo exit code $?

echo '### Test last dying print --halt-on-error -1'; 
  (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt -1 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit not shift'; 
  echo exit code $?

echo '### Test last dying print --halt-on-error -2'; 
  (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt -2 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit not shift'; 
  echo exit code $?

echo '**'

echo '### test memfree'
  parallel --memfree 1k echo Free mem: ::: 1k
  stdout parallel --timeout 3 --argsep II parallel --memfree 1t echo Free mem: ::: II 1t

echo '**'


EOF
