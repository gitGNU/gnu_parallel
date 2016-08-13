#!/bin/bash


par_basic_shebang_wrap() {
    echo "### Test basic --shebang-wrap"
    cat <<EOF > /tmp/basic--shebang-wrap
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/perl

print "Shebang from perl with args @ARGV\n";
EOF

    chmod 755 /tmp/basic--shebang-wrap
    /tmp/basic--shebang-wrap arg1 arg2
    echo "### Test basic --shebang-wrap Same as"
    parallel -k /usr/bin/perl /tmp/basic--shebang-wrap ::: arg1 arg2
    echo "### Test basic --shebang-wrap stdin"
    (echo arg1; echo arg2) | /tmp/basic--shebang-wrap
    echo "### Test basic --shebang-wrap Same as"
    (echo arg1; echo arg2) | parallel -k /usr/bin/perl /tmp/basic--shebang-wrap
    rm /tmp/basic--shebang-wrap
}

par_shebang_with_parser_options() {
    seq 1 2 >/tmp/in12
    seq 4 5 >/tmp/in45
    
    echo "### Test --shebang-wrap with parser options"
    cat <<EOF > /tmp/with-parser--shebang-wrap
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/perl -p

print "Shebang from perl with args @ARGV\n";
EOF

    chmod 755 /tmp/with-parser--shebang-wrap
    /tmp/with-parser--shebang-wrap /tmp/in12 /tmp/in45
    echo "### Test --shebang-wrap with parser options Same as"
    parallel -k /usr/bin/perl -p /tmp/with-parser--shebang-wrap ::: /tmp/in12 /tmp/in45
    echo "### Test --shebang-wrap with parser options stdin"
    (echo /tmp/in12; echo /tmp/in45) | /tmp/with-parser--shebang-wrap
    echo "### Test --shebang-wrap with parser options Same as"
    (echo /tmp/in12; echo /tmp/in45) | parallel -k /usr/bin/perl /tmp/with-parser--shebang-wrap
    rm /tmp/with-parser--shebang-wrap


    echo "### Test --shebang-wrap --pipe with parser options"
    cat <<EOF > /tmp/pipe--shebang-wrap
#!/usr/local/bin/parallel --shebang-wrap -k --pipe /usr/bin/perl -p

print "Shebang from perl with args @ARGV\n";
EOF

    chmod 755 /tmp/pipe--shebang-wrap
    echo "### Test --shebang-wrap --pipe with parser options stdin"
    cat /tmp/in12 /tmp/in45 | /tmp/pipe--shebang-wrap
    echo "### Test --shebang-wrap --pipe with parser options Same as"
    cat /tmp/in12 /tmp/in45 | parallel -k --pipe /usr/bin/perl\ -p /tmp/pipe--shebang-wrap
    rm /tmp/pipe--shebang-wrap
    
    rm /tmp/in12
    rm /tmp/in45
}

par_shebang_wrap_perl() {
    F=/tmp/shebang_wrap_perl
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/perl

print "Arguments @ARGV\n";
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_python() {
    F=/tmp/shebang_wrap_python
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/python

import sys
print 'Arguments', str(sys.argv)
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_bash() {
    F=/tmp/shebang_wrap_bash
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /bin/bash

echo Arguments "$@"
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_sh() {
    F=/tmp/shebang_wrap_sh
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /bin/sh

echo Arguments "$@"
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_ksh() {
    F=/tmp/shebang_wrap_ksh
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/ksh

echo Arguments "$@"
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_zsh() {
    F=/tmp/shebang_wrap_zsh
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/zsh

echo Arguments "$@"
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_csh() {
    F=/tmp/shebang_wrap_csh
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /bin/csh

echo Arguments "$argv"
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_tcl() {
    F=/tmp/shebang_wrap_tcl
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/tclsh

puts "Arguments $argv"
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_R() {
    F=/tmp/shebang_wrap_R
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/Rscript --vanilla --slave

args <- commandArgs(trailingOnly = TRUE)
print(paste("Arguments ",args))
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_gnuplot() {
    F=/tmp/shebang_wrap_gnuplot
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k ARG={} /usr/bin/gnuplot

print "Arguments ", system('echo $ARG')
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_ruby() {
    F=/tmp/shebang_wrap_ruby
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/ruby
  
print "Arguments "
puts ARGV
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_octave() {
    F=/tmp/shebang_wrap_octave
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/octave

printf ("Arguments");
arg_list = argv ();
for i = 1:nargin
  printf (" %s", arg_list{i});
endfor
printf ("\n");
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_clisp() {
    F=/tmp/shebang_wrap_clisp
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/clisp
  
(format t "~&~S~&" 'Arguments)
(format t "~&~S~&" *args*)
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_php() {
    F=/tmp/shebang_wrap_php
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/php
<?php
echo "Arguments";
foreach(array_slice($argv,1) as $v)
{
  echo " $v";
}
echo "\n";
?>
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_nodejs() {
    F=/tmp/shebang_wrap_nodejs
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/node

var myArgs = process.argv.slice(2);
console.log('Arguments ', myArgs);
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_lua() {
    F=/tmp/shebang_wrap_lua
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/lua

io.write "Arguments"
for a = 1, #arg do
  io.write(" ")
  io.write(arg[a])
end
print("")
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

par_shebang_wrap_csharp() {
    F=/tmp/shebang_wrap_csharp
    cat <<'EOF' > $F
#!/usr/local/bin/parallel --shebang-wrap -k ARGV={} /usr/bin/csharp

var argv = Environment.GetEnvironmentVariable("ARGV");
print("Arguments "+argv);
EOF
    chmod 755 $F
    $F arg1 arg2 arg3
    rm $F
}

export -f $(compgen -A function | grep par_)
# Tested with -j1..8
# -j6 was fastest
#compgen -A function | grep par_ | sort | parallel -j$P --tag -k '{} 2>&1'
compgen -A function | grep par_ | sort | parallel -j6 --tag -k '{} 2>&1'
