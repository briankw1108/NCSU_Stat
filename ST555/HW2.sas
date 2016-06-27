libname St555 'L:\';                                             *load library St555 in L drive;

options pageno=1 nodate linesize=85 pagesize=55 formdlim = "=";  *set up options in global environment;

proc sort data=St555.Fish out=Work.Fish1;                        *proc sort step to sort data;
    by dam lt n;                                                 *sort data set by variable dam lt n;
run;

proc print data=Work.Fish1 double label split="*";               *proc print step;
    where elv < 1000;                                            *filter the data with elv < 1000;
        title "Sum of Runoff Factor and Flushing Rate";          *title line 1;
        title2 "By Dam Status (1 = Present) and Lake Type";      *title line 2;
        title3 "for Elevation of at most 1000 ft";               *title line 3;
        var lat1 lat2 lat3 long1 long2 long3 rf fr;              *select printed variables;
            label lat1 = "Latitude*(deg.)"                               
	              lat2 = "Lat.*(min.*part)"
		          lat3 = "Lat.*(set.*part)"
		          long1 = "Longitude*(deg.)"
		          long2 = "Long.*(min.*part)"
		          long3 = "Long.*(set.*part)"
		          rf = "Runoff*factor"
		          fr = "Fishing*rate*(#/year)";                  *rename printed variable names;
	        id name;                                             *use name as first variable column;
	        by dam lt n;                                         *grouped by dam lt n;
            pageby lt;                                           *create a new page when lt changes;
			sum rf fr;                                           *sum variable rf and fr;
	        sumby lt;                                            *sum by lt for each level;
            sumby dam;                                           *sum by dam for each level;
		    format rf 6.3                                        
		           fr 6.2;                                       *reset numeric format for variable rf & fr;
	    footnote "Report prepared by Brian Wang";                *add footnote;
run;
