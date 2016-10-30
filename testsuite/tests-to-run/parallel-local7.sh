#!/bin/bash

par_tmux_filter() {
    # /tmp/parallel-local7/tmsOU2Ig
    perl -pe 's:(/tmp\S+/tms).....:$1XXXXX:;s/ p\d+/pID/;'
}
export -f par_tmux_filter

par_tmux() {
    (stdout parallel --timeout 3 --tmux --delay 0.03 echo '{}{=$_="\\"x$_=}'; echo $?) | par_tmux_filter
}
export -f par_tmux
cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj3 --timeout 60 --retries 2 -k --joblog /tmp/jl-`basename $0` -L1
echo '### tmux1.9'
  seq 000   100 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 100   200 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 200   300 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 300   400 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 400   500 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 500   600 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 600   700 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 700   800 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 800   900 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 900  1000 | PARALLEL_TMUX=tmux1.9 par_tmux
  seq 1000 1006 | PARALLEL_TMUX=tmux1.9 par_tmux
echo '### tmux1.9 fails'
  echo 1007 | PARALLEL_TMUX=tmux1.9 par_tmux
  echo 1008 | PARALLEL_TMUX=tmux1.9 par_tmux
  echo 1009 | PARALLEL_TMUX=tmux1.9 par_tmux

echo '### tmux1.8'
  seq   1  50 | PARALLEL_TMUX=tmux1.8 par_tmux
  seq  51 100 | PARALLEL_TMUX=tmux1.8 par_tmux
  seq 101 113 | PARALLEL_TMUX=tmux1.8 par_tmux
echo '### tmux1.8 fails'
  echo 114 | PARALLEL_TMUX=tmux1.8 par_tmux
  echo 115 | PARALLEL_TMUX=tmux1.8 par_tmux
  echo 116 | PARALLEL_TMUX=tmux1.8 par_tmux

echo '### tmux1.8 0..255 ascii'
perl -e 'print map { ($_, map { pack("c*",$_) } grep { $_>=1 && $_!=10 } $_-110..$_),"\n" } 0..255' | 
   PARALLEL_TMUX=tmux1.8 stdout parallel --tmux --timeout 3 echo | par_tmux_filter; echo $?

echo '### tmux1.9 0..255 ascii'
perl -e 'print map { ($_, map { pack("c*",$_) } grep { $_>=1 && $_!=10 } 0..$_),"\n" } 0..255' | 
   PARALLEL_TMUX=tmux1.9 stdout parallel --tmux --timeout 3 echo | par_tmux_filter; echo $?

echo '### Test output ascii'
  rm -f /tmp/paralocal7-ascii*; 
  perl -e 'print map { ($_, map { pack("c*",$_) } grep { $_>=1 && $_!=10 } $_-10..$_),"\n" } 1..255' | stdout parallel --tmux echo {}'>>/tmp/paralocal7-ascii{%}' | par_tmux_filter; 
  sort /tmp/paralocal7-ascii* | md5sum

echo '### Test critical lengths. Must not block'
  seq 70 130  | PARALLEL_TMUX=tmux1.8 stdout parallel --tmux echo '{}{=$_="&"x$_=}' | par_tmux_filter
  seq 70 130  | PARALLEL_TMUX=tmux1.9 stdout parallel --tmux echo '{}{=$_="&"x$_=}' | par_tmux_filter
  seq 280 425 | PARALLEL_TMUX=tmux1.8 stdout parallel --tmux echo '{}{=$_="a"x$_=}' | par_tmux_filter
  seq 280 425 | PARALLEL_TMUX=tmux1.9 stdout parallel --tmux echo '{}{=$_="a"x$_=}' | par_tmux_filter

EOF

rm -f /tmp/paralocal7*
