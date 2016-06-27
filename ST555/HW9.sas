*set up library to L drive as st555;
libname st555 "L:\";

*sort the fish data and save sorted data set in work library;
proc sort data = st555.fish
          out = work.fishSort;
    by descending lt descending dam;
run;

*select variables that need to be calculated their statistics;
data work.fishsort;
    set work.fishsort;
	keep name lt dam hg rf fr;
run;

*calculate means and medians for selected variables and save the data in work library;
proc means data = work.fishsort noprint
           mean median;
		   by descending lt descending dam;
		   var hg rf fr;
output out = work.fishStat mean = u_hg u_rf u_fr
                           median = med_hg med_rf med_fr;
run;

*create a data set that contains all statisics by merging sorted and stat data sets;
data work.all;
    *merge two data sets by descending lt and dam;
    merge work.fishsort
	      work.fishstat;
    by descending lt descending dam;
    *give new formats to numeric values;
    format u_hg u_rf u_fr 
	       med_hg med_rf med_fr
           d_hg d_rf d_fr 
           dm_hg dm_rf dm_fr
           6.3
           p_hg p_rf p_fr
		   pm_hg pm_rf pm_fr
           percentn9.2;
    *give new labels to new variables;
    label u_hg = 'Mean Hg (within Dam & Lake Type)'
	      u_rf = 'Mean rf (within Dam & Lake Type)'
		  u_fr = 'Mean fr (within Dam & Lake Type)'
          med_hg = 'Median Hg (within Dam & Lake Type)'
		  med_rf = 'Median Runoff Factor (within Dam & Lake Type)'
		  med_fr = 'Median Flushing Rate (within Dam & Lake Type)'
          d_hg = 'Difference from Mean (Hg)'
		  d_rf = 'Difference from Mean (Runoff Factor)'
		  d_fr = 'Difference from Mean (Flushing Rate)'
          dm_hg = 'Difference from Median (Hg)'
		  dm_rf = 'Difference from Median (Runoff Factor)'
		  dm_fr = 'Difference from Median (Flushing Rate)'
          p_hg = 'Percent Difference from Mean (Hg)'
		  p_rf = 'Percent Difference from Mean (Runoff Factor)'
		  p_fr = 'Percent Difference from Mean (Flushing Rate)'
          pm_hg = 'Percent Difference from Median (Hg)'
		  pm_rf = 'Percent Difference from Median (Runoff Factor)'
		  pm_fr = 'Percent Difference from Median (Flushing Rate)'
          ;
	*remove automatic variables _TYPE_ and _FREQ_;
    drop _TYPE_ _FREQ_;
    *create new variables of difference from mean, median, and difference of percentage;
    d_hg = hg - u_hg;
	dm_hg = hg - med_hg;
	d_rf = rf - u_rf;
	dm_rf = rf - med_rf;
	d_fr = fr - u_fr;
	dm_fr = fr - med_fr;
	p_hg = d_hg / u_hg;
	pm_hg = dm_hg / med_hg;
    p_rf = d_rf / u_rf;
	pm_rf = dm_rf / med_rf;
	p_fr = d_fr / u_fr;
    pm_fr = dm_fr / med_fr;
run;

*sort the final data set by lake name;
proc sort data = work.all out = work.all;
    by name;
run;

*reorder the variables;
data work.all;
	retain name hg lt dam u_hg med_hg d_hg dm_hg p_hg pm_hg
	            rf u_rf med_rf d_hg dm_rf p_rf pm_rf
				fr u_fr med_fr d_fr dm_fr p_fr pm_fr;
	set work.all;
run;

*remove other two seed data sets and only leave final data set in work library;
proc datasets library = work;
    delete fishsort fishstat;
run;

quit;

