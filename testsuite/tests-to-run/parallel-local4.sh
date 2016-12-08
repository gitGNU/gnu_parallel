#!/bin/bash

echo 'bug #46120: Suspend should suspend (at least local) children'
  echo 'it should burn 1.9 CPU seconds, but no more than that'
  echo 'The 5 second sleep will make it be killed by timeout when it fgs'
  stdout bash -i -c 'stdout /usr/bin/time -f CPUTIME=%U parallel --timeout 5 burnP6 ::: 1 | grep -q CPUTIME=1 & 
  sleep 1.9; 
  kill -TSTP -$!; 
  sleep 5; 
  fg; 
  echo Zero=OK $?' | grep -v '\[1\]'

  stdout bash -i -c 'echo 1 | stdout /usr/bin/time -f CPUTIME=%U parallel --timeout 5 burnP6 | grep -q CPUTIME=1 & 
  sleep 1.9; 
  kill -TSTP -$!; 
  sleep 5; 
  fg; 
  echo Zero=OK $?' | grep -v '\[1\]'

cat <<'EOF' | sed -e 's/;$/; /;' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo '### -L -n with pipe'
  seq 14 | parallel --pipe -k -L 3 -n 2 'cat;echo 6 Ln line record'

echo '### -L -N with pipe'
  seq 14 | parallel --pipe -k -L 3 -N 2 'cat;echo 6 LN line record'

echo '### -l -N with pipe'
  seq 14 | parallel --pipe -k -l 3 -N 2 'cat;echo 6 lN line record'

echo '### -l -n with pipe'
  seq 14 | parallel --pipe -k -l 3 -n 2 'cat;echo 6 ln line record'

echo '### bug #39360: --joblog does not work with --pipe'
  seq 100 | parallel --joblog - --pipe wc | tr '0-9' 'X'

echo '### bug #39572: --tty and --joblog do not work'
  seq 1 | parallel --joblog - -u true | tr '0-9' 'X'

echo '### How do we deal with missing $HOME'
   unset HOME; stdout perl -w $(which parallel) -k echo ::: 1 2 3

echo '### How do we deal with missing $SHELL'
   unset SHELL; stdout perl -w $(which parallel) -k echo ::: 1 2 3

echo '### Test if length is computed correctly - first should give one line, second 2 lines each'
  seq 4 | parallel -s 29 -X -kj1 echo a{}b{}c
  seq 4 | parallel -s 28 -X -kj1 echo a{}b{}c
  seq 4 | parallel -s 21 -X -kj1 echo {} {}
  seq 4 | parallel -s 20 -X -kj1 echo {} {}
  seq 4 | parallel -s 23 -m -kj1 echo a{}b{}c
  seq 4 | parallel -s 22 -m -kj1 echo a{}b{}c
  seq 4 | parallel -s 21 -m -kj1 echo {} {}
  seq 4 | parallel -s 20 -m -kj1 echo {} {}

echo 'bug #44144: --tagstring {=s/a/b/=} broken'
  # Do not be confused by {} in --rpl
  parallel --rpl '{:} s/A/D/;{}' --tagstring '{1:}{-1:}{= s/A/E/=}' echo {} ::: A/B.C
  # Non-standard --parens 
  parallel --parens ,, --rpl '{:} s/A/D/;{}' --tagstring '{1:}{-1:}, 's/A/E/, echo {} ::: A/B.C
  # Non-standard --parens -i
  parallel --rpl '{:} s/A/D/;{}' --tag --parens ,, -iDUMMY echo {} ::: A/B.C

echo 'bug #45692: Easy way of cancelling a job in {= =} and'
echo 'bug #45691: Accessing multiple arguments in {= =}'
  parallel -k echo {= '$arg[1] eq 2 and $job->skip()' =} ::: {1..5}


EOF
