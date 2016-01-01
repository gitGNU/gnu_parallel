#!/bin/bash

export SQLITE=sqlite3:///%2Frun%2Fshm%2Fparallel.db
export SQLITETBL=$SQLITE/parsql
export PG=pg://tange:tange@lo/tange
export PGTBL=$PG/parsql
export MYSQL=mysql://tange:tange@lo/tange
export MYSQLTBL=$MYSQL/parsql
export PGTBL2=${PGTBL}2
export PGTBL3=${PGTBL}3
export PGTBL4=${PGTBL}4
export PGTBL5=${PGTBL}5
export T1=$(tempfile)
export T2=$(tempfile)
export T3=$(tempfile)
export T4=$(tempfile)
export T5=$(tempfile)
export T6=$(tempfile)
export T7=$(tempfile)
export T8=$(tempfile)
export T9=$(tempfile)
export T10=$(tempfile)
export T11=$(tempfile)
export T12=$(tempfile)
export T13=$(tempfile)
export T14=$(tempfile)

#sql mysql://tange:tange@lo/ 'create database tange;'; 
cat <<'EOF' | sed -e 's/;$/; /;' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1 | perl -pe 's/\s*\d+\.?\d+\s*/999/g;s/999e+999.\s+.\s+/999e+999|999/g;'
echo '### --sqlandworker mysql'
  (sleep 2; parallel --sqlworker $MYSQLTBL sleep .3\;echo >$T1) &
  parallel --sqlandworker $MYSQLTBL sleep .3\;echo ::: {1..5} ::: {a..e} >$T2; 
  true sort -u $T1 $T2; 
  sql $MYSQL 'select * from parsql order by seq;'

echo '### --sqlandworker postgresql'
  (sleep 2; parallel --sqlworker $PGTBL sleep .3\;echo >$T3) &
  parallel --sqlandworker $PGTBL sleep .3\;echo ::: {1..5} ::: {a..e} >$T4; 
  true sort -u $T3 $T4; 
  sql $PG 'select * from parsql order by seq;'

echo '### --sqlandworker sqlite'
  (sleep 2; parallel --sqlworker $SQLITETBL sleep .3\;echo >$T5) &
  parallel --sqlandworker $SQLITETBL sleep .3\;echo ::: {1..5} ::: {a..e} >$T6; 
  true sort -u $T5 $T6; 
  sql $SQLITE 'select * from parsql order by seq;'

echo '### --sqlandworker postgresql -S lo'
  (sleep 2; parallel -S lo --sqlworker $PGTBL2 sleep .3\;echo >$T7) &
  parallel -S lo --sqlandworker $PGTBL2 sleep .3\;echo ::: {1..5} ::: {a..e} >$T8; 
  true sort -u $T7 $T8; 
  sql $PG 'select * from parsql2 order by seq;'

echo '### --sqlandworker postgresql --results'
  mkdir -p /tmp/out--sql
  (sleep 2; parallel --results /tmp/out--sql --sqlworker $PGTBL3 sleep .3\;echo >$T9) &
  parallel --results /tmp/out--sql --sqlandworker $PGTBL3 sleep .3\;echo ::: {1..5} ::: {a..e} >$T10; 
  true sort -u $T9 $T10; 
  sql $PG 'select * from parsql3 order by seq;'

echo '### --sqlandworker postgresql --linebuffer'
  (sleep 2; parallel --linebuffer --sqlworker $PGTBL4 sleep .3\;echo >$T11) &
  parallel --linebuffer --sqlandworker $PGTBL4 sleep .3\;echo ::: {1..5} ::: {a..e} >$T12; 
  true sort -u $T11 $T12; 
  sql $PG 'select * from parsql4 order by seq;'

echo '### --sqlandworker postgresql -u'
  (sleep 2; parallel -u --sqlworker $PGTBL5 sleep .3\;echo >$T13) &
  parallel -u --sqlandworker $PGTBL5 sleep .3\;echo ::: {1..5} ::: {a..e} >$T14; 
  true sort -u $T13 $T14; 
  sql $PG 'select * from parsql5 order by seq;'

EOF

eval rm '$T'{1..14}