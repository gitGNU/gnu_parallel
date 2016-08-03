#!/bin/bash

# Simple jobs that never fails
# Each should be taking >100s and be possible to run in parallel
# I.e.: No race conditions, no logins

# tmpdir with > 5 GB available
TMP5G=${TMP5G:-/dev/shm}
export TMP5G

rm -f /tmp/*.{tmx,pac,arg,all,log,swp,loa,ssh,df,pip,tmb,chr,tms,par}

par_retries_unreachable() {
  echo '### Test of --retries on unreachable host'
  seq 2 | stdout parallel -k --retries 2 -v -S 4.3.2.1,: echo
}

par_outside_file_handle_limit() {
  echo "### Test Force outside the file handle limit, 2009-02-17 Gave fork error"
  (echo echo Start; seq 1 20000 | perl -pe 's/^/true /'; echo echo end) |
    stdout parallel -uj 0 | egrep -v 'processes took|adjusting'
}

par_over_4GB() {
  echo '### Test if we can deal with output > 4 GB'
  echo | 
    nice parallel --tmpdir $TMP5G -q perl -e '$a="x"x1000000;for(0..4300){print $a}' |
    nice md5sum
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort | parallel -vj0 -k --tag --joblog /tmp/jl-`basename $0` '{} 2>&1'
