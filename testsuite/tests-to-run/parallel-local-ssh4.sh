#!/bin/bash

# TODO ksh fish

unset run_test

# SSH only allowed to localhost/lo
# --retries if ssh dies
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj1 --retries 2 -k --joblog /tmp/jl-`basename $0` -L1
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
myarray=('' array_val2 3 '' 5)
declare -A assocarr
assocarr[a]=assoc_val_a
assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";
func_echo() {
  echo $*;
  echo "$myvar"
  echo ${myarray[1]}
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
myarray=('' array_val2 3 '' 5)
declare -A assocarr
assocarr[a]=assoc_val_a
assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";
func_echo() {
  echo $*;
  echo "$myvar"
  echo $myarray[2]
  echo ${assocarr[a]}
  echo Funky-"$funky"-funky
}

# alias does not work:
#   http://unix.stackexchange.com/questions/223534/defining-an-alias-and-immediately-use-it
env_parallel alias_echo ::: alias_does_not_work
env_parallel func_echo ::: function_works
env_parallel -S zsh@lo alias_echo ::: alias_does_not_work_over_ssh
env_parallel -S zsh@lo func_echo ::: function_works_over_ssh
echo
echo "$funky" | parallel --shellquote
EOS

echo
echo "### Ksh environment"
stdout ssh -q ksh@lo <<'EOS' | egrep -v 'Welcome to |packages can be updated|security updates'
myvar="myvar  works"
funky=$(perl -e 'print pack "c*", 1..255')
myarray=('' array_val2 3 '' 5)
typeset -A assocarr
assocarr[a]=assoc_val_a
assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";

func_echo() {
  echo $*;
  echo "$myvar"
  echo ${myarray[1]}
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

set myarray '' array_val2 3 '' 5
# Assoc arrays do not exist
#typeset -A assocarr
#assocarr[a]=assoc_val_a
#assocarr[b]=assoc_val_b
alias alias_echo="echo 3 arg";

function func_echo
  echo $argv;
  echo "$myvar"
  echo "$myenvvar"
  echo $myarray[2]
# Assoc arrays do not exist in fish
#  echo ${assocarr[a]}
  echo
  echo
  echo
  echo Funky-"$funky"-funky
  echo Funky-"$funkyenv"-funky
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
# http://hyperpolyglot.org/unix-shells
# makealias:
#   alias quote     "/bin/sed -e 's/\\!/\\\\\!/g' -e 's/'\\\''/'\\\'\\\\\\\'\\\''/g' -e 's/^/'\''/' -e 's/"\$"/'\''/'"
#   alias makealias "quote | /bin/sed 's/^/alias \!:1 /' \!:2*"
#
#   makealias_with_newline
#   perl -e '$/=undef;$_=<>;s/\n/\\\n/g;s/\047/\047\042\047\042\047/g;print'

stdout ssh -q csh@lo <<'EOS' | egrep -v 'Welcome to |packages can be updated|security updates'
set myvar = "myvar  works"
set funky = "`perl -e 'print pack q(c*), 1..255'`"
set myarray = ('' 'array_val2' '3' '' '5')
#declare -A assocarr
#assocarr[a]=assoc_val_a
#assocarr[b]=assoc_val_b
alias alias_echo echo 3 arg;
alias alias_echo_var 'echo $argv; echo $myvar; echo ${myarray[2]}; echo Funky-"$funky"-funky'

#function func_echo
#  echo $argv;
#  echo $myvar;
#  echo ${myarray[2]}
#  #echo ${assocarr[a]}
#  echo Funky-"$funky"-funky
#end

# ALIAS TO EXPORT ALIASES:

#   Quote ' by putting it inside "
#   s/'/'"'"'/g;
#   ' => \047 " => \042
#   s/\047/\047\042\047\042\047/g;
#   Quoted: s/\\047/\\047\\042\\047\\042\\047/g\;

#   Remove () from second column
#   s/^(\S+)(\s+)\((.*)\)/\1\2\3/
#   \047 => '
#   s/^(\S+)(\s+)\((.*)\)/\1\2\3/;
#   Quoted: s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;

#   Add ' around second column
#   s/^(\S+)(\s+)(.*)/\1\2'\3'/
#   \047 => '
#   s/^(\S+)(\s+)(.*)/\1\2\047\3\047/;
#   Quoted: s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;

#   Quote ! as \!
#   s/\!/\\\!/g;
#   Quoted: s/\\\!/\\\\\\\!/g;

#   Prepend with "\nalias "
#   s/^/\001alias /;
#   Quoted: s/\^/\\001alias\ /\;

#!# alias env_parallel 'setenv PARALLEL_ENV "`alias | perl -pe s/\\047/\\047\\042\\047\\042\\047/g\;s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;s/\^/\\001alias\ /\;s/\\\!/\\\\\\\!/g;`";parallel \!*; setenv PARALLEL_ENV'


##  set tmpfile=`tempfile`
##  foreach v (`set | awk -e '{print $1}' |grep -v prompt2`);
##  eval if'($?'$v' && ${#'$v'} <= 1) echo scalar'$v'="$'$v'"' >> $tmpfile;
##  eval if'($?'$v' && ${#'$v'} > 1) echo array'$v'="$'$v'"' >> $tmpfile;
##  end
##  cat $tmpfile | parallel --shellquote | perl -pe 's/^scalar(\S+).=/set $1=/ or s/^array(\S+).=(.*)/set $1=($2)/ && s/\\ / /g;'; rm $tmpfile
##  
##  set tmpfile=`tempfile`
##  foreach _vARnAmE (`set | awk -e '{print $1}' |grep -v prompt2`);
##  eval if'($?'$_vARnAmE' && ${#'$_vARnAmE'} <= 1) echo scalar'$_vARnAmE'="$'$_vARnAmE'"' >> $tmpfile; eval if'($?'$_vARnAmE' && ${#'$_vARnAmE'} > 1) echo array'$_vARnAmE'="$'$_vARnAmE'"' >> $tmpfile;
##  end
##  cat $tmpfile | parallel --shellquote | perl -pe 's/^scalar(\S+).=/set $1=/ or s/^array(\S+).=(.*)/set $1=($2)/ && s/\\ / /g;'; rm $tmpfile; unset tmpfile
##  
##  #!/bin/csh
##  
##  set _tmpfile=`tempfile`;
##  foreach _vARnAmE (`set | awk -e '{print $1}' |grep -Ev 'prompt2|_tmpfile'`);
##  eval if'($?'$_vARnAmE' && ${#'$_vARnAmE'} <= 1) echo scalar'$_vARnAmE'="$'$_vARnAmE'"' >> $_tmpfile;
##  eval if'($?'$_vARnAmE' && ${#'$_vARnAmE'} > 1) echo array'$_vARnAmE'="$'$_vARnAmE'"' >> $_tmpfile;
##  end 
##  setenv PARALLEL_ENV `cat $_tmpfile | parallel --shellquote | perl -pe 's/^scalar(\S+).=/set $1=/ or s/^array(\S+).=(.*)/set $1=($2)/ && s/\\ / /g; s/$/\001/';`
##  rm $_tmpfile;
##  unset _tmpfile
##  
##  setenv PARALLEL_ENV "$PARALLEL_ENV`alias | perl -pe s/\\047/\\047\\042\\047\\042\\047/g\;s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;s/\^/\\001alias\ /\;s/\\\!/\\\\\\\!/g;`"
##  parallel \!*
##  setenv PARALLEL_ENV
##  
##  
##  perl -e '$/=undef;$_=<>;s/\n/\\\\\n/g;s/\047/\047\042\047\042\047/g;print "eval \047$_\047"'
##  
##  foreach g (h i j)
##  echo $g
##  end
##  
##  


env_parallel alias_echo ::: alias_works
env_parallel alias_echo_var ::: alias_var_does_not_work
env_parallel func_echo ::: function_does_not_work
env_parallel -S csh@lo alias_echo ::: alias_works_over_ssh
env_parallel -S csh@lo alias_echo_var ::: alias_var_does_not_work
env_parallel -S csh@lo func_echo ::: function_does_not_work_over_ssh
echo
echo "$funky" | parallel --shellquote
EOS

