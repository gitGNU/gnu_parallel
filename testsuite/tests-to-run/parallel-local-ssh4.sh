#!/bin/bash

# SSH only allowed to localhost/lo
# --retries if ssh dies
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj1 --retries 2 -k --joblog /tmp/jl-`basename $0` -L1
echo '### zsh'
  ssh zsh@lo 'fun="() { echo function from zsh to zsh \$*; }"; 
              export fun; 
              parallel --env fun fun ::: OK'

  ssh zsh@lo 'fun="() { echo function from zsh to bash \$*; }"; 
              export fun; 
              parallel -S parallel@lo --env fun fun ::: OK'

echo '### csh'
  echo "3 big vars run remotely - length(base64) > 1000"
  stdout ssh csh@lo 'setenv A `seq 200|xargs`; 
                     setenv B `seq 200 -1 1|xargs`; 
                     setenv C `seq 300 -2 1|xargs`; 
                     parallel -Scsh@lo --env A,B,C -k echo \$\{\}\|wc ::: A B C'

  echo "3 big vars run locally"
  stdout ssh csh@lo 'setenv A `seq 200|xargs`; 
                     setenv B `seq 200 -1 1|xargs`; 
                     setenv C `seq 300 -2 1|xargs`; 
                     parallel --env A,B,C -k echo \$\{\}\|wc ::: A B C'

echo '### Test tmux works on different shells'
  parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux echo ::: 1 2 3 4; echo $?
  parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux false ::: 1 2 3 4; echo $?

  export PARTMUX='parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux '; 
  stdout ssh zsh@lo      "$PARTMUX" 'true  ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh zsh@lo      "$PARTMUX" 'false ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh parallel@lo "$PARTMUX" 'true  ::: 1 2 3 4; echo $?'      | grep -v 'See output'; 
  stdout ssh parallel@lo "$PARTMUX" 'false ::: 1 2 3 4; echo $?'      | grep -v 'See output'; 
  stdout ssh tcsh@lo     "$PARTMUX" 'true  ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh tcsh@lo     "$PARTMUX" 'false ::: 1 2 3 4; echo $status' | grep -v 'See output'

echo '### This fails - word too long'
  export PARTMUX='parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux '; 
  stdout ssh csh@lo "$PARTMUX" 'true ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh csh@lo "$PARTMUX" 'false ::: 1 2 3 4; echo $status' | grep -v 'See output'

echo '### works'
  stdout parallel -Sparallel@lo --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@ | grep -v 'See output'
  stdout parallel -Sparallel@lo --tmux echo ::: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | grep -v 'See output'

echo '### These blocked due to length'
  stdout parallel -Slo      --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@ | grep -v 'See output'
  stdout parallel -Scsh@lo  --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@ | grep -v 'See output'
  stdout parallel -Stcsh@lo --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@ | grep -v 'See output'
  stdout parallel -Szsh@lo  --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@ | grep -v 'See output'
  stdout parallel -Scsh@lo  --tmux echo ::: 111111111111111111111111111111111111111111111111111111111 | grep -v 'See output'

echo '### bug #43746: --transfer and --return of multiple inputs {1} and {2}'
echo '### and:'
echo '### bug #44371: --trc with csh complains'
  cd /tmp; echo 1 > file1; echo 2 > file2; 
  parallel -Scsh@lo --trc {1}.a --trc {2}.b 'echo A {1} > {1}.a; echo B {2} > {2}.b' ::: file1 ::: file2; 
  cat file1.a file2.b; 
  rm /tmp/file1 /tmp/file2 /tmp/file1.a /tmp/file2.b

echo '### bug #44143: csh and nice'
  parallel --nice 1 -S csh@lo setenv B {}\; echo '$B' ::: OK

EOF

echo
echo "### Fish environment"
stdout ssh -q fish@lo <<'EOS' | grep -v 'packages can be updated.'
alias alias_echo=echo;
function func_echo
  echo $argv;
end
function env_parallel
  setenv PARALLEL_ENV (functions -n | perl -pe 's/,/\n/g' | while read d; functions $d; end|perl -pe 's/\n/\001/')
  parallel $argv;
  set -e PARALLEL_ENV
end
env_parallel alias_echo ::: alias_works
env_parallel func_echo ::: function_works
env_parallel -S fish@lo alias_echo ::: alias_works_over_ssh
env_parallel -S fish@lo func_echo ::: function_works_over_ssh
EOS

echo
echo "### Zsh environment"
stdout ssh -q zsh@lo <<'EOS' | grep -v 'packages can be updated.'
alias alias_echo=echo;
func_echo() {
  echo $*;
}
env_parallel() {
  PARALLEL_ENV="$(typeset -f)";
  export PARALLEL_ENV
  `which parallel` "$@";
  unset PARALLEL_ENV;
}
env_parallel alias_echo ::: alias_does_not_work
env_parallel func_echo ::: function_works
env_parallel -S zsh@lo alias_echo ::: alias_does_not_work_over_ssh
env_parallel -S zsh@lo func_echo ::: function_works_over_ssh
EOS

echo
echo "### Ksh environment"
stdout ssh -q ksh@lo <<'EOS' | grep -v 'packages can be updated.'
alias alias_echo=echo;
func_echo() {
  echo $*;
}
env_parallel() {
  export PARALLEL_ENV="$(alias | perl -pe 's/^/alias /';typeset -p;typeset -f)";
  `which parallel` "$@";
  unset PARALLEL_ENV;
}
env_parallel alias_echo ::: alias_works
env_parallel func_echo ::: function_works
env_parallel -S ksh@lo alias_echo ::: alias_works_over_ssh
env_parallel -S ksh@lo func_echo ::: function_works_over_ssh
EOS

