#!/bin/bash

# Simple jobs that never fails
# Each should be taking 10-30s and be possible to run in parallel
# I.e.: No race conditions, no logins
par_pipepart_spawn() {
    echo '### bug #46214: Using --pipepart doesnt spawn multiple jobs in version 20150922'
    seq 1000000 > /tmp/num1000000;
    stdout parallel --pipepart --progress -a /tmp/num1000000 --block 10k -j0 true |
    grep 1:local | perl -pe 's/\d\d\d/999/g'
}

par_testhalt() {
    testhalt() {
	echo '### testhalt --halt '$1;
	(yes 0 | head -n 10; seq 10) | stdout parallel -kj4 --halt $1 'sleep {= $_=$_*0.3+1 =}; exit {}'; echo $?;
	(seq 10; yes 0 | head -n 10) | stdout parallel -kj4 --halt $1 'sleep {= $_=$_*0.3+1 =}; exit {}'; echo $?;
    };
    export -f testhalt;

    stdout parallel -kj0 testhalt {1},{2}={3} \
	::: now soon ::: fail success ::: 0 1 2 30% 70% |
    # Remove lines that only show up now and then
    perl -ne '/Starting no more jobs./ or print'
}

par_halt_on_error() {
    mytest() {
	HALT=$1
	BOOL1=$2
	BOOL2=$3
	(echo "sleep 1;$BOOL1";
	    echo "sleep 2;$BOOL2";
	    echo "sleep 3;$BOOL1") |
	parallel -j10 --halt-on-error $HALT
	echo $?
	(echo "sleep 1;$BOOL1";
	    echo "sleep 2;$BOOL2";
	    echo "sleep 3;$BOOL1";
	    echo "sleep 4;non_exist";
	) |
	parallel -j10 --halt-on-error $HALT
	echo $?
    }
    export -f mytest
    parallel -j0 -k --tag mytest ::: -2 -1 0 1 2 ::: true false ::: true false
}

par_print_before_halt_on_error() {
    echo '### What is printed before the jobs are killed'
    mytest() {
	HALT=$1
	(echo 0;
	    echo 3;
	    seq 0 7;
	    echo 0;
	    echo 8) |
	parallel --tag -j10 -kq --halt $HALT perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; '$HALT' > 0 ? exit shift : exit not shift;';
	echo exit code $?
    }
    export -f mytest
    parallel -j0 -k --tag mytest ::: -2 -1 0 1 2
}

par_first_print_halt_on_error_1() {
    echo '### Test first dying print --halt-on-error 1';
    (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt 1 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit shift';
    echo exit code $?
}

par_first_print_halt_on_error_2() {
    echo '### Test last dying print --halt-on-error 2';
    (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt 2 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit shift';
    echo exit code $?
}

par_first_print_halt_on_error_minus_1() {
    echo '### Test last dying print --halt-on-error -1';
    (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt -1 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit not shift';
    echo exit code $?
}

par_first_print_halt_on_error_minus_2() {
    echo '### Test last dying print --halt-on-error -2';
    (echo 0; echo 3; seq 0 7;echo 0; echo 8) | parallel -j10 -kq --halt -2 perl -e 'sleep $ARGV[0];print STDERR @ARGV,"\n"; exit not shift';
    echo exit code $?
}

par_k_linebuffer() {
    echo '### bug #47750: -k --line-buffer should give current job up to now'

    parallel --line-buffer --tag -k 'seq {} | pv -qL 10' ::: {10..20}
    parallel --line-buffer -k 'echo stdout top;sleep 1;echo stderr in the middle >&2; sleep 1;echo stdout' ::: end 2>&1
}

par_memleak() {
    echo "### Test memory consumption stays (almost) the same for 30 and 300 jobs"
    echo "should give 1 == true"

    mem30=$( stdout time -f %M parallel -j2 true :::: <(perl -e '$a="x"x60000;for(1..30){print $a,"\n"}') );
    mem300=$( stdout time -f %M parallel -j2 true :::: <(perl -e '$a="x"x60000;for(1..300){print $a,"\n"}') );
    echo "Memory use should not depend very much on the total number of jobs run\n";
    echo "Test if memory consumption(300 jobs) < memory consumption(30 jobs) * 110% ";
    echo $(($mem300*100 < $mem30 * 110))
}

par_maxlinelen_m_I() {
    echo "### Test max line length -m -I"

    seq 1 60000 | parallel -I :: -km -j1 echo a::b::c | sort >/tmp/114-a$$;
    md5sum </tmp/114-a$$;
    export CHAR=$(cat /tmp/114-a$$ | wc -c);
    export LINES=$(cat /tmp/114-a$$ | wc -l);
    echo "Chars per line ($CHAR/$LINES): "$(echo "$CHAR/$LINES" | bc);
    rm /tmp/114-a$$
}

par_maxlinelen_X_I() {
    echo "### Test max line length -X -I"

    seq 1 60000 | parallel -I :: -kX -j1 echo a::b::c | sort >/tmp/114-b$$;
    md5sum </tmp/114-b$$;
    export CHAR=$(cat /tmp/114-b$$ | wc -c);
    export LINES=$(cat /tmp/114-b$$ | wc -l);
    echo "Chars per line ($CHAR/$LINES): "$(echo "$CHAR/$LINES" | bc);
    rm /tmp/114-b$$
}

par_compress_fail() {
    echo "### bug #41609: --compress fails"
    seq 12 | parallel --compress --compress-program bzip2 -k seq {} 1000000 | md5sum
    seq 12 | parallel --compress -k seq {} 1000000 | md5sum
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort | parallel -j6 --tag -k '{} 2>&1'
