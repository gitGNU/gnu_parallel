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
  sudo mkdir -p /mnt/ram
  sudo mount smalldisk.img /mnt/ram
  sudo chmod 777 /mnt/ram
) >/dev/null 2>/dev/null

stdsort() {
    "$@" 2>&1 | sort;
}
export -f stdsort

# Test amount of parallelization
# parallel --shuf --jl /tmp/myjl -j1 'export JOBS={1};'bash tests-to-run/parallel-local-0.3s.sh ::: {1..16} ::: {1..5}

cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj13 -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test bug #45619: "--halt" erroneous error exit code (should give 0)'; 
  seq 10 | parallel --halt now,fail=1 true; 
  echo $?

echo '**'

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

echo '### bug #47501: --xapply for some input sources'
  # Wrapping does not work yet
  parallel -k echo ::: a b c aWRAP :::+ aa bb cc ::: A B :::+ AA BB AAwrap

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
parallel --rpl '{+.} s:.*\.::' --rpl '%' 
  --rpl '%D $_=::shell_quote(::dirname($_));' --rpl '%B s:.*/::;s:\.[^/.]+$::;' --rpl '%E s:.*\.::' 
  'echo {}=%;echo %D={//};echo %B={/.};echo %E={+.};echo %D/%B.%E={}' ::: a.b/c.d/e.f

echo '**'

echo '### Disk full'
cat /dev/zero >$SMALLDISK/out; 
  parallel --tmpdir $SMALLDISK echo ::: OK; 
  rm $SMALLDISK/out

echo '**'

echo '### bug #44614: --pipepart --header off by one'
  seq 10 >/tmp/parallel_44616; 
    parallel --pipepart -a /tmp/parallel_44616 -k --block 5 'echo foo; cat'; 
    parallel --pipepart -a /tmp/parallel_44616 -k --block 2 --regexp --recend 3'\n' 'echo foo; cat'; 
    rm /tmp/parallel_44616

echo '### PARALLEL_TMUX not found'
  PARALLEL_TMUX=not-existing parallel --tmux echo ::: 1

echo '**'

  parallel -j4 --halt 2 ::: 'sleep 1' burnP6 false; 
    killall burnP6 && echo ERROR: burnP6 should already have been killed
  parallel -j4 --halt -2 ::: 'sleep 1' burnP5 true; 
    killall burnP5 && echo ERROR: burnP5 should already have been killed

parallel --halt error echo ::: should not print
parallel --halt soon echo ::: should not print
parallel --halt now echo ::: should not print

echo '**'

echo '### bug #44995: parallel echo {#} ::: 1 2 ::: 1 2'

parallel -k echo {#} ::: 1 2 ::: 1 2

echo '**'

testquote() { printf '"#&/\n()*=?'"'" | PARALLEL_SHELL=$1 parallel -0 echo; }; 
  export -f testquote; 
  parallel --tag -k testquote ::: ash bash csh dash fdsh fish fizsh ksh ksh93 mksh posh rbash rc rzsh sash sh static-sh tcsh yash zsh

echo '**'

echo '### bug #45769: --round-robin --pipepart gives wrong results'

seq 10000 >/tmp/seq10000; 
  parallel -j2 --pipepart -a /tmp/seq10000 --block 14 --round-robin wc | wc -l; 
  rm /tmp/seq10000

echo '**'

echo '### bug #45842: Do not evaluate {= =} twice'

  parallel -k echo '{=  $_=++$::G =}' ::: {1001..1004}
  parallel -k echo '{=1 $_=++$::G =}' ::: {1001..1004}
  parallel -k echo '{=  $_=++$::G =}' ::: {1001..1004} ::: {a..c}
  parallel -k echo '{=1 $_=++$::G =}' ::: {1001..1004} ::: {a..c}

echo '**'

echo '### bug #45939: {2} in {= =} fails'

  parallel echo '{= s/O{2}//=}' ::: OOOK
  parallel echo '{2}-{=1 s/O{2}//=}' ::: OOOK ::: OK

echo '**'

echo '### bug #45998: --pipe to function broken'

  myfunc() { echo $1; cat; }; 
    export -f myfunc; 
    echo pipefunc OK | parallel --pipe myfunc {#}; 
    echo pipefunc and more OK | parallel --pipe 'myfunc {#};echo and more OK'

echo '**'

echo 'bug #46016: --joblog should not log when --dryrun'

  parallel --dryrun --joblog - echo ::: Only_this

echo '**'

echo 'bug #45993: --wd ... should also work when run locally'

  parallel --wd /bi 'pwd; echo $OLDPWD; echo' ::: fail
  parallel --wd /bin 'pwd; echo $OLDPWD; echo' ::: OK
  parallel --wd / 'pwd; echo $OLDPWD; echo' ::: OK
  parallel --wd /tmp 'pwd; echo $OLDPWD; echo' ::: OK
  parallel --wd ... 'pwd; echo $OLDPWD; echo' ::: OK | perl -pe 's/\d+/0/g'
  parallel --wd . 'pwd; echo $OLDPWD; echo' ::: OK

echo '**'

echo 'bug #46232: {%} with --bar/--eta/--shuf or --halt xx% broken'

  parallel --bar -kj2 --delay 0.1 echo {%} ::: a b  ::: c d e 2>/dev/null
  parallel --halt now,fail=10% -kj2 --delay 0.1 echo {%} ::: a b  ::: c d e
  parallel --eta -kj2 --delay 0.1 echo {%} ::: a b  ::: c d e 2>/dev/null
  parallel --shuf -kj2 --delay 0.1 echo {%} ::: a b  ::: c d e 2>/dev/null

echo '**'

echo 'bug #46231: {%} with --pipepart broken. Should give 1+2'

  seq 10000 > /tmp/num10000; 
  parallel -k --pipepart -ka /tmp/num10000 --block 10k -j2 --delay 0.05 echo {%}; 
  rm /tmp/num10000

echo '**'

echo '{##} bug #45841: Replacement string for total no of jobs'

  parallel -k --plus echo {##} ::: {a..j};
  parallel -k 'echo {= $::G++ > 3 and ($_=$Global::JobQueue->total_jobs());=}' ::: {1..10}
  parallel -k -N7 --plus echo {#} {##} ::: {1..14}
  parallel -k -N7 --plus echo {#} {##} ::: {1..15}
  parallel -k -S 8/: -X --plus echo {#} {##} ::: {1..15}

echo '**'

echo 'bug #47002: --tagstring with -d \n\n'

  (seq 3;echo;seq 4) | parallel -k -d '\n\n' --tagstring {%} echo ABC';'echo

echo '**'

echo 'bug #47086: [PATCH] Initialize total_completed from joblog'

  rm -f /tmp/parallel-47086; 
  parallel -j1 --joblog /tmp/parallel-47086 --halt now,fail=1          echo '{= $_=$Global::total_completed =};exit {}' ::: 0 0 0 1 0 0; 
  parallel -j1 --joblog /tmp/parallel-47086 --halt now,fail=1 --resume echo '{= $_=$Global::total_completed =};exit {}' ::: 0 0 0 1 0 0

echo '**'

echo 'bug #47290: xargs: Warning: a NUL character occurred in the input'

  perl -e 'print "foo\0not printed"' | parallel echo

echo '**'

echo '### Test --shellquote'
  parallel --tag -q -k {} -c perl\ -e\ \'print\ pack\(\"c\*\",1..255\)\'\ \|\ parallel\ -0\ --shellquote ::: ash bash csh dash fish fizsh ksh ksh93 lksh mksh posh rzsh sash sh static-sh tcsh yash zsh csh tcsh

echo '**'

echo xargs compatibility

echo '### Test -L -l and --max-lines'

  (echo a_b;echo c) | parallel -km -L2 echo
  (echo a_b;echo c) | parallel -k -L2 echo
  (echo a_b;echo c) | xargs -L2 echo

echo '### xargs -L1 echo'

  (echo a_b;echo c) | parallel -km -L1 echo
  (echo a_b;echo c) | parallel -k -L1 echo
  (echo a_b;echo c) | xargs -L1 echo
  echo 'Lines ending in space should continue on next line'

echo '### xargs -L1 echo'

  (echo a_b' ';echo c;echo d) | parallel -km -L1 echo
  (echo a_b' ';echo c;echo d) | parallel -k -L1 echo
  (echo a_b' ';echo c;echo d) | xargs -L1 echo
  
echo '### xargs -L2 echo'

  (echo a_b' ';echo c;echo d;echo e) | parallel -km -L2 echo
  (echo a_b' ';echo c;echo d;echo e) | parallel -k -L2 echo
  (echo a_b' ';echo c;echo d;echo e) | xargs -L2 echo
  
echo '### xargs -l echo'

  (echo a_b' ';echo c;echo d;echo e) | parallel -l -km echo # This behaves wrong
  (echo a_b' ';echo c;echo d;echo e) | parallel -l -k echo # This behaves wrong
  (echo a_b' ';echo c;echo d;echo e) | xargs -l echo
  
echo '### xargs -l2 echo'

  (echo a_b' ';echo c;echo d;echo e) | parallel -km -l2 echo
  (echo a_b' ';echo c;echo d;echo e) | parallel -k -l2 echo
  (echo a_b' ';echo c;echo d;echo e) | xargs -l2 echo
  
echo '### xargs -l1 echo'

  (echo a_b' ';echo c;echo d;echo e) | parallel -km -l1 echo
  (echo a_b' ';echo c;echo d;echo e) | parallel -k -l1 echo
  (echo a_b' ';echo c;echo d;echo e) | xargs -l1 echo
  
echo '### xargs --max-lines=2 echo'

  (echo a_b' ';echo c;echo d;echo e) | parallel -km --max-lines 2 echo
  (echo a_b' ';echo c;echo d;echo e) | parallel -k --max-lines 2 echo
  (echo a_b' ';echo c;echo d;echo e) | xargs --max-lines=2 echo
  
echo '### xargs --max-lines echo'

  (echo a_b' ';echo c;echo d;echo e) | parallel --max-lines -km echo # This behaves wrong
  (echo a_b' ';echo c;echo d;echo e) | parallel --max-lines -k echo # This behaves wrong
  (echo a_b' ';echo c;echo d;echo e) | xargs --max-lines echo
  
echo '### test too long args'

  perl -e 'print "z"x1000000' | parallel echo 2>&1
  perl -e 'print "z"x1000000' | xargs echo 2>&1
  (seq 1 10; perl -e 'print "z"x1000000'; seq 12 15) | stdsort parallel -j1 -km -s 10 echo
  (seq 1 10; perl -e 'print "z"x1000000'; seq 12 15) | stdsort xargs -s 10 echo
  (seq 1 10; perl -e 'print "z"x1000000'; seq 12 15) | stdsort parallel -j1 -kX -s 10 echo
  
echo '### Test -x'

  (seq 1 10; echo 12345; seq 12 15) | stdsort parallel -j1 -km -s 10 -x echo
  (seq 1 10; echo 12345; seq 12 15) | stdsort parallel -j1 -kX -s 10 -x echo
  (seq 1 10; echo 12345; seq 12 15) | stdsort xargs -s 10 -x echo
  (seq 1 10; echo 1234;  seq 12 15) | stdsort parallel -j1 -km -s 10 -x echo
  (seq 1 10; echo 1234;  seq 12 15) | stdsort parallel -j1 -kX -s 10 -x echo
  (seq 1 10; echo 1234;  seq 12 15) | stdsort xargs -s 10 -x echo
  
echo '### Test -a and --arg-file: Read input from file instead of stdin'

  seq 1 10 >/tmp/parallel_$$-1; parallel -k -a /tmp/parallel_$$-1 echo; rm /tmp/parallel_$$-1
  seq 1 10 >/tmp/parallel_$$-2; parallel -k --arg-file /tmp/parallel_$$-2 echo; rm /tmp/parallel_$$-2
  
echo '### Test -i and --replace: Replace with argument'

  (echo a; echo END; echo b) | parallel -k -i -eEND echo repl{}ce
  (echo a; echo END; echo b) | parallel -k --replace -eEND echo repl{}ce
  (echo a; echo END; echo b) | parallel -k -i+ -eEND echo repl+ce
  (echo e; echo END; echo b) | parallel -k -i'*' -eEND echo r'*'plac'*'
  (echo a; echo END; echo b) | parallel -k --replace + -eEND echo repl+ce
  (echo a; echo END; echo b) | parallel -k --replace== -eEND echo repl=ce
  (echo a; echo END; echo b) | parallel -k --replace = -eEND echo repl=ce
  (echo a; echo END; echo b) | parallel -k --replace=^ -eEND echo repl^ce
  (echo a; echo END; echo b) | parallel -k -I^ -eEND echo repl^ce
  
echo '### Test -E: Artificial end-of-file'

  (echo include this; echo END; echo not this) | parallel -k -E END echo
  (echo include this; echo END; echo not this) | parallel -k -EEND echo
  
echo '### Test -e and --eof: Artificial end-of-file'

  (echo include this; echo END; echo not this) | parallel -k -e END echo
  (echo include this; echo END; echo not this) | parallel -k -eEND echo
  (echo include this; echo END; echo not this) | parallel -k --eof=END echo
  (echo include this; echo END; echo not this) | parallel -k --eof END echo
  
echo '### Test -n and --max-args: Max number of args per line (only with -X and -m)'

  (echo line 1;echo line 2;echo line 3) | parallel -k -n1 -m echo
  (echo line 1;echo line 1;echo line 2) | parallel -k -n2 -m echo
  (echo line 1;echo line 2;echo line 3) | parallel -k -n1 -X echo
  (echo line 1;echo line 1;echo line 2) | parallel -k -n2 -X echo
  (echo line 1;echo line 2;echo line 3) | parallel -k -n1 echo
  (echo line 1;echo line 1;echo line 2) | parallel -k -n2 echo
  (echo line 1;echo line 2;echo line 3) | parallel -k --max-args=1 -X echo
  (echo line 1;echo line 2;echo line 3) | parallel -k --max-args 1 -X echo
  (echo line 1;echo line 1;echo line 2) | parallel -k --max-args=2 -X echo
  (echo line 1;echo line 1;echo line 2) | parallel -k --max-args 2 -X echo
  (echo line 1;echo line 2;echo line 3) | parallel -k --max-args 1 echo
  (echo line 1;echo line 1;echo line 2) | parallel -k --max-args 2 echo
  
echo '### Test --max-procs and -P: Number of processes'

  seq 1 10 | parallel -k --max-procs +0 echo max proc
  seq 1 10 | parallel -k -P 200% echo 200% proc
  
echo '### Test --delimiter and -d: Delimiter instead of newline'

  echo '# Yes there is supposed to be an extra newline for -d N'
  echo line 1Nline 2Nline 3 | parallel -k -d N echo This is
  echo line 1Nline 2Nline 3 | parallel -k --delimiter N echo This is
  printf "delimiter NUL line 1\0line 2\0line 3" | parallel -k -d '\0' echo
  printf "delimiter TAB line 1\tline 2\tline 3" | parallel -k --delimiter '\t' echo
  
echo '### Test --max-chars and -s: Max number of chars in a line'

  (echo line 1;echo line 1;echo line 2) | parallel -k --max-chars 25 -X echo
  (echo line 1;echo line 1;echo line 2) | parallel -k -s 25 -X echo
  
echo '### Test --no-run-if-empty and -r: This should give no output'

  echo "  " | parallel -r echo
  echo "  " | parallel --no-run-if-empty echo
  
echo '### Test --help and -h: Help output (just check we get the same amount of lines)'

  echo Output from -h and --help
  parallel -h | wc -l
  parallel --help | wc -l
  
echo '### Test --version: Version output (just check we get the same amount of lines)'

  parallel --version | wc -l
  
echo '### Test --verbose and -t'

  (echo b; echo c; echo f) | parallel -k -t echo {}ar 2>&1 >/dev/null
  (echo b; echo c; echo f) | parallel -k --verbose echo {}ar 2>&1 >/dev/null
  
echo '### Test --show-limits'

  (echo b; echo c; echo f) | parallel -k --show-limits echo {}ar
  (echo b; echo c; echo f) | parallel -j1 -kX --show-limits -s 100 echo {}ar
  
echo '### Test empty line as input'

  echo | parallel echo empty input line
  
echo '### Tests if (cat | sh) works'

  perl -e 'for(1..25) {print "echo a $_; echo b $_\n"}' | parallel 2>&1 | sort
  
echo '### Test if xargs-mode works'

  perl -e 'for(1..25) {print "a $_\nb $_\n"}' | parallel echo 2>&1 | sort
  
echo '### Test -q'

  parallel -kq perl -e '$ARGV[0]=~/^\S+\s+\S+$/ and print $ARGV[0],"\n"' ::: "a b" c "d e f" g "h i"
  
echo '### Test -q {#}'

  parallel -kq echo {#} ::: a b
  parallel -kq echo {\#} ::: a b
  parallel -kq echo {\\#} ::: a b
  
echo '### Test long commands do not take up all memory'

  seq 1 100 | parallel -j0 -qv perl -e '$r=rand(shift);for($f=0;$f<$r;$f++){$a="a"x100};print shift,"\n"' 10000 2>/dev/null | sort
  
echo '### Test 0-arguments'

  seq 1 2 | parallel -k -n0 echo n0
  seq 1 2 | parallel -k -L0 echo L0
  seq 1 2 | parallel -k -N0 echo N0
  
echo '### Because of --tollef -l, then -l0 == -l1, sorry'

  seq 1 2 | parallel -k -l0 echo l0
  
echo '### Test replace {}'

  seq 1 2 | parallel -k -N0 echo replace {} curlies
  
echo '### Test arguments on commandline'

  parallel -k -N0 echo args on cmdline ::: 1 2
  
echo '### Test --nice locally'

  parallel --nice 1 -vv 'PAR=a bash -c "echo  \$PAR {}"' ::: b
  
echo '### Test distribute arguments at EOF to 2 jobslots'

  seq 1 92 | parallel -j2 -kX -s 100 echo
  
echo '### Test distribute arguments at EOF to 5 jobslots'

  seq 1 92 | parallel -j5 -kX -s 100 echo
  
echo '### Test distribute arguments at EOF to infinity jobslots'

  seq 1 92 | parallel -j0 -kX -s 100 echo 2>/dev/null
  
echo '### Test -N is not broken by distribution - single line'

  seq 9 | parallel  -N 10  echo
  
echo '### Test -N is not broken by distribution - two lines'

  seq 19 | parallel -k -N 10  echo
  
echo '### Test -N context replace'

  seq 19 | parallel -k -N 10  echo a{}b
  
echo '### Test -L context replace'

  seq 19 | parallel -k -L 10  echo a{}b
  
echo '**'

echo '### Test {} multiple times in different commands'

  seq 10 | parallel -v -Xj1 echo {} \; echo {}

echo '### Test of -X {1}-{2} with multiple input sources'

  parallel -j1 -kX  echo {1}-{2} ::: a ::: b
  parallel -j2 -kX  echo {1}-{2} ::: a b ::: c d
  parallel -j2 -kX  echo {1}-{2} ::: a b c ::: d e f
  parallel -j0 -kX  echo {1}-{2} ::: a b c ::: d e f

echo '### Test of -X {}-{.} with multiple input sources'

  parallel -j1 -kX  echo {}-{.} ::: a ::: b
  parallel -j2 -kX  echo {}-{.} ::: a b ::: c d
  parallel -j2 -kX  echo {}-{.} ::: a b c ::: d e f
  parallel -j0 -kX  echo {}-{.} ::: a b c ::: d e f

echo '### Test of -r with --pipe - the first should give an empty line. The second should not.'

  echo | parallel  -j2 -N1 --pipe cat | wc -l
  echo | parallel -r -j2 -N1 --pipe cat | wc -l

echo '### Test --tty'

  seq 0.1 0.1 0.5 | parallel -j1 --tty tty\;sleep

echo '**'

echo '### Test bugfix if no command given'
  (echo echo; seq 1 5; perl -e 'print "z"x1000000'; seq 12 15) | stdout parallel -j1 -km -s 10

echo '**'

echo "bug #34958: --pipe with record size measured in lines"
  seq 10 | parallel -k --pipe -l 4 cat\;echo bug 34958-2

echo '**'

echo "bug #37325: Inefficiency of --pipe -L"
  seq 2000 | parallel -k --pipe --block 1k -L 4 wc\;echo FOO | uniq

echo '**'

echo "bug #34958: --pipe with record size measured in lines"
  seq 10 | parallel -k --pipe -L 4 cat\;echo bug 34958-1

echo '**'

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

echo '**'

echo '### --pipe without command'

  seq -w 10 | stdout parallel --pipe

echo '**'

echo '### bug #36260: {n} expansion in --colsep files fails for empty fields if all following fields are also empty'

  echo A,B,, | parallel --colsep , echo {1}{3}{2}

echo '**'

echo '### bug #34422: parallel -X --eta crashes with div by zero'

  # We do not care how long it took
  seq 2 | stdout parallel -X --eta echo | grep -E -v 'ETA:.*AVG'

echo '**'

  bash -O extglob -c '. `which env_parallel.bash`; 
    _longopt () { 
      case "$prev" in 
        --+([-a-z0-9_])) 
          echo foo;; 
      esac; 
    }; 
    env_parallel echo ::: env_parallel 2>&1 
  '

echo '**'

echo '### bug #48745: :::+ bug'

  parallel -k echo ::: 11 22 33 ::::+ <(seq 3) <(seq 21 23) ::: a b c :::+ aa bb cc
  parallel -k echo :::: <(seq 3) <(seq 21 23) :::+ a b c ::: aa bb cc
  parallel -k echo :::: <(seq 3) :::: <(seq 21 23) :::+ a b c ::: aa bb cc

echo '**'

echo '### bug #48658: --linebuffer --files'

  stdout parallel --files --linebuffer 'sleep .1;seq {};sleep .1' ::: {1..10} | wc -l

echo '**'

echo 'bug #49538: --header and {= =}'

  parallel --header : echo '{=v2=}{=v1 $_=Q($_)=}' ::: v1 K ::: v2 O
  parallel --header : echo '{2}{=1 $_=Q($_)=}' ::: v2 K ::: v1 O
  parallel --header : echo {var/.} ::: var sub/dir/file.ext
  parallel --header : echo {var//} ::: var sub/dir/file.ext
  parallel --header : echo {var/.} ::: var sub/dir/file.ext
  parallel --header : echo {var/} ::: var sub/dir/file.ext
  parallel --header : echo {var.} ::: var sub/dir/file.ext

echo '**'

echo 'bug --colsep 0'

  parallel --colsep 0 echo {2} ::: a0OK0c
  parallel --header : --colsep 0 echo {ok} ::: A0ok0B a0OK0b

echo '**'

EOF
echo '### 1 .par file from --files expected'
find /tmp{/*,}/*.{par,tms,tmx} 2>/dev/null -mmin -10 | wc -l
find /tmp{/*,}/*.{par,tms,tmx} 2>/dev/null -mmin -10 | parallel rm

sudo umount -l /tmp/smalldisk.img

par_empty() {
    echo "bug #:"

    parallel echo ::: true
}

par_empty_line() {
    echo '### Test bug: empty line for | sh with -k'
    (echo echo a ; echo ; echo echo b) | parallel -k
}

par_append_joblog() {
    echo '### can you append to a joblog using +'
    parallel --joblog /tmp/parallel_append_joblog echo ::: 1
    parallel --joblog +/tmp/parallel_append_joblog echo ::: 1
    wc -l /tmp/parallel_append_joblog
}

par_file_ending_in_newline() {
    echo '### Hans found a bug giving unitialized variable'
    echo >/tmp/parallel_f1
    echo >/tmp/parallel_f2'
'
    echo /tmp/parallel_f1 /tmp/parallel_f2 |
    stdout parallel -kv --delimiter ' ' gzip
    rm /tmp/parallel_f*
}

par_python_children() {
    echo '### bug #49970: Python child process dies if --env is used'
    fu() { echo joe; }
    export -f fu
    echo foo | stdout parallel --env fu python -c \
    \""import os; f = os.popen('uname -p'); output = f.read(); rc = f.close()"\"
}

par_pipepart_block_bigger_2G() {
    echo '### Test that --pipepart can have blocks > 2GB'
    tmp=$(mktemp)
    echo foo >$tmp
    parallel --pipepart -a $tmp --block 3G wc
    rm $tmp
}

par_retries_replacement_string() {
    tmp=$(mktemp)
    parallel --retries {//} "echo {/} >>$tmp;exit {/}" ::: 1/11 2/22 3/33
    sort $tmp
    rm $tmp
}

par_tee() {
    export PARALLEL='-k --tee --pipe --tag'
    seq 1000000 | parallel 'echo {%};LANG=C wc' ::: {1..5} ::: {a..b}
    seq 300000 | parallel 'grep {1} | LANG=C wc {2}' ::: {1..5} ::: -l -c
}

par_tagstring_pipe() {
    echo 'bug #50228: --pipe --tagstring broken'
    seq 3000 | parallel -j4 --pipe -N1000 -k --tagstring {%} LANG=C wc
}

par_link_files_as_only_arg() {
    echo 'bug #50685: single ::::+ does not work'
    parallel echo ::::+ <(seq 10) <(seq 3) <(seq 4)
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort |
    parallel -j6 --tag -k --joblog +/tmp/jl-`basename $0` '{} 2>&1'
