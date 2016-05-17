#!/bin/bash

cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo "### --line-buffer"
  seq 10 | parallel -j20 --line-buffer  'seq {} 10 | pv -qL 10' > /tmp/parallel_l$$; 
  seq 10 | parallel -j20                'seq {} 10 | pv -qL 10' > /tmp/parallel_$$; 
  cat /tmp/parallel_l$$ | wc; 
  diff /tmp/parallel_$$ /tmp/parallel_l$$ >/dev/null ; 
  echo These must diff: $?; 
  rm /tmp/parallel_l$$ /tmp/parallel_$$

echo "### --pipe --line-buffer"
  seq 200| parallel -N10 -L1 --pipe  -j20 --line-buffer --tagstring {#} pv -qL 10 > /tmp/parallel_pl$$; 
  seq 200| parallel -N10 -L1 --pipe  -j20               --tagstring {#} pv -qL 10 > /tmp/parallel_p$$; 
  cat /tmp/parallel_pl$$ | wc; 
  diff /tmp/parallel_p$$ /tmp/parallel_pl$$ >/dev/null ; 
  echo These must diff: $?; 
  rm /tmp/parallel_pl$$ /tmp/parallel_p$$

echo "### --pipe --line-buffer --compress"
  seq 200| parallel -N10 -L1 --pipe  -j20 --line-buffer --compress --tagstring {#} pv -qL 10 | wc

echo "### bug #41482: --pipe --compress blocks at different -j/seq combinations"
  seq 1 | parallel -k -j2 --compress -N1 -L1 --pipe cat;
  echo echo 1-4 + 1-4
    seq 4 | parallel -k -j3 --compress -N1 -L1 -vv echo;
  echo 4 times wc to stderr to stdout
    (seq 4 | parallel -k -j3 --compress -N1 -L1 --pipe wc '>&2') 2>&1 >/dev/null
  echo 1 2 3 4
    seq 4 | parallel -k -j3 --compress echo;
  echo 1 2 3 4
    seq 4 | parallel -k -j1 --compress echo;
  echo 1 2
    seq 2 | parallel -k -j1 --compress echo;
  echo 1 2 3
    seq 3 | parallel -k -j2 --compress -N1 -L1 --pipe cat;

echo "### bug #41609: --compress fails"
  seq 12 | parallel --compress --compress-program bzip2 -k seq {} 1000000 | md5sum
  seq 12 | parallel --compress -k seq {} 1000000 | md5sum

echo "### --compress race condition (use nice): Fewer than 400 would run"
# 2>/dev/null to ignore Warning: Starting 45 processes took > 2 sec.
  seq 400| nice parallel -j200 --compress echo 2>/dev/null | wc

echo "### -v --pipe: Dont spawn too many - 1 is enough"
  seq 1 | parallel -j10 -v --pipe cat

echo "### Test -N0 and --tagstring (fails)"
  echo tagstring arg | parallel --tag -N0 echo foo

echo "### Test -I"; 
  seq 1 10 | parallel -k 'seq 1 {} | parallel -k -I :: echo {} ::'

echo "### Test -X -I"; 
  seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -X -k -I :: echo a{} b::'

echo "### Test -m -I"; 
  seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -m -k -I :: echo a{} b::'


echo "### bug #36659: --sshlogin strips leading slash from ssh command"
  parallel --sshlogin '/usr/bin/ssh localhost' echo ::: OK

echo "### bug #36660: --workdir mkdir does not use --sshlogin custom ssh"
  rm -rf /tmp/foo36660; 
  cd /tmp; echo OK > parallel_test36660.txt; 
  ssh () { echo Failed; }; 
  export -f ssh; 
  parallel --workdir /tmp/foo36660/bar --transfer --sshlogin '/usr/bin/ssh localhost' cat ::: parallel_test36660.txt; 
  rm -rf /tmp/foo36660 parallel_test36660.txt

echo "bug #36657: --load does not work with custom ssh"
  ssh () { echo Failed; }; 
  export -f ssh; 
  parallel --load=1000% -S "/usr/bin/ssh localhost" echo ::: OK


EOF
