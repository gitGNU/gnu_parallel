#!/bin/bash

export SQLITE=sqlite3:///%2Frun%2Fshm%2Fparallel.db
export PG=pg://`whoami`:`whoami`@lo/`whoami`
export MYSQL=mysql://`whoami`:`whoami`@lo/`whoami`

export DEBUG=false

p_showsqlresult() {
  SERVERURL=$1
  TABLE=$2
  sql $SERVERURL "select Host,Command,V1,V2,Stdout,Stderr from $TABLE order by seq;"
}

p_wrapper() {
  INNER=$1
  SERVERURL=$2
  TABLE=TBL$RANDOM
  DBURL=$SERVERURL/$TABLE
  T1=$(tempfile)
  T2=$(tempfile)
  eval "$INNER"
  echo Exit=$?
  wait
  echo Exit=$?
  $DEBUG && sort -u $T1 $T2; 
  rm $T1 $T2
  p_showsqlresult $SERVERURL $TABLE
  $DEBUG || sql $SERVERURL "drop table $TABLE;" >/dev/null
}

p_sqlandworker() {
  (sleep 2; parallel --sqlworker $DBURL sleep .3\;echo >$T1) &
  parallel --sqlandworker $DBURL sleep .3\;echo ::: {1..5} ::: {a..e} >$T2; 
}
export -f p_sqlandworker

par_sqlandworker() {
  p_wrapper p_sqlandworker $1
}

p_sqlandworker_lo() {
  (sleep 2; parallel -S lo --sqlworker $DBURL sleep .3\;echo >$T1) &
  parallel -S lo --sqlandworker $DBURL sleep .3\;echo ::: {1..5} ::: {a..e} >$T2; 
}

par_sqlandworker_lo() {
  p_wrapper p_sqlandworker_lo $1
}

p_sqlandworker_results() {
  (sleep 2; parallel --results /tmp/out--sql --sqlworker $DBURL sleep .3\;echo >$T1) &
  parallel --results /tmp/out--sql --sqlandworker $DBURL sleep .3\;echo ::: {1..5} ::: {a..e} >$T2; 
}

par_sqlandworker_results() {
  p_wrapper p_sqlandworker_results $1
}

p_sqlandworker_linebuffer() {
  (sleep 2; parallel --linebuffer --sqlworker $DBURL sleep .3\;echo >$T1) &
  parallel --linebuffer --sqlandworker $DBURL sleep .3\;echo ::: {1..5} ::: {a..e} >$T2; 
}

par_sqlandworker_linebuffer() {
  p_wrapper p_sqlandworker_linebuffer $1
}

p_sqlandworker_unbuffer() {
  (sleep 2; parallel -u --sqlworker $DBURL sleep .3\;echo >$T1) &
  parallel -u --sqlandworker $DBURL sleep .3\;echo ::: {1..5} ::: {a..e} >$T2; 
}

par_sqlandworker_unbuffer() {
  p_wrapper p_sqlandworker_unbuffer $1
}

export -f $(compgen -A function | egrep 'p_|par_')
# Tested that -j0 in parallel is fastest (up to 15 jobs)
compgen -A function | grep par_ | sort |
  stdout parallel -vj0 -k --tag --joblog /tmp/jl-`basename $0` :::: - ::: \$MYSQL \$PG \$SQLITE
