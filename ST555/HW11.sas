/*==========================================================
                        HW11 Program 1
  ==========================================================*/

*set up library to L drive;
libname st555 'L:\';
*set up output delivering system;
ods listing close;
ods pdf file = 'C:\\Users\u213493\Desktop\New Salary Report YoS Basis.pdf';

*sort data AirEmps by empid;
proc sort data = st555.airemps out = work.sort_temp;
    by empid;
run;

*preview the description of data set;
*proc contents data = work.sort_temp;
*run;

*modify data set with new salary calculations and full name of employee;
data work.temp;
    set work.sort_temp;
	*Uppercase first letter in variable division;
    division = propcase(division);
	if division = 'Finance & It' then division = 'Finance & IT';
    *combine last and first name in one variable;
    name = propcase(trim(lastname)||', '||trim(firstname));
    *calculate the years of service since hire date until today;
    yr_service = intck('year', hiredate, today());
    *set up proper formats;
    format salary New_Salary_YoS dollar11.2
           hiredate date9.
           ;
	*add proper label each variable;
	label empid = 'Employee ID'
	      name = 'Employee Name (Last, First)'
		  jobcode = 'Job Code'
		  division = 'Division'
		  phone = 'Phone Extension'
		  hiredate = 'Hire Date'
		  yr_service = 'Years of Service'
		  salary = 'Old Salary'
		  new_salary_yos = 'New Salary'
		  ;
	*calculate new salart based on years of service;
    select;
	    *;
	    when (yr_service >= 35) do;
		    if substr(jobcode, 6, 1) in ('2', '3') then New_Salary_YoS = salary*1.025 + 3500;
                else if substr(jobcode, 6, 1) = '1' then New_Salary_YoS = salary*1.015 + 3500;
				    else New_Salary_YoS = salary*1.02 + 3500;
		end;
		when (yr_service >= 25) do;
		    if substr(jobcode, 6, 1) in ('2', '3') then New_Salary_YoS = salary*1.02 + 2000;
                else if substr(jobcode, 6, 1) = '1' then New_Salary_YoS = salary*1.01 + 2000;
				    else New_Salary_YoS = salary*1.0175 + 2000; 
		end;
	    otherwise do;
		    if substr(jobcode, 6, 1) in ('2', '3') then New_Salary_YoS = salary*1.0275;
                else if substr(jobcode, 6, 1) = '1' then New_Salary_YoS = salary*1.0175;
				    else New_Salary_YoS = salary*1.025; 
		    if yr_service = . then put empid 'missing hire date.';
		end;
	end;
	*remove redundant variables;
	drop firstname lastname;
run;

*reorder variables in data set;
data work.NewSalaryYoS;
    retain empid name jobcode division phone hiredate yr_service salary new_salary_yos;
	set work.temp;
run;

*delete temp data set in work library;
proc datasets library = work;
    delete temp sort_temp;
run;

*set up options;
option pageno = 2 nodate orientation = landscape;

*create pdf file to designated destination;
proc print data = Work.NewSalaryYoS label;
    *set up title and footnotes;
    title "New Salary Report YoS Basis";
	footnote "Updated: 2016-06-14";
	footnote2 "by: Brian Wang";
run;

*reset ods to original state;
ods pdf close;
ods listing;

quit;

/*==========================================================
                        HW11 Program 2
  ==========================================================*/

*sort Fish data set by lt and dam;
proc sort data = st555.fish
          out = work.fishSort;
    by descending lt descending dam;
run;

*remove irrelevant and indicating variables ;
data work.temp;
    set work.fishsort;
	drop name st lat1 lat2 lat3 long1 long2 long3;
run;

*calculate means and medians;
proc means data = temp noprint
           mean median;
    by descending lt descending dam;
	var hg n elv sa z da rf fr;
output out = work.fishStat mean = u_hg u_n u_elv u_sa u_z u_da u_rf u_fr
                           median = med_hg med_n med_elv med_sa med_z med_da med_rf med_fr;
run;

*merge statistics and raw data sets by lt and dam;
data work.tpAll;
    merge work.temp
	      work.fishstat;
	by descending lt descending dam;
    drop _TYPE_ _FREQ_ lt dam;
run;

*calculate new statistics as new variables;
data all (drop = i);
    set work.tpall;
	*calculate difference from mean;
    array origin[*] _numeric_;
    array caltemp[8] d_hg d_n d_elv d_sa d_z d_da d_rf d_fr;
	do i = 1 to 8;
	    caltemp[i] = origin[i] - origin[i + 8];
	end;
    *calculate difference from median;
	array origin1[*] _numeric_;
	array caltemp1[8] dm_hg dm_n dm_elv dm_sa dm_z dm_da dm_rf dm_fr;
	do i = 1 to 8;
	    caltemp1[i] = origin1[i] - origin[i + 16];
	end;
    *calculate percentage of difference to mean;
	array origin2[*] _numeric_;
	array caltemp2[8] p_hg p_n p_elv p_sa p_z p_da p_rf p_fr;
	do i = 1 to 8;
	    caltemp2[i] = origin2[i + 24] / origin2[i + 8];
    end;
    *calculate percentage of difference to median;
    array origin3[*] _numeric_;
    array caltemp3[8] pm_hg pm_n pm_elv pm_sa pm_z pm_da pm_rf pm_fr;
    do i = 1 to 8;
        caltemp3[i] = origin3[i + 32] / origin3[i + 16]; 
    end;
    *set up permanent labels;
	label u_hg = 'Mean Hg (within Dam & Lake Type)'
          u_n = 'Mean # of fish (within Dam & Lake Type)'
		  u_elv = 'Mean Elevation (ft.) (within Dam & Lake Type)' 
		  u_sa = 'Mean Surface Area (arces) (within Dam & Lake Type)'
		  u_z = 'Mean Max. depth (ft.) (within Dam & Lake Type)'
		  u_da = 'Mean Drainage area (within Dam & Lake Type)'
          u_rf = 'Mean rf (within Dam & Lake Type)'
		  u_fr = 'Mean fr (within Dam & Lake Type)'
          med_hg = 'Median Hg (within Dam & Lake Type)'
		  med_n = 'Median # of fish (within Dam & Lake Type)'
		  med_elv = 'Median Elevation (ft.) (within Dam & Lake Type)'
		  med_sa = 'Median Surface Area (arces) (within Dam & Lake Type)'
		  med_z = 'Median Max. depth (ft.) (within Dam & Lake Type)'
		  med_da = 'Median Drainage area (within Dam & Lake Type)'
		  med_rf = 'Median Runoff Factor (within Dam & Lake Type)'
		  med_fr = 'Median Flushing Rate (within Dam & Lake Type)'
		  d_hg = 'Difference from Mean (Hg)'
		  d_n = 'Difference from Mean (# of fish)' 
		  d_elv = 'Difference from Mean (Elevation (ft.))'
		  d_sa = 'Difference from Mean (Surface Area (arces))'
		  d_z = 'Difference from Mean (Max. depth (ft.))'
		  d_da = 'Difference from Mean (Drainage area)'
		  d_rf = 'Difference from Mean (Runoff Factor)'
		  d_fr = 'Difference from Mean (Flushing Rate)'
          dm_hg = 'Difference from Median (Hg)'
		  dm_n = 'Difference from Median (# of fish)' 
		  dm_elv = 'Difference from Median (Elevation (ft.))' 
		  dm_sa = 'Difference from Median (Surface Area (arces))' 
		  dm_z = 'Difference from Median (Max. depth (ft.))' 
		  dm_da = 'Difference from Median (Drainage area)' 
		  dm_rf = 'Difference from Median (Runoff Factor)'
		  dm_fr = 'Difference from Median (Flushing Rate)'
          p_hg = 'Percent Difference from Mean (Hg)'
		  p_n = 'Percent Difference from Mean (# of fish)' 
		  p_elv = 'Percent Difference from Mean (Elevation (ft.))'
		  p_sa = 'Percent Difference from Mean (Surface Area (arces))' 
		  p_z = 'Percent Difference from Mean (Max. depth (ft.))' 
		  p_da = 'Percent Difference from Mean (Drainage area)' 
		  p_rf = 'Percent Difference from Mean (Runoff Factor)'
		  p_fr = 'Percent Difference from Mean (Flushing Rate)'
          pm_hg = 'Percent Difference from Median (Hg)'
		  pm_n = 'Percent Difference from Median (# of fish)'
		  pm_elv = 'Percent Difference from Median (Elevation (ft.))'
		  pm_sa = 'Percent Difference from Median (Surface Area (arces))'
		  pm_z = 'Percent Difference from Median (Max. depth (ft.))'
		  pm_da = 'Percent Difference from Median (Drainage area)'
		  pm_rf = 'Percent Difference from Median (Runoff Factor)'
		  pm_fr = 'Percent Difference from Median (Flushing Rate)'
          ;
    *set up proper formats;
    format u_hg u_n u_elv u_sa u_z u_da u_rf u_fr 
           med_hg med_n med_elv med_sa med_z med_da med_rf med_fr
		   d_hg d_n d_elv d_sa d_z d_da d_rf d_fr
           dm_hg dm_n dm_elv dm_sa dm_z dm_da dm_rf dm_fr
           6.3
           p_hg p_n p_elv p_sa p_z p_da p_rf p_fr
		   pm_hg pm_n pm_elv pm_sa pm_z pm_da pm_rf pm_fr
           percentn9.2
           ;
run;

*get partial data set only contains name lt dam st variables;
data work.fishsort_p;
    set work.fishsort;
	keep name lt dam st;
run;

*one-to-one merge fish_sort_p and all to get name lt dam st variables;
data work.all;
    set work.fishsort_p;
	set work.all;
run;

*sort data set by name;
proc sort data = work.all;
    by name;
run;

*delete temp data sets in work library;
proc datasets library = work;
    delete fishsort fishsort_p fishstat temp tpall;
run;

*set up output destination;
ods listing close;
ods pdf file = 'C:\\Users\u213493\Desktop\Fish Summary.pdf';
ods rtf file = 'C:\\Users\u213493\Desktop\Fish Summary.rtf';
*set up options;
option nonumber date;

*create reports;
proc print data = work.all
           label;
    id name;
    title;
	footnote '06/14/2016';
run;

*reset output destination;
ods pdf close;
ods rtf close;
ods listing;

quit;
