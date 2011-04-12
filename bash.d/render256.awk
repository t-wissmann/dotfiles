#!/bin/awk -f

# Setup
BEGIN {
	#chunksize=int(1000/(2*barlength)+0.5);
	n=0;
    linenr=0
	rmax=1; gmax=1; bmax=1;
	rmaxsize=1; gmaxsize=1; bmaxsize=1;
}

# Sum the samples in each chunk and find the max value for each color
{
    n=int((linenr/1000)*2*barlength)
    chsize[n]++;
	r[n]+=$1;
    g[n]+=$2;
    b[n]+=$3;
	if (r[n] > rmax) { rmax = r[n];  }
    if (g[n] > gmax) { gmax = g[n];  }
    if (b[n] > bmax) { bmax = b[n];  }
	linenr++;
}

# Draw the moodbar
END {
	ORS="";
    #print "linenr=" linenr " \n"
    #print "chsize=" chunksize " \n"
    #print "barlength=" barlength " \n"
    #print "*=" (2*chunksize*barlength) " \n"
    #s=0
    #for (i=1;i<=n;i++) {
    #    print "chsize[" i "]=" chsize[i] "\n";
    #    s+=chsize[n];
    #}
    #print "sum is " s "\n";
	for (i=1;i<=barlength*2-1;i+=2) {
		r[i]/=rmax; g[i]/=gmax; b[i]/=bmax;
        # convert rgb in range from 0 to 1 to 256color
        r[i] = int(r[i] * 6);
        g[i] = int(g[i] * 6);
        b[i] = int(b[i] * 6);
        rgbcolor = r[i]*36 + g[i]*6+b[i]+16;
		r[i+1]/=rmax; g[i+1]/=gmax; b[i+1]/=bmax;
        # convert rgb i+1n range from 0 to 1 to 256color
        r[i+1] = int(r[i+1] * 6);
        g[i+1] = int(g[i+1] * 6);
        b[i+1] = int(b[i+1] * 6);
        rgbcolor1 = r[i+1]*36 + g[i+1]*6+b[i+1]+16;
        print "\033[38;5;" rgbcolor "m\033[48;5;" rgbcolor1 "m▍";
        #print "(" r[i] "," g[i] "," b[i] ")";
		#if (r[i] + g[i] + b[i] < 0.10) print "\033[30m" shade[0];
		#else if ((r[i] > g[i]) && (r[i] > b[i])) print "\033[31m" shade[int(r[i]*2.99)];
		#else if ((g[i] > r[i]) && (g[i] > b[i])) print "\033[32m" shade[int(g[i]*2.99)];
		#else print "\033[34m" shade[int(b[i]*2.99)];
	}
	print "\033[0m\n"
}

