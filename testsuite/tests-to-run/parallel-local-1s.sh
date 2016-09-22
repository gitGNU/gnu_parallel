#!/bin/bash

# Simple jobs that never fails
# Each should be taking 1-3s and be possible to run in parallel
# I.e.: No race conditions, no logins
cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo "### BUG: The length for -X is not close to max (131072)"; 

  seq 1 60000 | parallel -X echo {.} aa {}{.} {}{}d{} {}dd{}d{.} |head -n 1 |wc
  seq 1 60000 | parallel -X echo a{}b{}c |head -n 1 |wc
  seq 1 60000 | parallel -X echo |head -n 1 |wc
  seq 1 60000 | parallel -X echo a{}b{}c {} |head -n 1 |wc
  seq 1 60000 | parallel -X echo {}aa{} |head -n 1 |wc
  seq 1 60000 | parallel -X echo {} aa {} |head -n 1 |wc

echo '### Test --fifo under csh'

  csh -c "seq 3000000 | parallel -k --pipe --fifo 'sleep .{#};cat {}|wc -c ; false; echo \$status; false'"; echo exit $?

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

  parallel -k --tag               --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: tag true true
  parallel -k --tag               --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: tag false true
  parallel -k --tag               --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: tag false false
  parallel -k --tag               --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: tag true false
  parallel -k                     --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: true true
  parallel -k                     --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: false true
  parallel -k                     --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: false false
  parallel -k                     --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: true false
  parallel -k       --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: line-buffer true true
  parallel -k       --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: line-buffer false true
  parallel -k       --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: line-buffer false false
  parallel -k --tag --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: tag line-buffer true false
  parallel -k --tag --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: tag line-buffer true true
  parallel -k --tag --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: tag line-buffer false true
  parallel -k --tag --line-buffer --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: tag line-buffer false false
  parallel -k --tag --line-buffer --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: tag line-buffer true false
  parallel -k --files             --compress --compress-program 'cat;true'  --decompress-program 'cat;true'  echo ::: files true true   | parallel rm
  parallel -k --files             --compress --compress-program 'cat;false' --decompress-program 'cat;true'  echo ::: files false true  | parallel rm
  parallel -k --files             --compress --compress-program 'cat;false' --decompress-program 'cat;false' echo ::: files false false | parallel rm
  parallel -k --files             --compress --compress-program 'cat;true'  --decompress-program 'cat;false' echo ::: files true false  | parallel rm

echo 'bug #44250: pxz complains File format not recognized but decompresses anyway'

  # The first line dumps core if run from make file. Why?!
  stdout parallel --compress --compress-program pxz ls /{} ::: OK-if-missing-file
  stdout parallel --compress --compress-program pixz --decompress-program 'pixz -d' ls /{}  ::: OK-if-missing-file
  stdout parallel --compress --compress-program pixz --decompress-program 'pixz -d' true ::: OK-if-no-output
  stdout parallel --compress --compress-program pxz true ::: OK-if-no-output

echo 'bug #41613: --compress --line-buffer no newline';

  perl -e 'print "It worked"'| parallel --pipe --compress --line-buffer cat; echo

echo 'bug #48658: --linebuffer --files';

  doit() { parallel --files --linebuffer --compress-program $1 seq ::: 100000 | wc -l ; }; 
  export -f doit; 
  parallel -k doit ::: zstd pzstd clzip lz4 lzop pigz pxz gzip plzip pbzip2 lzma xz lzip bzip2 lbzip2 lrz

  doit() { parallel --results /tmp/par48658$1 --linebuffer --compress-program $1 seq ::: 100000 | wc -l ; rm -rf "/tmp/par48658$1"; }; 
  export -f doit; 
  parallel -k doit ::: zstd pzstd clzip lz4 lzop pigz pxz gzip plzip pbzip2 lzma xz lzip bzip2 lbzip2 lrz

  doit() { parallel --linebuffer --compress-program $1 seq ::: 100000 | wc -l ; }; 
  export -f doit; 
  parallel -k doit ::: zstd pzstd clzip lz4 lzop pigz pxz gzip plzip pbzip2 lzma xz lzip bzip2 lbzip2 lrz

echo '**'

echo "### Test -I"; 

  seq 1 10 | parallel -k 'seq 1 {} | parallel -k -I :: echo {} ::'

echo "### Test -X -I"; 

  seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -X -k -I :: echo a{} b::'

echo "### Test -m -I"; 

  seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -m -k -I :: echo a{} b::'


EOF
