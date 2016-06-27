*read empdata.dat to SAS;
data work.emp;
    infile 'L:\\empdata.dat' firstobs = 2;
    input hiredate : date9.
	      empid $
		  jobcode $
		  salary : dollar8.
		  ;
run;

*read divisions.dat to SAS;
data work.div;
    infile 'L:\\divisions.dat' firstobs = 2;
	input @1 division & $20.
	      @21 jobcode $
		  ;
run;

*read personal.dat to SAS;
data work.psn;
    infile 'L:\\personal.dat' firstobs = 2;
    input @1  lastname $19.
	      @20 firstname & $19.
	      @40 phone $
		  @46 empid $
		  ;
run;

*sort data by jobcode for merging;
proc sort data = work.emp
          out = work.emp;
    by jobcode;
run;

*sort data by jobcode for merging;
proc sort data = work.div
          out = work.div;
    by jobcode;
run;

*merge emp and div data sets by jobcode;
data work.merge1;
    merge work.emp
	      work.div;
    by jobcode;
run;

*sort merged data by empid for merging;
proc sort data = work.merge1
          out = work.merge1;
    by empid;
run;

*sort psn data by empid for merging;
proc sort data = work.psn
          out = work.psn;
    by empid;
run;

*merge first merged and psn data sets by empid;
data work.airemps;
    merge work.merge1
	      work.psn;
    by empid;
run;
    
*set up output delivering system;
ods listing close;
ods pdf file = 'C:\\Users\u213493\Desktop\New Salary Report YoS Basis.pdf';

*modify data set with new salary calculations and full name of employee;
data work.airemps;
    set work.airemps;
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
	set work.airemps;
run;

*remove data sets that are not important;
*proc datasets library = work;
*    delete merge1 emp div psn;
*run;

*set up options;
option pageno = 2 nodate orientation = landscape;

*create pdf file to designated destination;
proc print data = Work.NewSalaryYoS label;
    *set up title and footnotes;
    title "New Salary Report YoS Basis";
	footnote "Updated: 2016-06-16";
	footnote2 "by: Brian Wang";
run;

*clear title and footnote;
title;
footnote;

*reset ods to original state;
ods pdf close;
ods listing;

quit;
