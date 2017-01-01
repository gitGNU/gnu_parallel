#!/bin/bash

# Test xargs compatibility

#rm -f ~/.parallel/will-cite

cd input-files/test15 || cd ../input-files/test15

echo 'xargs Expect: 3 1'
echo 3 | xargs -P 1 -n 1 -a files cat -
echo 'parallel Expect: 3 1 via psedotty  2'
cat >/tmp/parallel-script-for-script <<EOF
#!/bin/bash
echo 3 | parallel --tty -k -P 1 -n 1 -a files cat -
EOF
chmod 755 /tmp/parallel-script-for-script
echo via pseudotty | script -q -f -c /tmp/parallel-script-for-script /dev/null
sleep 1

echo 'xargs Expect: 1 3'
echo 3 | xargs -I {} -P 1 -n 1 -a files cat {} -
echo 'parallel Expect: 1 3 2 via pseudotty'
cat >/tmp/parallel-script-for-script2 <<EOF
#!/bin/bash
echo 3 | parallel --tty -k -I {} -P 1 -n 1 -a files cat {} -
EOF
chmod 755 /tmp/parallel-script-for-script2
echo via pseudotty | script -q -f -c /tmp/parallel-script-for-script2 /dev/null
sleep 1

touch ~/.parallel/will-cite
