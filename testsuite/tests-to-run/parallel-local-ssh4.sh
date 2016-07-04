#!/bin/bash

# TODO ksh fish

unset run_test

# SSH only allowed to localhost/lo
# --retries if ssh dies
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj4 --retries 2 -k --joblog /tmp/jl-`basename $0` -L1
echo '### --env from man env_parallel'
echo '### bash'
ssh bash@lo ' 
  alias myecho="echo aliases"; 
  env_parallel myecho ::: work; 
  env_parallel -S server myecho ::: work; 
  env_parallel --env myecho myecho ::: work; 
  env_parallel --env myecho -S server myecho ::: work 
'

ssh bash@lo ' 
  myfunc() { echo functions $*; }; 
  env_parallel myfunc ::: work; 
  env_parallel -S server myfunc ::: work; 
  env_parallel --env myfunc myfunc ::: work; 
  env_parallel --env myfunc -S server myfunc ::: work 
'

ssh bash@lo ' 
  myvar=variables; 
  env_parallel echo "\$myvar" ::: work; 
  env_parallel -S server echo "\$myvar" ::: work; 
  env_parallel --env myvar echo "\$myvar" ::: work; 
  env_parallel --env myvar -S server echo "\$myvar" ::: work 
'

ssh bash@lo ' 
  myarray=(arrays work, too); 
  env_parallel -k echo "\${myarray[{}]}" ::: 0 1 2; 
  env_parallel -k -S server echo "\${myarray[{}]}" ::: 0 1 2; 
  env_parallel -k --env myarray echo "\${myarray[{}]}" ::: 0 1 2; 
  env_parallel -k --env myarray -S server echo "\${myarray[{}]}" ::: 0 1 2 
'

echo '### zsh'

ssh zsh@lo ' 
  alias myecho="echo aliases"; 
  env_parallel myecho ::: work; 
  env_parallel -S server myecho ::: work; 
  env_parallel --env myecho myecho ::: work; 
  env_parallel --env myecho -S server myecho ::: work 
'

ssh zsh@lo ' 
  myfunc() { echo functions $*; }; 
  env_parallel myfunc ::: work; 
  env_parallel -S server myfunc ::: work; 
  env_parallel --env myfunc myfunc ::: work; 
  env_parallel --env myfunc -S server myfunc ::: work 
'

ssh zsh@lo ' 
  myvar=variables; 
  env_parallel echo "\$myvar" ::: work; 
  env_parallel -S server echo "\$myvar" ::: work; 
  env_parallel --env myvar echo "\$myvar" ::: work; 
  env_parallel --env myvar -S server echo "\$myvar" ::: work 
'

ssh zsh@lo ' 
  myarray=(arrays work, too); 
  env_parallel -k echo "\${myarray[{}]}" ::: 1 2 3; 
  env_parallel -k -S server echo "\${myarray[{}]}" ::: 1 2 3; 
  env_parallel -k --env myarray echo "\${myarray[{}]}" ::: 1 2 3; 
  env_parallel -k --env myarray -S server echo "\${myarray[{}]}" ::: 1 2 3 
'

echo '### ksh'
ssh ksh@lo ' 
  . `which env_parallel.ksh`; 
  alias myecho="echo aliases"; 
  env_parallel myecho ::: work; 
  env_parallel -S server myecho ::: work; 
  env_parallel --env myecho myecho ::: work; 
  env_parallel --env myecho -S server myecho ::: work 
'

ssh ksh@lo ' 
  . `which env_parallel.ksh`; 
  myfunc() { echo functions $*; }; 
  env_parallel myfunc ::: work; 
  env_parallel -S server myfunc ::: work; 
  env_parallel --env myfunc myfunc ::: work; 
  env_parallel --env myfunc -S server myfunc ::: work 
'

ssh ksh@lo ' 
  . `which env_parallel.ksh`; 
  myvar=variables; 
  env_parallel echo "\$myvar" ::: work; 
  env_parallel -S server echo "\$myvar" ::: work; 
  env_parallel --env myvar echo "\$myvar" ::: work; 
  env_parallel --env myvar -S server echo "\$myvar" ::: work 
'

ssh ksh@lo ' 
  . `which env_parallel.ksh`; 
  myarray=(arrays work, too); 
  env_parallel -k echo "\${myarray[{}]}" ::: 0 1 2; 
  env_parallel -k -S server echo "\${myarray[{}]}" ::: 0 1 2; 
  env_parallel -k --env myarray echo "\${myarray[{}]}" ::: 0 1 2; 
  env_parallel -k --env myarray -S server echo "\${myarray[{}]}" ::: 0 1 2 
'

echo '### --env _'
  fUbAr="OK FUBAR" parallel -S parallel@lo --env _ echo '$fUbAr $DEBEMAIL' ::: test
  fUbAr="OK FUBAR" parallel -S csh@lo --env _ echo '$fUbAr $DEBEMAIL' ::: test

echo '### --env _ with explicit mentioning of normally ignored var $DEBEMAIL'
  fUbAr="OK FUBAR" parallel -S parallel@lo --env DEBEMAIL,_ echo '$fUbAr $DEBEMAIL' ::: test
  fUbAr="OK FUBAR" parallel -S csh@lo --env DEBEMAIL,_ echo '$fUbAr $DEBEMAIL' ::: test

echo 'bug #40137: SHELL not bash: Warning when exporting funcs'
  . <(printf 'myfunc() {\necho $1\n}'); export -f myfunc; parallel --env myfunc -S lo myfunc ::: no_warning
  . <(printf 'myfunc() {\necho $1\n}'); export -f myfunc; SHELL=/bin/sh parallel --env myfunc -S lo myfunc ::: warning

echo 'env_parallel from man page - transfer non-exported var'
  source $(which env_parallel.bash); 
  var=nonexported env_parallel -S parallel@lo echo '$var' ::: variable

echo 'compared to parallel - no transfer non-exported var'
  var=nonexported parallel -S parallel@lo echo '$var' ::: variable

echo '### zsh'

echo 'env in zsh'
  echo 'Normal variable export'
  export B=\'; 
  PARALLEL_SHELL=/usr/bin/zsh parallel --env B echo '$B' ::: a

  echo 'Function export as variable'
  export myfuncvar="() { echo myfuncvar \$*; }"; 
  PARALLEL_SHELL=/usr/bin/zsh parallel --env myfuncvar myfuncvar ::: a

  echo 'Function export as function'
  myfunc() { echo myfunc $*; }; 
  export -f myfunc; 
  PARALLEL_SHELL=/usr/bin/zsh parallel --env myfunc myfunc ::: a


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
echo '### csh2'
  echo "3 big vars run locally"
  stdout ssh csh@lo 'setenv A `seq 200|xargs`; 
                     setenv B `seq 200 -1 1|xargs`; 
                     setenv C `seq 300 -2 1|xargs`; 
                     parallel --env A,B,C -k echo \$\{\}\|wc ::: A B C'


echo '### rc'
  echo "3 big vars run remotely - length(base64) > 1000"
  stdout ssh rc@lo 'A=`{seq 200}; 
                    B=`{seq 200 -1 1}; 
                    C=`{seq 300 -2 1}; 
                    parallel -Src@lo --env A,B,C -k echo '"'"'${}|wc'"'"' ::: A B C'

echo '### rc2'
  echo "3 big vars run locally"
  stdout ssh rc@lo 'A=`{seq 200}; 
                    B=`{seq 200 -1 1}; 
                    C=`{seq 300 -2 1}; 
                    parallel --env A,B,C -k echo '"'"'${}|wc'"'"' ::: A B C'

echo '### Test tmux works on different shells'
  (stdout parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux echo ::: 1 2 3 4; echo $?) | grep -v 'See output';
  (stdout parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux false ::: 1 2 3 4; echo $?) | grep -v 'See output';

  export PARTMUX='parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux '; 
  stdout ssh zsh@lo      "$PARTMUX" 'true  ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh zsh@lo      "$PARTMUX" 'false ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh parallel@lo "$PARTMUX" 'true  ::: 1 2 3 4; echo $?'      | grep -v 'See output'; 
  stdout ssh parallel@lo "$PARTMUX" 'false ::: 1 2 3 4; echo $?'      | grep -v 'See output'; 
  stdout ssh tcsh@lo     "$PARTMUX" 'true  ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh tcsh@lo     "$PARTMUX" 'false ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  echo "# command is currently too long for csh. Maybe it can be fixed?"; 
  stdout ssh csh@lo      "$PARTMUX" 'true  ::: 1 2 3 4; echo $status' | grep -v 'See output'; 
  stdout ssh csh@lo      "$PARTMUX" 'false ::: 1 2 3 4; echo $status' | grep -v 'See output'

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
  parallel -Scsh@lo --transferfile {1} --transferfile {2} --trc {1}.a --trc {2}.b 
   '(cat {1}; echo A {1}) > {1}.a; (cat {2};echo B {2}) > {2}.b' ::: file1 ::: file2; 
  cat file1.a file2.b; 
  rm /tmp/file1 /tmp/file2 /tmp/file1.a /tmp/file2.b

echo '### bug #44143: csh and nice'
  parallel --nice 1 -S csh@lo setenv B {}\; echo '$B' ::: OK

echo '### bug #45575: -m and multiple hosts repeats first args'
  seq 1 3 | parallel -X -S 2/lo,2/: -k echo 

EOF

echo
echo Test env_parallel:
echo + for each shell
echo + remote, locally
echo + variables, variables with funky content, arrays, assoc array, functions, aliases
echo
echo "### Bash environment"
#stdout ssh -t lo <<'EOS'
myvar="myvar  works"
funky=$(perl -e 'print pack "c*", 1..255')
myarray=('' array_val2 3 '' 5 '  space  6  ')
declare -A assocarr
assocarr[a]=assoc_val_a
assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";
func_echo() {
  echo $*;
  echo "$myvar"
  echo "${myarray[5]}"
  echo ${assocarr[a]}
  echo Funky-"$funky"-funky
}
. `which env_parallel.bash`
env_parallel alias_echo ::: alias_works
env_parallel func_echo ::: function_works
env_parallel -S lo alias_echo ::: alias_works_over_ssh
env_parallel -S lo func_echo ::: function_works_over_ssh
echo
echo "$funky" | parallel --shellquote
#EOS


echo
echo "### Zsh environment"
stdout ssh -q zsh@lo <<'EOS' | egrep -v 'Welcome to |packages can be updated|security updates'
myvar="myvar  works"
funky=$(perl -e 'print pack "c*", 1..255')
myarray=('' array_val2 3 '' 5 '  space  6  ')
declare -A assocarr
assocarr[a]=assoc_val_a
assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";
func_echo() {
  echo $*;
  echo "$myvar"
  echo "$myarray[6]"
  echo ${assocarr[a]}
  echo Funky-"$funky"-funky
}

env_parallel alias_echo ::: alias_works
env_parallel func_echo ::: function_works
env_parallel -S zsh@lo alias_echo ::: alias_works_over_ssh
env_parallel -S zsh@lo func_echo ::: function_works_over_ssh
echo
echo "$funky" | parallel --shellquote
EOS

echo
echo "### Ksh environment"
stdout ssh -q ksh@lo <<'EOS' | egrep -v 'Welcome to |packages can be updated|security updates'
myvar="myvar  works"
funky=$(perl -e 'print pack "c*", 1..255')
myarray=('' array_val2 3 '' 5 '  space  6  ')
typeset -A assocarr
assocarr[a]=assoc_val_a
assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";

func_echo() {
  echo $*;
  echo "$myvar"
  echo "${myarray[5]}"
  echo ${assocarr[a]}
  echo Funky-"$funky"-funky
}

env_parallel alias_echo ::: alias_works
env_parallel func_echo ::: function_works
env_parallel -S ksh@lo alias_echo ::: alias_works_over_ssh
env_parallel -S ksh@lo func_echo ::: function_works_over_ssh
echo
echo "$funky" | parallel --shellquote
EOS

echo
echo "### Fish environment"
stdout ssh -q fish@lo <<'EOS' | egrep -v 'Welcome to |packages can be updated|security updates'
set myvar "myvar  works"
setenv myenvvar "myenvvar  works"

set funky (perl -e 'print pack "c*", 1..255')
setenv funkyenv (perl -e 'print pack "c*", 1..255')

set myarray '' array_val2 3 '' 5 '  space  6  '

# Assoc arrays do not exist
#typeset -A assocarr
#assocarr[a]=assoc_val_a
#assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";

function func_echo
  echo $argv;
  echo "$myvar"
  echo "$myenvvar"
  echo "$myarray[6]"
# Assoc arrays do not exist in fish
#  echo ${assocarr[a]}
  echo
  echo
  echo
  echo Funky-"$funky"-funky
  echo Funkyenv-"$funkyenv"-funkyenv
  echo
  echo
  echo
end

env_parallel alias_echo ::: alias_works
env_parallel func_echo ::: function_works
env_parallel -S fish@lo alias_echo ::: alias_works_over_ssh
env_parallel -S fish@lo func_echo ::: function_works_over_ssh
echo 
echo "$funky" | parallel --shellquote
EOS

echo 
echo "### csh environment"
stdout ssh -q csh@lo <<'EOS' | egrep -v 'Welcome to |packages can be updated|security updates'
set myvar = "myvar  works"
set funky = "`perl -e 'print pack q(c*), 2..255'`"
set myarray = ('' 'array_val2' '3' '' '5' '  space  6  ')
#declare -A assocarr
#assocarr[a]=assoc_val_a
#assocarr[b]=assoc_val_b
alias alias_echo echo 3 arg;
alias alias_echo_var 'echo $argv; echo "$myvar"; echo "${myarray[4]} special chars problem"; echo Funky-"$funky"-funky'

#function func_echo
#  echo $argv;
#  echo $myvar;
#  echo ${myarray[2]}
#  #echo ${assocarr[a]}
#  echo Funky-"$funky"-funky
#end

env_parallel alias_echo ::: alias_works
env_parallel alias_echo_var ::: alias_var_works
env_parallel func_echo ::: function_does_not_work
env_parallel -S csh@lo alias_echo ::: alias_works_over_ssh
env_parallel -S csh@lo alias_echo_var ::: alias_var_works_over_ssh
env_parallel -S csh@lo func_echo ::: function_does_not_work_over_ssh
echo
echo "$funky" | parallel --shellquote
EOS

