*set up global options;
options formdlim = "=";

*create macro variables for # of simulations and sample size;
%let nsim = 3000;
%let ndice = 3;

*simulate rolling n dice and record output in a data set;
data dice&ndice;
    do n = 1 to &nsim;
	    dsum = 0;
	    do m = 1 to &ndice;
	        dice = ceil(6 * ranuni(123));
		    dsum+dice;
			output;
		end;
	end;
run;

*print data set that contains sum of rolling n dice;
*proc print data = dice&ndice;
*    where (m = &ndice);
*run;

*print frequecy of sum of rolling n dice;
proc freq data = dice&ndice;
    where m = &ndice;
    table dsum / norow nopercent;
	title "Frequency of Sum of Rolling &ndice Dice";
	title2 "with &nsim Simulations";
run;

title2;

*plot histogram for sum of rolling n dice;
proc gchart data = dice&ndice;
    where m = &ndice;
    vbar dsum;
run;

*calculate expected value of rolling n dice;
proc means data = dice&ndice mean;
    where m = &ndice;
	var dsum;
	title "The Expected Value of Rolling";
	title2 "&ndice Dice";
run;

title2;

quit;
