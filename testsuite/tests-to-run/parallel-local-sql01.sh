#!/bin/bash

# GNU SQL tests
# The tests must be able to run in parallel

export SQLITE=sqlite3:///%2Frun%2Fshm%2Fparallel.db
export PG=pg://`whoami`:`whoami`@lo/`whoami`
export MYSQL=mysql://`whoami`:`whoami`@lo/`whoami`

export DEBUG=false

#p_showsqlresult() {
#  SERVERURL=$1
#  TABLE=$2
#  sql $SERVERURL "select Host,Command,V1,V2,Stdout,Stderr from $TABLE order by seq;"
#}
#
#p_wrapper() {
#  INNER=$1
#  SERVERURL=$(eval echo $2)
#  TABLE=TBL$RANDOM
#  DBURL=$SERVERURL/$TABLE
#  T1=$(tempfile)
#  T2=$(tempfile)
#  eval "$INNER"
#  echo Exit=$?
#  wait
#  echo Exit=$?
#  $DEBUG && sort -u $T1 $T2;
#  rm $T1 $T2
#  p_showsqlresult $SERVERURL $TABLE
#  $DEBUG || sql $SERVERURL "drop table $TABLE;" >/dev/null 2>/dev/null
#}
#
#p_template() {
#  (sleep 2;
#   parallel --sqlworker $DBURL    "$@" sleep .3\;echo >$T1) &
#  parallel  --sqlandworker $DBURL "$@" sleep .3\;echo ::: {1..5} ::: {a..e} >$T2;
#}
#
#par_sqlandworker() {
#  p_template
#}
#
#par_sqlandworker_lo() {
#  p_template -S lo
#}
#
#par_sqlandworker_results() {
#  p_template --results /tmp/out--sql
#}
#
#par_sqlandworker_linebuffer() {
#  p_template --linebuffer
#}
#
#par_sqlandworker_tag() {
#  p_template --tag
#}
#
#par_sqlandworker_linebuffer_tag() {
#  p_template --linebuffer --tag
#}
#
#par_sqlandworker_compress_linebuffer_tag() {
#  p_template --compress --linebuffer --tag
#}
#
#par_sqlandworker_unbuffer() {
#  p_template -u
#}
#
#par_sqlandworker_total_jobs() {
#  p_template echo {#} of '{=1 $_=total_jobs(); =};'
#}
#
#par_append() {
#  parallel --sqlmaster  $DBURL sleep .3\;echo ::: {1..5} ::: {a..e} >$T2;
#  parallel --sqlmaster +$DBURL sleep .3\;echo ::: {11..15} ::: {A..E} >>$T2;
#  parallel --sqlworker  $DBURL sleep .3\;echo >$T1
#}
#
#par_shuf() {
#  MD5=$(echo $SERVERURL | md5sum | perl -pe 's/(...).*/$1/')
#  T=/tmp/parallel-bug49791-$MD5
#  [ -e $T ] && rm -rf $T
#  export PARALLEL="--shuf --result $T"
#  parallel --sqlandworker $DBURL sleep .3\;echo \
#    ::: {1..5} ::: {a..e} >$T2;
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  unset PARALLEL
#  wait;
#  # Did it compute correctly?
#  cat $T/1/*/*/*/stdout
#  # Did it shuffle
#  SHUF=$(sql $SERVERURL "select Host,Command,V1,V2,Stdout,Stderr from $TABLE order by seq;")
#  export PARALLEL="--result $T"
#  parallel --sqlandworker $DBURL sleep .3\;echo \
#    ::: {1..5} ::: {a..e} >$T2;
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  parallel --sqlworker    $DBURL sleep .3\;echo >$T2 &
#  unset PARALLEL
#  wait;
#  NOSHUF=$(sql $SERVERURL "select Host,Command,V1,V2,Stdout,Stderr from $TABLE order by seq;")
#  DIFFSIZE=$(diff <(echo "$SHUF") <(echo "$NOSHUF") | wc -c)
#  if [ $DIFFSIZE -gt 2500 ]; then
#    echo OK: Diff bigger than 2500 char
#  fi
#  [ -e $T ] && rm -rf $T
#  touch $T1
#}
#
par_empty() {
    true;
}

export -f $(compgen -A function | egrep 'p_|par_')
# Tested that -j0 in parallel is fastest (up to 15 jobs)
compgen -A function | grep par_ | sort |
  stdout parallel -vj5 -k --tag --joblog /tmp/jl-`basename $0` p_wrapper \
    :::: - ::: \$MYSQL \$PG \$SQLITE
