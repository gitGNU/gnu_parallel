#!/bin/bash

# SSH only allowed to localhost/lo
rm -rf tmp
mkdir tmp
cd tmp
unset run_test

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | stdout parallel -vj300% -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test --load remote'
  ssh parallel@lo 'seq 10 | parallel --nice 19 --timeout 15 -j0 -N0 burnP6' & 
  sleep 1; 
  stdout /usr/bin/time -f %e parallel -S parallel@lo --load 10 sleep ::: 1 | perl -ne '$_ > 10 and print "OK\n"'

echo '**'

echo '### Stop if all hosts are filtered and there are no hosts left to run on'
  stdout parallel --filter-hosts -S no-such.host echo ::: 1

echo '### Can csh propagate a variable containing \n'; 
  export A=$(seq 3); parallel -S csh@lo --env A bash -c \''echo "$A"'\' ::: dummy

echo '### bug #41805: Idea: propagate --env for parallel --number-of-cores'
  echo '** test_zsh'
  FOO=test_zsh parallel --env FOO,HOME -S zsh@lo -N0 env ::: "" |sort|egrep 'FOO|^HOME'
  echo '** test_zsh_filter'
  FOO=test_zsh_filter parallel --filter-hosts --env FOO,HOME -S zsh@lo -N0 env ::: "" |sort|egrep 'FOO|^HOME'
  echo '** test_csh'
  FOO=test_csh parallel --env FOO,HOME -S csh@lo -N0 env ::: "" |sort|egrep 'FOO|^HOME'
  echo '** test_csh_filter'
  FOO=test_csh_filter parallel --filter-hosts --env FOO,HOME -S csh@lo -N0 env ::: "" |sort|egrep 'FOO|^HOME'
  echo '** bug #41805 done'

echo '### Deal with long command lines on remote servers'
  perl -e 'print((("\""x5000)."\n")x10)' | parallel -j1 -S lo -N 10000 echo {} |wc

echo '### Test bug #34241: --pipe should not spawn unneeded processes'
  seq 5 | ssh csh@lo parallel -k --block 5 --pipe -j10 cat\\\;echo Block_end

echo '### bug #40002: --files and --nonall seem not to work together:'
  parallel --files --nonall -S localhost true | tee >(parallel rm) | wc -l

echo '### bug #40001: --joblog and --nonall seem not to work together:'
  parallel --joblog - --nonall -S lo,localhost true | wc -l

echo '### bug #40132: FreeBSD: --workdir . gives warning if . == $HOME'
  cd && parallel --workdir . -S lo pwd ::: ""

echo '### use function as $PARALLEL_SSH'
  foossh() { echo "FOOSSH" >&2; ssh "$@"; }; 
  export -f foossh; 
  PARALLEL_SSH=foossh parallel -S 1/lo echo ::: 'Run through FOOSSH?'

echo '### use --ssh'
  barssh() { echo "BARSSH" >&2; ssh "$@"; }; 
  export -f barssh; 
  parallel --ssh barssh -S 1/lo echo ::: 'Run through BARSSH?'

echo '### test filename :'
  echo content-of-: > :; 
  echo : | parallel -j1 --trc {}.{.} -S parallel@lo '(echo remote-{}.{.};cat {}) > {}.{.}'; 
  cat :.:; rm : :.:

echo '### Test --wd ... --cleanup which should remove the filled tmp dir'
  ssh sh@lo 'mkdir -p .parallel/tmp; find .parallel/tmp |grep uNiQuE_sTrInG.6 | parallel rm'; 
  stdout parallel -j9 -k --retries 3 --wd ... --cleanup -S sh@lo -v echo ">"{}.6 :::  uNiQuE_sTrInG; 
  find ~sh/.parallel/tmp |grep uNiQuE_sTrInG.6

echo '### Test --wd --'
  stdout parallel --wd -- -S sh@lo echo OK ">"{}.7 ::: uNiQuE_sTrInG; 
  cat ~sh/--/uNiQuE_sTrInG.7; 
  stdout ssh sh@lo rm ./--/uNiQuE_sTrInG.7

echo '### Test --wd " "'
  stdout parallel --wd " " -S sh@lo echo OK ">"{}.8 ::: uNiQuE_sTrInG; 
  cat ~sh/" "/uNiQuE_sTrInG.8; 
  stdout ssh sh@lo rm ./'" "'/uNiQuE_sTrInG.8

echo "### Test --wd \"'\""
  stdout parallel --wd "'" -S sh@lo echo OK ">"{}.9 ::: uNiQuE_sTrInG; 
  cat ~sh/"'"/uNiQuE_sTrInG.9; 
  stdout ssh sh@lo rm ./"\\'"/uNiQuE_sTrInG.9

echo '### Test --trc ./--/--foo1'
  mkdir -p ./--; echo 'Content --/--foo1' > ./--/--foo1; 
  stdout parallel --trc {}.1 -S sh@lo '(cat {}; echo remote1) > {}.1' ::: ./--/--foo1; cat ./--/--foo1.1; 
  stdout parallel --trc {}.2 -S sh@lo '(cat ./{}; echo remote2) > {}.2' ::: --/--foo1; cat ./--/--foo1.2

echo '### Test --trc ./:dir/:foo2'
  mkdir -p ./:dir; echo 'Content :dir/:foo2' > ./:dir/:foo2; 
  stdout parallel --trc {}.1 -S sh@lo '(cat {}; echo remote1) > {}.1' ::: ./:dir/:foo2; 
  cat ./:dir/:foo2.1; 
  stdout parallel --trc {}.2 -S sh@lo '(cat ./{}; echo remote2) > {}.2' ::: :dir/:foo2; 
  cat ./:dir/:foo2.2

echo '### Test --trc ./" "/" "foo3'
  mkdir -p ./" "; echo 'Content _/_foo3' > ./" "/" "foo3; 
  stdout parallel --trc {}.1 -S sh@lo '(cat {}; echo remote1) > {}.1' ::: ./" "/" "foo3; 
  cat ./" "/" "foo3.1; 
  stdout parallel --trc {}.2 -S sh@lo '(cat ./{}; echo remote2) > {}.2' ::: " "/" "foo3; 
  cat ./" "/" "foo3.2

echo '### Test --trc ./--/./--foo4'
  mkdir -p ./--; echo 'Content --/./--foo4' > ./--/./--foo4; 
  stdout parallel --trc {}.1 -S sh@lo '(cat ./--foo4; echo remote{}) > --foo4.1' ::: --/./--foo4; 
  cat ./--/./--foo4.1

echo '### Test --trc ./:/./:foo5'
  mkdir -p ./:a; echo 'Content :a/./:foo5' > ./:a/./:foo5; 
  stdout parallel --trc {}.1 -S sh@lo '(cat ./:foo5; echo remote{}) > ./:foo5.1' ::: ./:a/./:foo5; 
  cat ./:a/./:foo5.1

echo '### Test --trc ./" "/./" "foo6'
  mkdir -p ./" "; echo 'Content _/./_foo6' > ./" "/./" "foo6; 
  stdout parallel --trc {}.1 -S sh@lo '(cat ./" "foo6; echo remote{}) > ./" "foo6.1' ::: ./" "/./" "foo6; 
  cat ./" "/./" "foo6.1

echo '### Test --trc "-- " "-- "'
  touch -- '-- ' ' --'; rm -f ./?--.a ./--?.a; 
  parallel --trc {}.a -S csh@lo,sh@lo touch ./{}.a ::: '-- ' ' --'; ls ./--?.a ./?--.a; 
  parallel --nonall -k -S csh@lo,sh@lo 'ls ./?-- || echo OK'; 
  parallel --nonall -k -S csh@lo,sh@lo 'ls ./--? || echo OK'; 
  parallel --nonall -k -S csh@lo,sh@lo 'ls ./?--.a || echo OK'; 
  parallel --nonall -k -S csh@lo,sh@lo 'ls ./--?.a || echo OK'

echo '### Test --trc "/tmp/./--- /A" "/tmp/./ ---/B"'
  mkdir -p '/tmp/./--- '   '/tmp/ ---'; 
  touch -- '/tmp/./--- /A' '/tmp/ ---/B'; 
  rm -f ./---?/A.a ./?---/B.a; 
  parallel --trc {=s:.*/./::=}.a -S csh@lo,sh@lo touch ./{=s:.*/./::=}.a ::: '/tmp/./--- /A' '/tmp/./ ---/B'; 
  ls ./---?/A.a ./?---/B.a; 
  parallel --nonall -k -S csh@lo,sh@lo 'ls ./?--- ./---? || echo OK'; 

echo '### bug #46519: --onall ignores --transfer'
  touch bug46519.{a,b,c}; rm -f bug46519.?? bug46519.???; 
  parallel --onall --tf bug46519.{} --trc bug46519.{}{} --trc bug46519.{}{}{} -S csh@lo,sh@lo 
    'ls bug46519.{}; touch bug46519.{}{} bug46519.{}{}{}' ::: a b c; 
  ls bug46519.?? bug46519.???; 
  parallel --onall -S csh@lo,sh@lo ls bug46519.{}{} bug46519.{}{}{} ::: a b c && echo Cleanup failed

echo '### Test --nice remote'
stdout parallel --nice 1 -S lo -vv 'PAR=a bash -c "echo  \$PAR {}"' ::: b | 
  perl -pe 's/\S*parallel-server\S*/one-server/;s:[a-z/\\+=0-9]{500,}:base64:i;'

echo '**'

echo TODO

## echo '### Test --trc --basefile --/./--foo7 :/./:foo8 " "/./" "foo9 ./foo11/./foo11'

EOF

cd ..
rm -rf tmp
mkdir tmp
cd tmp
