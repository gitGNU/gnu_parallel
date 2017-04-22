#!/bin/bash

echo '### test --env _'
echo 'Both test that variables are copied,'
echo 'but also that they are NOT copied, if ignored'

#
## par_*_man = tests from the man page
#

par_bash_man() {
  echo '### bash'

  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.bash`;

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

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $? should be 255
_EOF
  )
  ssh bash@lo "$myscript"
}

par_zsh_man() {
  echo '### zsh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.zsh`;

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

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $? should be 255
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

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $? should be 255
_EOF
  )
  ssh ksh@lo "$myscript"
}

_disabled_pdksh_man() {
  echo '### pdksh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.pdksh`;
    alias myecho="echo aliases";
    env_parallel myecho ::: work;
    env_parallel -S server myecho ::: work;
    env_parallel --env myecho myecho ::: work;
    env_parallel --env myecho -S server myecho ::: work

    . `which env_parallel.pdksh`;
    myfunc() { echo functions $*; };
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc myfunc ::: work;
    env_parallel --env myfunc -S server myfunc ::: work

    . `which env_parallel.pdksh`;
    myvar=variables;
    env_parallel echo "\$myvar" ::: work;
    env_parallel -S server echo "\$myvar" ::: work;
    env_parallel --env myvar echo "\$myvar" ::: work;
    env_parallel --env myvar -S server echo "\$myvar" ::: work

    . `which env_parallel.pdksh`;
    myarray=(arrays work, too);
    env_parallel -k echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k -S server echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k --env myarray echo "\${myarray[{}]}" ::: 0 1 2;
    env_parallel -k --env myarray -S server echo "\${myarray[{}]}" ::: 0 1 2

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $? should be 255
_EOF
  )
  ssh pdksh@lo "$myscript"
}

par_tcsh_man() {
  echo '### tcsh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

#    source `which env_parallel.tcsh`

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

    env_parallel ::: true false true false
    echo exit value $status should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $status should be 255
_EOF
  )
  ssh -tt tcsh@lo "$myscript"
}

par_csh_man() {
  echo '### csh'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

#    source `which env_parallel.csh`;

    alias myecho 'echo aliases'
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    # Functions not supported

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

    env_parallel ::: true false true false
    echo exit value $status should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $status should be 255
_EOF
  )
  # Sometimes the order f*cks up
  stdout ssh csh@lo "$myscript" | sort
}

par_fish_man() {
  echo '### fish'
  myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    alias myecho 'echo aliases'
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    function myfunc
      echo functions $argv
    end
    env_parallel myfunc ::: work
    env_parallel -S server myfunc ::: work
    env_parallel --env myfunc myfunc ::: work
    env_parallel --env myfunc -S server myfunc ::: work

    set myvar variables
    env_parallel echo '$myvar' ::: work
    env_parallel -S server echo '$myvar' ::: work
    env_parallel --env myvar echo '$myvar' ::: work
    env_parallel --env myvar -S server echo '$myvar' ::: work

    set myarray arrays work, too
    env_parallel -k echo '$myarray[{}]' ::: 1 2 3
    env_parallel -k -S server echo '$myarray[{}]' ::: 1 2 3
    env_parallel -k --env myarray echo '$myarray[{}]' ::: 1 2 3
    env_parallel -k --env myarray -S server echo '$myarray[{}]' ::: 1 2 3

    env_parallel ::: true false true false
    echo exit value $status should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $status should be 255
_EOF
  )
  ssh fish@lo "$myscript"
}


#
## par_*_underscore = tests with --env _
#

par_bash_underscore() {
  echo '### bash'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

    . `which env_parallel.bash`;

    alias not_copied_alias="echo BAD"
    not_copied_func() { echo BAD; };
    not_copied_var=BAD
    not_copied_array=(BAD BAD BAD);
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

    env_parallel --env _ -S server not_copied_alias ::: error=OK;
    env_parallel --env _ -S server not_copied_func ::: error=OK;
    env_parallel --env _ -S server echo \$not_copied_var ::: error=OK;
    env_parallel --env _ -S server echo \${not_copied_array[@]} ::: error=OK;

    echo myvar >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myarray >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myecho >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if no myecho      ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if no myecho      ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
    echo myfunc >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if no myfunc      ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if no myfunc      ^^^^^^^^^^^^^^^^^^^^^^^^^" >&2;
_EOF
  )
  ssh bash@lo "$myscript"
}

par_zsh_underscore() {
  echo '### zsh'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

    . `which env_parallel.zsh`;

    alias not_copied_alias="echo BAD"
    not_copied_func() { echo BAD; };
    not_copied_var=BAD
    not_copied_array=(BAD BAD BAD);
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

    env_parallel --env _ -S server not_copied_alias ::: error=OK;
    env_parallel --env _ -S server not_copied_func ::: error=OK;
    env_parallel --env _ -S server echo \$not_copied_var ::: error=OK;
    env_parallel --env _ -S server echo \$\{not_copied_array\[\@\]\} ::: error=OK;

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

    alias not_copied_alias="echo BAD"
    not_copied_func() { echo BAD; };
    not_copied_var=BAD
    not_copied_array=(BAD BAD BAD);
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

    env_parallel --env _ -S server not_copied_alias ::: error=OK;
    env_parallel --env _ -S server not_copied_func ::: error=OK;
    env_parallel --env _ -S server echo \$not_copied_var ::: error=OK;
    env_parallel --env _ -S server echo \${not_copied_array[@]} ::: error=OK;

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

_disabled_pdksh_underscore() {
  echo '### pdksh'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

    alias not_copied_alias="echo BAD"
    not_copied_func() { echo BAD; };
    not_copied_var=BAD
    not_copied_array=(BAD BAD BAD);
    . `which env_parallel.pdksh`;
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

    env_parallel --env _ -S server not_copied_alias ::: error=OK;
    env_parallel --env _ -S server not_copied_func ::: error=OK;
    env_parallel --env _ -S server echo \$not_copied_var ::: error=OK;
    env_parallel --env _ -S server echo \${not_copied_array[@]} ::: error=OK;

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
  ssh pdksh@lo "$myscript"
}

par_tcsh_underscore() {
  echo '### tcsh'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

#    source `which env_parallel.tcsh`;

    env_parallel --record-env;
    alias myecho "echo "\$"myvar "\$'myarray'" aliases";
    set myvar="variables";
    set myarray=(and arrays in);
    env_parallel myecho ::: work;
    env_parallel -S server myecho ::: work;
    env_parallel --env myvar,myarray,myecho myecho ::: work;
    env_parallel --env myvar,myarray,myecho -S server myecho ::: work;
    env_parallel --env _ myecho ::: work;
    env_parallel --env _ -S server myecho ::: work;

    echo myvar >> ~/.parallel/ignored_vars;
    env_parallel --env _ myecho ::: work;
    env_parallel --env _ -S server myecho ::: work;
    alias myecho "echo "\$'myarray'" aliases";
    echo myarray >> ~/.parallel/ignored_vars;
    env_parallel --env _ myecho ::: work;
    env_parallel --env _ -S server myecho ::: work;
    echo myecho >> ~/.parallel/ignored_vars;
    env_parallel --env _ myecho ::: work;
    echo "OK      ^^^^^^^^^^^^^^^^^ if no myecho" >/dev/stderr;
    env_parallel --env _ -S server myecho ::: work;
    echo "OK      ^^^^^^^^^^^^^^^^^ if no myecho" >/dev/stderr;
_EOF
  )
  ssh -tt tcsh@lo "$myscript"
}

par_csh_underscore() {
  echo '### csh'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

#    source `which env_parallel.csh`;

    env_parallel --record-env;
    alias myecho "echo "\$"myvar "\$'myarray'" aliases";
    set myvar="variables";
    set myarray=(and arrays in);
    env_parallel myecho ::: work;
    env_parallel -S server myecho ::: work;
    env_parallel --env myvar,myarray,myecho myecho ::: work;
    env_parallel --env myvar,myarray,myecho -S server myecho ::: work;
    env_parallel --env _ myecho ::: work;
    env_parallel --env _ -S server myecho ::: work;

    echo myvar >> ~/.parallel/ignored_vars;
    env_parallel --env _ myecho ::: work;
    env_parallel --env _ -S server myecho ::: work;
    alias myecho "echo "\$'myarray'" aliases";
    echo myarray >> ~/.parallel/ignored_vars;
    env_parallel --env _ myecho ::: work;
    env_parallel --env _ -S server myecho ::: work;
    echo myecho >> ~/.parallel/ignored_vars;
    env_parallel --env _ myecho ::: work;
    echo "OK      ^^^^^^^^^^^^^^^^^ if no myecho" >/dev/stderr;
    env_parallel --env _ -S server myecho ::: work;
    echo "OK      ^^^^^^^^^^^^^^^^^ if no myecho" >/dev/stderr;
_EOF
  )
  ssh -tt csh@lo "$myscript"
}

par_fish_underscore() {
  echo '### fish'
  myscript=$(cat <<'_EOF'
    echo "### Testing of --env _"

#    . `which env_parallel.fish`;

    alias not_copied_alias="echo BAD"
    function not_copied_func
      echo BAD
    end
    set not_copied_var "BAD";
    set not_copied_array BAD BAD BAD;
    env_parallel --record-env;
    alias myecho="echo \$myvar aliases";
    function myfunc
      myecho $myarray functions $argv
    end
    set myvar "variables in";
    set myarray and arrays in;
    env_parallel myfunc ::: work;
    env_parallel -S server myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho myfunc ::: work;
    env_parallel --env myfunc,myvar,myarray,myecho -S server myfunc ::: work;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;

    env_parallel --env _ -S server not_copied_alias ::: error=OK;
    env_parallel --env _ -S server not_copied_func ::: error=OK;
    env_parallel --env _ -S server echo \$not_copied_var ::: error=OK;
    env_parallel --env _ -S server echo \$not_copied_array ::: error=OK;

    echo myvar >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myarray >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    env_parallel --env _ -S server myfunc ::: work;
    echo myecho >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if   ^^^^^^^^^^^^^^^^^ no myecho" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if   ^^^^^^^^^^^^^^^^^ no myecho" >&2;
    echo myfunc >> ~/.parallel/ignored_vars;
    env_parallel --env _ myfunc ::: work;
    echo "OK if   ^^^^^^^^^^^^^^^^^ no myfunc" >&2;
    env_parallel --env _ -S server myfunc ::: work;
    echo "OK if   ^^^^^^^^^^^^^^^^^ no myfunc" >&2;
_EOF
  )

  # Old versions of fish sometimes throw up bugs all over,
  # but seem to work OK otherwise. So ignore these errors.
  ssh fish@lo "$myscript" 2>&1 |
  perl -ne '/fish:|fish\(/ and next; print'
}

# Test env_parallel:
# + for each shell
# + remote, locally
# + variables, variables with funky content, arrays, assoc array, functions, aliases

par_bash_funky() {
  myscript=$(cat <<'_EOF'
    . `which env_parallel.bash`;

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
    env_parallel alias_echo ::: alias_works
    env_parallel func_echo ::: function_works
    env_parallel -S lo alias_echo ::: alias_works_over_ssh
    env_parallel -S lo func_echo ::: function_works_over_ssh
    echo
    echo "$funky" | parallel --shellquote
_EOF
  )
  # Order is often different. Dunno why. So sort
  ssh bash@lo "$myscript" 2>&1 | sort
}

par_zsh_funky() {
  myscript=$(cat <<'_EOF'

    . `which env_parallel.zsh`;

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
  # Order is often different. Dunno why. So sort
  ssh zsh@lo "$myscript" 2>&1 | sort
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
  # Order is often different. Dunno why. So sort
  ssh ksh@lo "$myscript" 2>&1 | sort
}

_disabled_pdksh_funky() {
  myscript=$(cat <<'_EOF'
    . `which env_parallel.pdksh`;

    myvar="myvar  works"
    funky=$(perl -e "print pack \"c*\", 1..255")
    myarray=("" array_val2 3 "" 5 "  space  6  ")
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
    env_parallel -S lo alias_echo ::: alias_works_over_ssh
    env_parallel -S lo func_echo ::: function_works_over_ssh
    echo
    echo "$funky" | parallel --shellquote
_EOF
  )
  ssh pdksh@lo "$myscript"
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

par_tcsh_funky() {
  myscript=$(cat <<'_EOF'
    # funky breaks with different LANG
    setenv LANG C
    set myvar = "myvar  works"
    set funky = "`perl -e 'print pack q(c*), 2..255'`"
    set myarray = ('' 'array_val2' '3' '' '5' '  space  6  ')
    # declare -A assocarr
    # assocarr[a]=assoc_val_a
    # assocarr[b]=assoc_val_b
    alias alias_echo echo 3 arg;
    alias alias_echo_var 'echo $argv; echo "$myvar"; echo "${myarray[4]} special chars problem"; echo Funky-"$funky"-funky'

    # function func_echo
    #  echo $argv;
    #  echo $myvar;
    #  echo ${myarray[2]}
    #  #echo ${assocarr[a]}
    #  echo Funky-"$funky"-funky
    # end

    env_parallel alias_echo ::: alias_works
    env_parallel alias_echo_var ::: alias_var_works
    env_parallel func_echo ::: function_does_not_work
    env_parallel -S tcsh@lo alias_echo ::: alias_works_over_ssh
    env_parallel -S tcsh@lo alias_echo_var ::: alias_var_works_over_ssh
    env_parallel -S tcsh@lo func_echo ::: function_does_not_work_over_ssh
    echo
    echo "$funky" | parallel --shellquote
_EOF
  )
  # Order is often different. Dunno why. So sort
  ssh tcsh@lo "$myscript" 2>&1 | sort
}

par_bash_env_parallel_fifo() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50435: Remote fifo broke in 20150522'
    # Due to $PARALLEL_TMP being transferred
    OK=OK
    echo data from stdin | env_parallel --pipe -S lo --fifo 'cat {} && echo $OK'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {} && echo $OK'
_EOF
  )
  # Order is often different. Dunno why. So sort
  ssh bash@lo "$myscript" 2>&1 | sort
}

par_zsh_env_parallel_fifo() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50435: Remote fifo broke in 20150522'
    # Due to $PARALLEL_TMP being transferred
    OK=OK
    echo data from stdin | env_parallel --pipe -S lo --fifo 'cat {} && echo $OK'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {} && echo $OK'
_EOF
  )
  # Order is often different. Dunno why. So sort
  ssh zsh@lo "$myscript" 2>&1 | sort
}

par_ksh_env_parallel_fifo() {
  myscript=$(cat <<'_EOF'
    . `which env_parallel.ksh`;
    echo 'bug #50435: Remote fifo broke in 20150522'
    # Due to $PARALLEL_TMP being transferred
    OK=OK
    echo data from stdin | env_parallel --pipe -S lo --fifo 'cat {} && echo $OK'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {} && echo $OK'
_EOF
  )
  # Order is often different. Dunno why. So sort
  ssh ksh@lo "$myscript" 2>&1 | sort
}

par_fish_env_parallel_fifo() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50435: Remote fifo broke in 20150522'
    # Due to $PARALLEL_TMP being transferred
    set OK OK
    echo data from stdin | env_parallel --pipe -S lo --fifo 'cat {}; and echo $OK'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {}; and echo $OK'
_EOF
  )
  ssh fish@lo "$myscript"
}

par_csh_env_parallel_fifo() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50435: Remote fifo broke in 20150522'
    # Due to $PARALLEL_TMP being transferred
    set OK=OK
    echo data from stdin | env_parallel --pipe -S lo --fifo 'cat {} && echo $OK'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {} && echo $OK'
_EOF
  )
  ssh csh@lo "$myscript"
}

par_tcsh_env_parallel_fifo() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50435: Remote fifo broke in 20150522'
    # Due to $PARALLEL_TMP being transferred
    set OK=OK
    echo data from stdin | env_parallel --pipe -S lo --fifo 'cat {} && echo $OK'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {} && echo $OK'
_EOF
  )
  # Order is often different. Dunno why. So sort
  ssh tcsh@lo "$myscript" 2>&1 | sort
}

par_bash_environment_too_big() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    . `which env_parallel.bash`;
    bigvar="$(yes | head -c 119k)"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(yes \"| head -c 79k)"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar=u
    eval 'bigfunc() { a="'"$(yes a| head -c 120k)"'"; };'
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(yes | head -c 120k)"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar="$(yes \"| head -c 80k)"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar=u
    eval 'bigfunc() { a="'"$(yes a| head -c 121k)"'"; };'
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail
_EOF
  )
  ssh bash@lo "$myscript"
}

par_dash_environment_too_big() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    . `which env_parallel.dash`;
    bigvar="$(perl -e 'print "x"x130000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "\""x65000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

#    Functions not supported om ash
#    bigvar=u
#    eval 'bigfunc() { a="'"$(perl -e 'print "\""x126000')"'"; };'
#    env_parallel echo ::: OK
#    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "x"x131000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar="$(perl -e 'print "\""x66000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

#    Functions not supported om ash
#    bigvar=u
#    eval 'bigfunc() { a="'"$(perl -e 'print "\""x126000')"'"; };'
#    env_parallel echo ::: OK
#    env_parallel -S lo echo ::: OK
_EOF
  )
  ssh dash@lo "$myscript"
}

par_ash_environment_too_big() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    . `which env_parallel.ash`;
    bigvar="$(perl -e 'print "x"x130000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "\""x65000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

#    Functions not supported in ash
#    bigvar=u
#    eval 'bigfunc() { a="'"$(perl -e 'print "\""x126000')"'"; };'
#    env_parallel echo ::: OK
#    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "x"x131000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar="$(perl -e 'print "\""x66000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

#    Functions not supported in ash
#    bigvar=u
#    eval 'bigfunc() { a="'"$(perl -e 'print "\""x126000')"'"; };'
#    env_parallel echo ::: OK
#    env_parallel -S lo echo ::: OK
_EOF
  )
  ssh ash@lo "$myscript"
}

par_sh_environment_too_big() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    . `which env_parallel.sh`;
    bigvar="$(perl -e 'print "x"x130000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "\""x65000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

#    Functions not supported on GNU/Linux
#    bigvar=u
#    eval 'bigfunc() { a="'"$(perl -e 'print "\\\""x133000')"'"; };'
#    env_parallel echo ::: OK
#    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "x"x131000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar="$(perl -e 'print "\""x66000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

#    Functions not supported on GNU/Linux
#    bigvar=u
#    eval 'bigfunc() { a="'"$(perl -e 'print "\""x132000')"'"; };'
#    env_parallel echo ::: fail
#    env_parallel -S lo echo ::: fail
_EOF
  )
  ssh sh@lo "$myscript"
}

par_zsh_environment_too_big() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    . `which env_parallel.zsh`;
    bigvar="$(perl -e 'print "x"x122000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "\""x122000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar=u
    eval 'bigfunc() { a="'"$(perl -e 'print "x"x122000')"'"; };'
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "x"x123000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar="$(perl -e 'print "\""x123000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar=u
    eval 'bigfunc() { a="'"$(perl -e 'print "x"x123000')"'"; };'
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail
_EOF
  )
  ssh zsh@lo "$myscript"
}

par_ksh_environment_too_big() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    . `which env_parallel.ksh`;
    bigvar="$(perl -e 'print "x"x125000')"
    env_parallel echo ::: OK
    bigvar="$(perl -e 'print "x"x124000')"
    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "\""x124000')"
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar=u
    eval 'bigfunc() { a="'"$(perl -e 'print "\""x124000')"'"; };'
    env_parallel echo ::: OK
    env_parallel -S lo echo ::: OK

    bigvar="$(perl -e 'print "x"x126000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar="$(perl -e 'print "\""x125000')"
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail

    bigvar=u
    eval 'bigfunc() { a="'"$(perl -e 'print "\""x125000')"'"; };'
    env_parallel echo ::: fail
    env_parallel -S lo echo ::: fail
_EOF
  )
  ssh ksh@lo "$myscript"
}

par_fish_environment_too_big() {
    echo Not implemented
}

par_csh_environment_too_big() {
    echo Not implemented
}

par_tcsh_environment_too_big() {
    echo Not implemented
}

export -f $(compgen -A function | grep par_)
#compgen -A function | grep par_ | sort | parallel --delay $D -j$P --tag -k '{} 2>&1'
compgen -A function | grep par_ | sort |
    parallel --joblog /tmp/jl-`basename $0` -j200% --tag -k '{} 2>&1'
