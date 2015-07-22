#!/bin/bash

# Simple jobs that never fails
# Each should be taking 0.3-1s and be possible to run in parallel
# I.e.: No race conditions, no logins

SMALLDISK=${SMALLDISK:-/mnt/ram}
export SMALLDISK
(
  cd /tmp
  sudo umount -l smalldisk.img
  dd if=/dev/zero of=smalldisk.img bs=100k count=1k
  yes|mkfs smalldisk.img
  mkdir -p /mnt/ram
  sudo mount smalldisk.img /mnt/ram
  sudo chmod 777 /mnt/ram
) >/dev/null 2>/dev/null

cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test exit val - true'; 
  echo true | parallel; 
  echo $?

echo '**'

echo '### Test exit val - false'; 
  echo false | parallel; 
  echo $?

echo '**'

echo '### Test bug #43284: {%} and {#} with --xapply'; 
  parallel --xapply 'echo {1} {#} {%} {2}' ::: a ::: b; 
  parallel -N2 'echo {%}' ::: a b

echo '**'

echo '### Test bug #43376: {%} and {#} with --pipe'
  echo foo | parallel -q --pipe -k echo {#}
  echo foo | parallel --pipe -k echo {%}
  echo foo | parallel -q --pipe -k echo {%}
  echo foo | parallel --pipe -k echo {#}

echo '**'

echo '### {= and =} in different groups separated by space'
  parallel echo {= s/a/b/ =} ::: a
  parallel echo {= s/a/b/=} ::: a
  parallel echo {= s/a/b/=}{= s/a/b/=} ::: a
  parallel echo {= s/a/b/=}{=s/a/b/=} ::: a
  parallel echo {= s/a/b/=}{= {= s/a/b/=} ::: a
  parallel echo {= s/a/b/=}{={=s/a/b/=} ::: a
  parallel echo {= s/a/b/ =} {={==} ::: a
  parallel echo {={= =} ::: a
  parallel echo {= {= =} ::: a
  parallel echo {= {= =} =} ::: a

echo '**'

echo '### {} as part of the command'
  echo p /bin/ls | parallel l{= s/p/s/ =}
  echo /bin/ls-p | parallel --colsep '-' l{=2 s/p/s/ =} {1}
  echo s /bin/ls | parallel l{}
  echo /bin/ls | parallel ls {}
  echo ls /bin/ls | parallel {}
  echo ls /bin/ls | parallel

echo '**'

echo '### bug #43817: Some JP char cause problems in positional replacement strings'
  parallel -k echo ::: '�<�>' '�<1 $_=2�>' 'ワ'
  parallel -k echo {1} ::: '�<�>' '�<1 $_=2�>' 'ワ'
  parallel -Xj1 echo ::: '�<�>' '�<1 $_=2�>' 'ワ'
  parallel -Xj1 echo {1} ::: '�<�>' '�<1 $_=2�>' 'ワ'

echo '**'

echo '### --rpl % that is a substring of longer --rpl %D'
parallel --plus --rpl '%' 
  --rpl '%D $_=::shell_quote(::dirname($_));' --rpl '%B s:.*/::;s:\.[^/.]+$::;' --rpl '%E s:.*\.::' 
  'echo {}=%;echo %D={//};echo %B={/.};echo %E={+.};echo %D/%B.%E={}' ::: a.b/c.d/e.f

echo '**'

echo '### Disk full'
cat /dev/zero >$SMALLDISK/out; 
  parallel --tmpdir $SMALLDISK echo ::: OK; 
  rm $SMALLDISK/out

echo '**'

echo '### bug #44546: If --compress-program fails: fail'
  parallel --line-buffer --compress-program false echo \;ls ::: /no-existing; echo $?
  parallel --tag --line-buffer --compress-program false echo \;ls ::: /no-existing; echo $?
  (parallel --files --tag --line-buffer --compress-program false echo \;sleep 1\;ls ::: /no-existing; echo $?) | tail -n1
  parallel --tag --compress-program false echo \;ls ::: /no-existing; echo $?
  parallel --line-buffer --compress-program false echo \;ls ::: /no-existing; echo $?
  parallel --compress-program false echo \;ls ::: /no-existing; echo $?

echo 'bug #41613: --compress --line-buffer - no newline';
  echo 'pipe compress tagstring'
  perl -e 'print "O"'| parallel --compress --tagstring {#} --pipe --line-buffer cat;  echo "K"
  echo 'pipe compress notagstring'
  perl -e 'print "O"'| parallel --compress --pipe --line-buffer cat;  echo "K"
  echo 'pipe nocompress tagstring'
  perl -e 'print "O"'| parallel --tagstring {#} --pipe --line-buffer cat;  echo "K"
  echo 'pipe nocompress notagstring'
  perl -e 'print "O"'| parallel --pipe --line-buffer cat;  echo "K"
  echo 'nopipe compress tagstring'
  parallel --compress --tagstring {#} --line-buffer echo {} O ::: -n;  echo "K"
  echo 'nopipe compress notagstring'
  parallel --compress --line-buffer echo {} O ::: -n;  echo "K"
  echo 'nopipe nocompress tagstring'
  parallel --tagstring {#} --line-buffer echo {} O ::: -n;  echo "K"
  echo 'nopipe nocompress notagstring'
  parallel --line-buffer echo {} O ::: -n;  echo "K"

echo 'Compress with failing (de)compressor'
  parallel -k --tag --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: tag true true
  parallel -k --tag --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: tag false true
  parallel -k --tag --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: tag false false
  parallel -k --tag --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: tag true false
  parallel -k --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: true true
  parallel -k --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: false true
  parallel -k --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: false false
  parallel -k --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: true false
  parallel -k --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: line-buffer true true
  parallel -k --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: line-buffer false true
  parallel -k --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: line-buffer false false
  parallel -k --tag --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: tag line-buffer true false
  parallel -k --tag --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: tag line-buffer true true
  parallel -k --tag --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: tag line-buffer false true
  parallel -k --tag --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: tag line-buffer false false
  parallel -k --tag --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: tag line-buffer true false
  parallel -k --files --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: files true true   | parallel rm
  parallel -k --files --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: files false true  | parallel rm
  parallel -k --files --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: files false false | parallel rm
  parallel -k --files --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: files true false  | parallel rm

echo 'bug #44250: pxz complains File format not recognized but decompresses anyway'
  # The first line dumps core if run from make file. Why?!
  stdout parallel --compress --compress-program pxz ls /{} ::: OK-if-missing-file
  stdout parallel --compress --compress-program pixz --decompress-program 'pixz -d' ls /{}  ::: OK-if-missing-file
  stdout parallel --compress --compress-program pixz --decompress-program 'pixz -d' true ::: OK-if-no-output
  stdout parallel --compress --compress-program pxz true ::: OK-if-no-output

echo 'bug #41613: --compress --line-buffer no newline';
  perl -e 'print "It worked"'| parallel --pipe --compress --line-buffer cat; echo

echo '### bug #44614: --pipepart --header off by one'
  seq 10 >/tmp/parallel_44616; 
    parallel --pipepart -a /tmp/parallel_44616 -k --block 5 'echo foo; cat'; 
    parallel --pipepart -a /tmp/parallel_44616 -k --block 2 --regexp --recend 3'\n' 'echo foo; cat'; 
    rm /tmp/parallel_44616

echo '### TMUX not found'
  TMUX=not-existing parallel --tmux echo ::: 1

echo '**'

parallel -j4 --halt 2 ::: 'sleep 1' burnP6 false; killall burnP6 && echo ERROR: burnP6 should be killed
parallel -j4 --halt -2 ::: 'sleep 1' burnP5 true; killall burnP5 && echo ERROR: burnP5 should be killed

parallel --halt error echo ::: should not print
parallel --halt soon echo ::: should not print
parallel --halt now echo ::: should not print

echo '**'

echo '### bug #44995: parallel echo {#} ::: 1 2 ::: 1 2'

parallel -k echo {#} ::: 1 2 ::: 1 2

echo '**'

testquote() { printf '"#&/\n()*=?'"'" | PARALLEL_SHELL=$1 parallel -0 echo; }; 
  export -f testquote; 
  parallel --tag -k testquote ::: ash bash csh dash fdsh fish fizsh ksh ksh93 mksh pdksh posh rbash rc rzsh sash sh static-sh tcsh yash zsh

echo '**'

EOF
echo '### 1 .par file from --files expected'
find /tmp{/*,}/*.{par,tms,tmx} 2>/dev/null -mmin -10 | wc -l
find /tmp{/*,}/*.{par,tms,tmx} 2>/dev/null -mmin -10 | parallel rm

sudo umount -l /tmp/smalldisk.img