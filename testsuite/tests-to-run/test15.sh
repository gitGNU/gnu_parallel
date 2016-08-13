#!/bin/bash

# Test xargs compatibility

#rm -f ~/.parallel/will-cite

echo '### Test -p --interactive'
cat >/tmp/parallel-script-for-expect <<_EOF
#!/bin/bash

seq 1 3 | parallel -k -p "sleep 0.1; echo opt-p"
seq 1 3 | parallel -k --interactive "sleep 0.1; echo opt--interactive"
_EOF
chmod 755 /tmp/parallel-script-for-expect

expect -b - <<_EOF
spawn /tmp/parallel-script-for-expect
expect "echo opt-p 1"
send "y\n"
expect "echo opt-p 2"
send "n\n"
expect "echo opt-p 3"
send "y\n"
expect "opt-p 1"
expect "opt-p 3"
expect "echo opt--interactive 1"
send "y\n"
expect "echo opt--interactive 2"
send "n\n"
expect "opt--interactive 1"
expect "echo opt--interactive 3"
send "y\n"
expect "opt--interactive 3"
_EOF
echo
cat <<'EOF' | parallel -vj0 -k -L1
echo '### Test killing children with --timeout and exit value (failed if timed out)'
  pstree $$ | grep sleep | grep -v anacron | grep -v screensave | wc; 
  parallel --timeout 3 'true {} ; for i in `seq 100 120`; do bash -c "(sleep $i)" & sleep $i & done; wait; echo No good' ::: 1000000000 1000000001 ; 
  echo $?; sleep 2; pstree $$ | grep sleep | grep -v anacron | grep -v screensave | wc
EOF

cd input-files/test15

echo 'xargs Expect: 3 1 2'
echo 3 | xargs -P 1 -n 1 -a files cat -
echo 'parallel Expect: 3 1 via psedotty  2'
cat >/tmp/parallel-script-for-script <<EOF
#!/bin/bash
echo 3 | parallel --tty -k -P 1 -n 1 -a files cat -
EOF
chmod 755 /tmp/parallel-script-for-script
echo via pseudotty | script -q -f -c /tmp/parallel-script-for-script /dev/null
sleep 1

echo 'xargs Expect: 1 3 2'
echo 3 | xargs -I {} -P 1 -n 1 -a files cat {} -
echo 'parallel Expect: 1 3 2 via pseudotty'
cat >/tmp/parallel-script-for-script2 <<EOF
#!/bin/bash
echo 3 | parallel --tty -k -I {} -P 1 -n 1 -a files cat {} -
EOF
chmod 755 /tmp/parallel-script-for-script2
echo via pseudotty | script -q -f -c /tmp/parallel-script-for-script2 /dev/null
sleep 1

echo '### Hans found a bug giving unitialized variable'
echo >/tmp/parallel_f1
echo >/tmp/parallel_f2'
'
echo /tmp/parallel_f1 /tmp/parallel_f2 | stdout parallel -kv --delimiter ' ' gzip
rm /tmp/parallel_f*


touch ~/.parallel/will-cite
