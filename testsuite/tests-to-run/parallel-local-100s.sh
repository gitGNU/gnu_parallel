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


measure() {
    # Input:
    #   $1 = iterations
    #   $2 = sleep 1 sec for every $2
    seq $1 | ramusage parallel -u sleep '{= $_=$_%'$2'?0:1 =}'
}
export -f measure

no_mem_leak() {
    # Return false if leaking
    max1000=$(parallel measure {} 100000 ::: 1000 1000 1000 1000 1000 1000 1000 1000 |
    		       sort -n | tail -n 1)
    min30000=$(parallel measure {} 100000 ::: 30000 30000 30000 |
    			sort -n | head -n 1)
    if [ $max1000 -gt $min30000 ] ; then
	# Make sure there are a few sleeps
	max1000=$(parallel measure {} 100 ::: 1000 1000 1000 1000 1000 1000 1000 1000 |
			   sort -n | tail -n 1)
	min30000=$(parallel measure {} 100 ::: 30000 30000 30000 |
			    sort -n | head -n 1)
	if [ $max1000 -gt $min30000 ] ; then
	    echo $max1000 -gt $min30000 = no leak
	    return 0
	else
	    echo not $max1000 -gt $min30000 = possible leak
	    return 1
	fi
    else
	echo not $max1000 -gt $min30000 = possible leak
	return 1
    fi
}
export -f no_mem_leak

par_mem_leak() {
    echo "### test for mem leak"
    if no_mem_leak >/dev/null ; then
	echo no mem leak detected
    else
	echo possible mem leak;
    fi
}


export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort | parallel -vj0 -k --tag --joblog /tmp/jl-`basename $0` '{} 2>&1'
