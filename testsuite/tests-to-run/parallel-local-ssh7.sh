#!/bin/bash

echo '### test --env _'
echo 'Both test that variables are copied,'
echo 'but also that they are NOT copied, if ignored'

par_bash_man() {
  echo '### bash'

  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    alias myecho="echo aliases";
    env_parallel myecho ::: work;
    env_parallel -S server myecho ::: work;
    env_parallel --env myecho myecho ::: work;
    env_parallel --env myecho -S server myecho ::: work

    myfunc() { echo functions $*; };
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc myfunc ::: work;
    env_parallel --env myfunc -S server myfunc ::: work

    myvar=variables;
    env_parallel echo "\$myvar" ::: work;
    env_parallel -S server echo "\$myvar" ::: work;
    env_parallel --env myvar echo "\$myvar" ::: work;
    env_parallel --env myvar -S server echo "\$myvar" ::: work

    myarray=(arrays work, too);
    env_parallel -k echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k -S server echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k --env myarray echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k --env myarray -S server echo "\${myarray[{}]}" ::: 0 1 2
_EOF
  )
  ssh bash@lo "$myscript"
}

par_zsh_man() {
  echo '### zsh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    alias myecho="echo aliases";
    env_parallel myecho ::: work;
    env_parallel -S server myecho ::: work;
    env_parallel --env myecho myecho ::: work;
    env_parallel --env myecho -S server myecho ::: work

    myfunc() { echo functions $*; };
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc myfunc ::: work;
    env_parallel --env myfunc -S server myfunc ::: work

    myvar=variables;
    env_parallel echo "\$myvar" ::: work;
    env_parallel -S server echo "\$myvar" ::: work;
    env_parallel --env myvar echo "\$myvar" ::: work;
    env_parallel --env myvar -S server echo "\$myvar" ::: work

    myarray=(arrays work, too);
    env_parallel -k echo "\${myarray[{}]}" ::: 1 2 3;
    env_parallel -k -S server echo "\${myarray[{}]}" ::: 1 2 3;
    env_parallel -k --env myarray echo "\${myarray[{}]}" ::: 1 2 3;
    env_parallel -k --env myarray -S server echo "\${myarray[{}]}" ::: 1 2 3
_EOF
  )
  ssh zsh@lo "$myscript"
}

par_ksh_man() {
  echo '### ksh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.ksh`;
    alias myecho="echo aliases";
    env_parallel myecho ::: work;
    env_parallel -S server myecho ::: work;
    env_parallel --env myecho myecho ::: work;
    env_parallel --env myecho -S server myecho ::: work

    . `which env_parallel.ksh`;
    myfunc() { echo functions $*; };
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc myfunc ::: work;
    env_parallel --env myfunc -S server myfunc ::: work

    . `which env_parallel.ksh`;
    myvar=variables;
    env_parallel echo "\$myvar" ::: work;
    env_parallel -S server echo "\$myvar" ::: work;
    env_parallel --env myvar echo "\$myvar" ::: work;
    env_parallel --env myvar -S server echo "\$myvar" ::: work

    . `which env_parallel.ksh`;
    myarray=(arrays work, too);
    env_parallel -k echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k -S server echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k --env myarray echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k --env myarray -S server echo "\${myarray[{}]}" ::: 0 1 2
_EOF
  )
  ssh ksh@lo "$myscript"
}

par_tcsh_man() {
  echo '### tcsh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    alias myecho 'echo aliases'
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    echo Functions not supported

    set myvar=variables
    env_parallel echo '$myvar' ::: work
    env_parallel -S server echo '$myvar' ::: work
    env_parallel --env myvar echo '$myvar' ::: work
    env_parallel --env myvar -S server echo '$myvar' ::: work

    set myarray=(arrays work, too)
    env_parallel -k echo \$'{myarray[{}]}' ::: 1 2 3
    env_parallel -k -S server echo \$'{myarray[{}]}' ::: 1 2 3
    env_parallel -k --env myarray echo \$'{myarray[{}]}' ::: 1 2 3
    env_parallel -k --env myarray -S server echo \$'{myarray[{}]}' ::: 1 2 3

_EOF
  )
  ssh -tt tcsh@lo "$myscript"
}

par_csh_man() {
  echo '### csh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    source `which env_parallel.csh`;

    alias myecho 'echo aliases'
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    #env_parallel --env myecho myecho ::: work
    #env_parallel --env myecho -S server myecho ::: work

    # Functions not supported

    set myvar=variables
    env_parallel echo '$myvar' ::: work
    env_parallel -S server echo '$myvar' ::: work
    #env_parallel --env myvar echo '$myvar' ::: work
    #env_parallel --env myvar -S server echo '$myvar' ::: work

    set myarray=(arrays work, too)
    env_parallel -k echo \$'{myarray[{}]}' ::: 1 2 3
    env_parallel -k -S server echo \$'{myarray[{}]}' ::: 1 2 3
    #env_parallel -k --env myarray echo \$'{myarray[{}]}' ::: 1 2 3
    #env_parallel -k --env myarray -S server echo \$'{myarray[{}]}' ::: 1 2 3

_EOF
  )
  ssh csh@lo "$myscript"
}

par_bash_underscore() {
  echo '### bash'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

    env_parallel --record-env;
    alias myecho="echo \$myvar aliases in";
    myfunc() { myecho ${myarray[@]} functions $*; };
    myvar="variables in";
    myarray=(and arrays in);
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho -S server myfunc ::: work;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;

    echo myvar >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myarray >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myecho >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if no myecho     ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if no myecho     ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
    echo myfunc >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if no myfunc     ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if no myfunc     ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
_EOF
  )
  ssh bash@lo "$myscript"
}

par_zsh_underscore() {
  echo '### zsh'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

    . `which env_parallel.zsh`;
    env_parallel --record-env;
    alias myecho="echo \$myvar aliases in";
    eval `cat <<"_EOS";
    myfunc() { myecho ${myarray[@]} functions $*; };
    myvar="variables in";
    myarray=(and arrays in);
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho -S server myfunc ::: work;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;

    echo myvar >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myarray >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myecho >> ~/.parallel/ignored_vars;
    : Not using the function, because aliases are expanded in functions;
    env_parallel --env _ myecho ::: work;
    echo OK if no .^^^^^^^^^^^^^^^^^^^^^^^^^ myecho >&2;
    env_parallel --env _ -S server myecho ::: work;
    echo OK if no .^^^^^^^^^^^^^^^^^^^^^^^^^ myecho >&2;
    echo myfunc >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo OK if no .^^^^^^^^^^^^^^^^^^^^^^^^^ myfunc >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo OK if no .^^^^^^^^^^^^^^^^^^^^^^^^^ myfunc >&2;
_EOS`
_EOF
  )
  ssh zsh@lo "$myscript"
}

par_ksh_underscore() {
  echo '### ksh'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

    . `which env_parallel.ksh`;
    env_parallel --record-env;
    alias myecho="echo \$myvar aliases in";
    myfunc() { myecho ${myarray[@]} functions $*; };
    myvar="variables in";
    myarray=(and arrays in);
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho -S server myfunc ::: work;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;

    echo myvar >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myarray >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myecho >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if no myecho    ^^^^^^^^^^^^^^^^^" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if no myecho    ^^^^^^^^^^^^^^^^^" >&2;
    echo myfunc >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if no myfunc         ^^^^^^^^^^^^^^^^^" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if no myfunc         ^^^^^^^^^^^^^^^^^" >&2;
_EOF
  )
  ssh ksh@lo "$myscript"
}

# Test env_parallel:
# + for each shell
# + remote, locally
# + variables, variables with funky content, arrays, assoc array, functions, aliases

par_bash_funky() {
  myscript=$(cat <<'_EOF'
    myvar="myvar  works"
    funky=$(perl -e "print pack \"c*\", 1..255")
    myarray=("" array_val2 3 "" 5 "  space  6  ")
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
_EOF
  )
  ssh bash@lo "$myscript"
}

par_zsh_funky() {
  myscript=$(cat <<'_EOF'
    myvar="myvar  works"
    funky=$(perl -e "print pack \"c*\", 1..255")
    myarray=("" array_val2 3 "" 5 "  space  6  ")
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
_EOF
  )
  ssh zsh@lo "$myscript"
}

par_ksh_funky() {
  myscript=$(cat <<'_EOF'
    . `which env_parallel.ksh`;

    myvar="myvar  works"
    funky=$(perl -e "print pack \"c*\", 1..255")
    myarray=("" array_val2 3 "" 5 "  space  6  ")
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
_EOF
  )
  ssh ksh@lo "$myscript"
}

par_fish_funky() {
  myscript=$(cat <<'_EOF'
    set myvar "myvar  works"
    setenv myenvvar "myenvvar  works"

    set funky (perl -e "print pack \"c*\", 1..255")
    setenv funkyenv (perl -e "print pack \"c*\", 1..255")

    set myarray "" array_val2 3 "" 5 "  space  6  "

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
_EOF
  )
  ssh fish@lo "$myscript"
}

par_csh_funky() {
  myscript=$(cat <<'_EOF'
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
_EOF
  )
  ssh csh@lo "$myscript"
}


export -f $(compgen -A function | grep par_)
# Tested with -j1..8
# -j6 was fastest
compgen -A function | grep par_ | sort | parallel -j6 --tag -k '{} 2>&1'
