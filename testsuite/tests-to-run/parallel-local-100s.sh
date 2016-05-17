#!/bin/bash

# Simple jobs that never fails
# Each should be taking >100s and be possible to run in parallel
# I.e.: No race conditions, no logins

TMP5G=${TMP5G:-/dev/shm}
export TMP5G

cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test of --retries on unreachable host'
  seq 2 | stdout parallel -k --retries 2 -v -S 4.3.2.1,: echo

echo '**'

echo "### Test Force outside the file handle limit, 2009-02-17 Gave fork error"
  (echo echo Start; seq 1 20000 | perl -pe 's/^/true /'; echo echo end) | stdout parallel -uj 0 | egrep -v 'processes took|adjusting'

echo '**'

echo '### Test if we can deal with output > 4 GB'
  echo | nice parallel --tmpdir $TMP5G -q perl -e '$a="x"x1000000;for(0..4300){print $a}' | nice md5sum

echo '**'

echo 'bug #41613: --compress --line-buffer no --tagstring';
  diff 
    <(nice perl -e 'for("x011".."x110"){print "$_\t", ("\n", map { rand } (1..100000)) }'| 
      nice parallel -N10 -L1 --pipe -j6 --block 20M --compress 
      pv -qL 1000000 | perl -pe 's/(....).*/$1/') 
    <(nice perl -e 'for("x011".."x110"){print "$_\t", ("\n", map { rand } (1..100000)) }'| 
      nice parallel -N10 -L1 --pipe -j6 --block 20M --compress --line-buffer 
      pv -qL 1000000 | perl -pe 's/(....).*/$1/') 
    >/dev/null 
  || (echo 'Good: --line-buffer matters'; false) && echo 'Bad: --line-buffer not working'

echo 'bug #41613: --compress --line-buffer with --tagstring';
  diff 
    <(nice perl -e 'for("x011".."x110"){print "$_\t", ("\n", map { rand } (1..100000)) }'| 
      nice parallel -N10 -L1 --pipe -j6 --block 20M --compress --tagstring {#} 
      pv -qL 1000000 | perl -pe 's/(....).*/$1/') 
    <(nice perl -e 'for("x011".."x110"){print "$_\t", ("\n", map { rand } (1..100000)) }'| 
      nice parallel -N10 -L1 --pipe -j6 --block 20M --compress --tagstring {#} --line-buffer 
      pv -qL 1000000 | perl -pe 's/(....).*/$1/') 
    >/dev/null 
  || (echo 'Good: --line-buffer matters'; false) && echo 'Bad: --line-buffer not working'

echo '**'


EOF
