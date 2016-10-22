#!/bin/bash

# SSH only allowed to localhost/lo
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj100% --retries 3 -k --joblog /tmp/jl-`basename $0` -L1
echo '### --hostgroup force ncpu'
  parallel --delay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo whoami\;sleep 0.4{} ::: {1..8} | sort

echo '### --hostgroup two group arg'
  parallel -k --sshdelay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo whoami\;sleep 0.3{} ::: {1..8}@g1+g2 | sort

echo '### --hostgroup one group arg'
  parallel --delay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo whoami\;sleep 0.2{} ::: {1..8}@g2

echo '### --hostgroup multiple group arg + unused group'
  parallel --delay 0.1 --hgrp -S @g1/1/parallel@lo -S @g1/3/lo -S @g3/100/tcsh@lo whoami\;sleep 0.4{} ::: {1..8}@g1+g2 | sort

echo '### --hostgroup two groups @'
  parallel -k --hgrp -S @g1/parallel@lo -S @g2/lo --tag whoami\;echo ::: parallel@g1 tange@g2

echo '### --hostgroup'
  parallel -k --hostgroup -S @grp1/lo echo ::: no_group explicit_group@grp1 implicit_group@lo

echo '### --hostgroup --sshlogin with @'
  parallel -k --hostgroups -S parallel@lo echo ::: no_group implicit_group@parallel@lo

echo '### --hostgroup -S @group'
  parallel -S @g1/ -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo whoami\;true ::: {1..6} | sort

echo '### --hostgroup -S @group1 -Sgrp2'
  parallel -S @g1/ -S @g2 -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo whoami\;true ::: {1..6} | sort

echo '### --hostgroup -S @group1+grp2'
  parallel -S @g1+g2 -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo whoami\;true ::: {1..6} | sort

echo '### trailing space in sshlogin'
  echo 'sshlogin trailing space' | parallel  --sshlogin "ssh -l parallel localhost " echo

echo '### Special char file and dir transfer return and cleanup'
  cd /tmp; 
  mkdir -p d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  echo local > d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/f"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  ssh parallel@lo rm -rf d'*'/; 
  mytouch() { 
    cat d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/f"`perl -e 'print pack("c*",1..9,11..46,48..255)'`" > d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
    echo remote OK >> d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  }; 
  export -f mytouch; 
  parallel --env mytouch -Sparallel@lo --transfer 
    --return {=s:/f:/g:=} 
    mytouch 
    ::: d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/f"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  cat d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"

echo '### Uniq {=perlexpr=} in return - not used in command'
  cd /tmp; 
  rm -f /tmp/parallel_perlexpr.2Parallel_PerlexPr; 
  echo local > parallel_perlexpr; 
  parallel -Sparallel@lo --trc {=s/pr/pr.2/=}{=s/p/P/g=} echo remote OK '>' {}.2{=s/p/P/g=} ::: parallel_perlexpr; 
  cat /tmp/parallel_perlexpr.2Parallel_PerlexPr; 
  rm -f /tmp/parallel_perlexpr.2Parallel_PerlexPr /tmp/parallel_perlexpr

#  Should be changed to --return '{=s:/f:/g:=}' and tested with csh - is error code kept?

echo '### functions and --nice'
  myfunc() { echo OK $*; }; export -f myfunc; parallel --nice 10 --env myfunc -S parallel@lo myfunc ::: func

echo '### bug #45906: {= in header =}'
  rm -f returnfile45906; 
  parallel --rpl '{G} $_=lc($_)' -S parallel@lo --return {G} --cleanup echo {G} '>' {G} ::: RETURNFILE45906; 
  ls returnfile45906

echo '### bug #45907: --header : + --return {header}'
  rm returnfile45907; 
  ppar --header : -S parallel@lo --return {G} --cleanup echo {G} '>' {G} ::: G returnfile45907; 
  ls returnfile45907

echo "### bug #47608: parallel --nonall -S lo 'echo ::: ' blocks"
  parallel --nonall -S lo 'echo ::: '

echo '### exported function to csh but with PARALLEL_SHELL=bash'
  doit() { echo "$1"; }; 
  export -f doit; 
  stdout parallel --env doit -S csh@lo doit ::: not_OK; 
  PARALLEL_SHELL=bash parallel --env doit -S csh@lo doit ::: OK

echo '### bug #49404: "Max jobs to run" does not equal the number of jobs specified when using GNU Parallel on remote server?'
  echo should give 12 running jobs
  stdout parallel -S 16/lo --progress true ::: {1..12} | grep /.12

EOF


echo 'bug #47695: How to set $PATH on remote?'
  rm -rf /tmp/parallel
  cp /usr/local/bin/parallel /tmp
  
  cat <<'_EOS' | stdout ssh nopathbash@lo -T | grep -Ev 'packages can be updated|System restart required|Welcome to Ubuntu'
  echo BASH Path before: $PATH with no parallel
  parallel echo ::: 1
  echo '^^^^^^^^ Not found is OK'
  # Exporting a big variable should not fail
  export A="`seq 1000`"
  PATH=$PATH:/tmp
  . /usr/local/bin/env_parallel.bash
  # --filter to see if $PATH with parallel is transferred
  env_parallel --filter --env A,PATH -Slo echo '$PATH' ::: OK
_EOS
  echo
  
  cat <<'_EOS' | stdout ssh nopathcsh@lo -T | grep -Ev 'packages can be updated|System restart required|Welcome to Ubuntu'
  echo CSH Path before: $PATH with no parallel
  which parallel >& /dev/stdout
  echo '^^^^^^^^ Not found is OK'
  alias parallel=/tmp/parallel
  # Exporting a big variable should not fail
  setenv A "`seq 1000`"
  setenv PATH ${PATH}:/tmp
  cp /usr/local/bin/env_parallel* /tmp
  source `which env_parallel.csh`
  # --filter to see if $PATH with parallel is transferred
  env_parallel --filter --env A,PATH -Slo echo '$PATH' ::: OK
  # It fails due to csh word limitation: The perl bunzipper is too long
_EOS

