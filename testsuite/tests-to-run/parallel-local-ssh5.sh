#!/bin/bash

# SSH only allowed to localhost/lo
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj3 --delay 0.1 --retries 3 -k --joblog /tmp/jl-`basename $0` -L1
echo '### --ssh autossh - add commands that fail here'
  export PARALLEL_SSH=autossh; export AUTOSSH_PORT=0; 
  parallel -S lo echo ::: OK; 
  echo OK | parallel --pipe -S lo cat; 
  parallel -S lo false ::: a || echo OK should fail; 
  touch foo_autossh; stdout parallel -S csh@lo --trc {}.out touch {}.out ::: foo_autossh; rm foo_autossh*;

echo '### bug #46520: --basefile cleans up without --cleanup'
  touch bug_46520; 
  parallel -S parallel@lo --bf bug_46520 ls ::: bug_46520; 
  ssh parallel@lo ls bug_46520; 
  parallel -S parallel@lo --cleanup --bf bug_46520 ls ::: bug_46520; 
  stdout ssh parallel@lo ls bug_46520 # should not exist

echo '### bug #36595: silent loss of input with --pipe and --sshlogin'
  seq 10000 | xargs | parallel --pipe -S 8/localhost cat 2>/dev/null | wc

echo 'bug #36707: --controlmaster eats jobs'
  seq 2 | parallel -k --controlmaster --sshlogin localhost echo OK{}

echo '### --ssh lsh'
  parallel --ssh lsh -S lo echo ::: OK
  echo OK | parallel --ssh lsh --pipe -S csh@lo cat
  # Todo rsync/trc csh@lo
  # Test gl. parallel med --ssh lsh: Hvilke fejler? brug dem. Også hvis de fejler

echo '### bug #45025: --pipe --retries does not reschedule on other host'
  seq 1 300030| stdout parallel -k --retries 2 -S a.a,: --pipe 'wc;hostname' | perl -pe 's/'`hostname`'/localhost-:/'
  stdout parallel --retries 2 --roundrobin echo ::: should fail

EOF
