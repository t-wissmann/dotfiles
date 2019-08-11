#!/usr/bin/env bash

# show the size of an mpd collection by year
mpc listall -f '%date% %time%' \
    |sed 's,-[^ ]*,,' \
    |grep -v '^ ' \
    |sed 's,:, ,' \
    |awk '

    BEGIN {
        minyear = 3000
        maxyear = 0
        for (i = 0; i <= 3000; i++) {
            l[i] = 0;
        }
    }

    {
        if ($1 > 0) {
            minyear = (($1 < minyear) ? $1 : minyear);
        }
        maxyear = (($1 > maxyear) ? $1 : maxyear);
        # accumulate seconds
        l[$1] = l[$1] + $2 * 60 + $3
    }

    END {
        for (i = minyear; i <= maxyear; i++) {
            print i " " (l[i] / 60 / 60) 
        }
    }

' \
    | gnuplot -p -e "
    set xlabel 'Jahr' ;
    set ylabel 'Spielzeit in Stunden' ;
    set xtics out rotate by -45 ;
    set xtics 0,2 scale 0,2 ;
    set mxtics 2 ;
    set boxwidth 0.8 ;
    plot '-' using 1:2 with boxes"
