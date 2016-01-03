#!/bin/bash

SSHLOGIN1=parallel@lo
SSHLOGIN2=csh@lo
mkdir -p tmp

# -L1 will join lines ending in ' '
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/\;s/\$SSHLOGIN1/$SSHLOGIN1/\;s/\$SSHLOGIN2/$SSHLOGIN2/ | parallel -vj5 -k --joblog /tmp/jl-`basename $0` -L1
echo '### Test --onall'; 
  parallel --onall --tag -k -S $SSHLOGIN1,$SSHLOGIN2 '(echo {1} {2}) | awk \{print\ \$2}' ::: a b c ::: 1 2

echo '### Test | --onall'; 
  seq 3 | parallel --onall --tag -k -S $SSHLOGIN1,$SSHLOGIN2 '(echo {1} {2}) | awk \{print\ \$2}' ::: a b c :::: -

echo '### Test --onall -u'; 
  parallel --onall -S $SSHLOGIN1,$SSHLOGIN2 -u '(echo {1} {2}) | awk \{print\ \$2}' ::: a b c ::: 1 2 3 | sort

echo '### Test --nonall'; 
  parallel --nonall -k -S $SSHLOGIN1,$SSHLOGIN2 pwd | sort

echo '### Test --nonall -u - should be interleaved x y x y'; 
  parallel --nonall -S $SSHLOGIN1,$SSHLOGIN2 -u 'pwd|grep -q csh && sleep 3; pwd;sleep 12;pwd;'

echo '### Test read sshloginfile from STDIN'; 
  echo $SSHLOGIN1,$SSHLOGIN2 | parallel -S - -k --nonall pwd; 
  echo $SSHLOGIN1,$SSHLOGIN2 | parallel --sshloginfile - -k --onall pwd\; echo ::: foo

echo '**'

echo '### Test --nonall --basefile'; 
  touch tmp/nonall--basefile; 
  stdout parallel --nonall --basefile tmp/nonall--basefile -S $SSHLOGIN1,$SSHLOGIN2 ls tmp/nonall--basefile; 
  stdout parallel --nonall -S $SSHLOGIN1,$SSHLOGIN2 rm tmp/nonall--basefile; 
  stdout rm tmp/nonall--basefile

echo '**'

echo '### Test --onall --basefile'; 
  touch tmp/onall--basefile; 
  stdout parallel --onall --basefile tmp/onall--basefile -S $SSHLOGIN1,$SSHLOGIN2 ls {} ::: tmp/onall--basefile; 
  stdout parallel --onall -S $SSHLOGIN1,$SSHLOGIN2 rm {} ::: tmp/onall--basefile; 
  stdout rm tmp/onall--basefile

echo '**'

echo '### Test --nonall --basefile --cleanup (rm should fail)'; 
  touch tmp/nonall--basefile--clean; 
  stdout parallel --nonall --basefile tmp/nonall--basefile--clean --cleanup -S $SSHLOGIN1,$SSHLOGIN2 ls tmp/nonall--basefile--clean; 
  stdout parallel --nonall -S $SSHLOGIN1,$SSHLOGIN2 rm tmp/nonall--basefile--clean; 
  stdout rm tmp/nonall--basefile--clean

echo '**'

echo '### Test --onall --basefile --cleanup (rm should fail)'; 
  touch tmp/onall--basefile--clean; 
  stdout parallel --onall --basefile tmp/onall--basefile--clean --cleanup -S $SSHLOGIN1,$SSHLOGIN2 ls {} ::: tmp/onall--basefile--clean; 
  stdout parallel --onall -S $SSHLOGIN1,$SSHLOGIN2 rm {} ::: tmp/onall--basefile--clean; 
  stdout rm tmp/onall--basefile--clean

echo '**'

echo '### Test --workdir .'; 
  ssh $SSHLOGIN1 mkdir -p mydir; 
  mkdir -p $HOME/mydir; cd $HOME/mydir; 
  parallel --workdir . -S $SSHLOGIN1 ::: pwd

echo '### Test --wd .'; 
  ssh $SSHLOGIN2 mkdir -p mydir; 
  mkdir -p $HOME/mydir; cd $HOME/mydir; 
  parallel --workdir . -S $SSHLOGIN2 ::: pwd

echo '### Test --wd {}'; 
  ssh $SSHLOGIN2 rm -rf wd1 wd2; 
  mkdir -p $HOME/mydir; cd $HOME/mydir; 
  parallel --workdir {} -S $SSHLOGIN2 touch ::: wd1 wd2; 
  ssh $SSHLOGIN2 ls -d wd1 wd2

echo '### Test --wd {= =}'; 
  ssh $SSHLOGIN2 rm -rf WD1 WD2; 
  mkdir -p $HOME/mydir; cd $HOME/mydir; 
  parallel --workdir '{= $_=uc($_) =}' -S $SSHLOGIN2 touch ::: wd1 wd2; 
  ssh $SSHLOGIN2 ls -d WD1 WD2

EOF
