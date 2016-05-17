#!/bin/bash

SERVER1=parallel-server3
SERVER2=parallel-server2

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj10 -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test --return of weirdly named file'
stdout parallel --return {} -vv -S parallel\@$SERVER1 echo '>'{} ::: 'aa<${#}" b' | 
  perl -pe 's/\S*parallel-server\S*/one-server/;s:[a-z+=/\\0-9]{500,}:base64:i;'; rm 'aa<${#}" b'

echo '### Test if remote login shell is csh'
stdout parallel -k -vv -S csh@localhost 'echo $PARALLEL_PID $PARALLEL_SEQ {}| wc -w' ::: a b c | 
  perl -pe 's/\S*parallel-server\S*/one-server/;s:[a-z+=/\\0-9]{500,}:base64:i;'


EOF
