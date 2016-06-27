proc format;
   *Create the LAKETYPE format;
   value laketype
   1='Oligotrophic'
   2='Eutrophic'
   3='Mesotrophic'
   . ='Unknown'
   ;
   *Create the SAFETY format;
   value safety
   low-<0.25='Safe'
   0.25-<0.5='Marginal'
   0.5-high='Unsafe'
   ;
   *Create the DAMS format;
   value dams
   0 = 'No Dam'
   1 = 'Dam Present'
   ;
run;

*set up library st555 to L drive;
libname st555 "L:\";

*set up options for report display;
options formdlim = "~" linesize = 110 nodate nonumber;

*create a statistical summary for Fish data set;
proc means data = st555.Fish 
           /*set up options for displaying the summary*/   
           nonobs order=formatted maxdec = 3
           /*set up statistics to display in the summary*/ 
           n min median max
           ;
    *create title;
    title "Summary Statistics by Lake Type and Mercury Status";
    *select variables for displaying statistics;
    var elv sa z;
    *grouped by Lake Type and Mercury Level;
    class lt hg;
    *reformat values for Lake Type and Mercury Level;
    format lt laketype.
	       hg safety.
           ;
run;

*create tables for Fish data set;
proc freq data = st555.Fish;
    *create title;
    title "Distribution of Lake Type vs Mercury Status";
	title2 "With and Without Dam Present";
    *create three-way tables;
    table dam*lt*hg / nopercent nocol;
    *reformat values for Lake Type, Mercury Level, and Dam Present;
    format lt laketype.
		   hg safety.
           dam dams.;
run;
