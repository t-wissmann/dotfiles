#!/bin/awk -f

# Setup
BEGIN {
	chunksize=int(1000/barlength+0.5);
	n=0;
	rmax=1; gmax=1; bmax=1;
}

# Sum the samples in each chunk and find the max value for each color
!(NR%chunksize-1) {
	r[n]=$1; g[n]=$2; b[n]=$3;
	for (i=1;i<chunksize;i++) {getline; r[n]+=$1; g[n]+=$2; b[n]+=$3};
	if (r[n] > rmax) rmax = r[n]; if (g[n] > gmax) gmax = g[n]; if (b[n] > bmax) bmax = b[n];
	n++;
}

# Draw the moodbar
END {
	ORS=""; shade[0]="░"; shade[1]="▒"; shade[2]="▓"; print "[";
	for (i=1;i<=barlength;i++) {
		r[i]/=rmax*1.25; g[i]/=gmax; b[i]/=bmax;
		if (r[i] + g[i] + b[i] < 0.10) print "\033[30m" shade[0];
		else if ((r[i] > g[i]) && (r[i] > b[i])) print "\033[31m" shade[int(r[i]*2.99)];
		else if ((g[i] > r[i]) && (g[i] > b[i])) print "\033[32m" shade[int(g[i]*2.99)];
		else print "\033[34m" shade[int(b[i]*2.99)];
	}
	print "\033[0m]\n"
}

