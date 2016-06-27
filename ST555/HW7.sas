*set up library st555 to L drive;
libname st555 "L:\";

*use proc contents to preview the description and content of the data set;
*proc contents data = st555.airemps;
*run;

*sort data by employee id;
proc sort data = st555.airemps out = work.sort_temp;
    by empid;
run;

*create a temp SAS data set named NewSalary;
data work.NewSalary;
    set st555.airemps;
    *sort by empid;
    by empid;
    *set up new variable newsalary with length of 8;
    length newsalary 8;
    *set up new formats to variables;
    format hiredate date9.
           salary newsalary dollar11.2;
    *calculate new salary by different conditions;
    select;
	    *salary adjustment for employees hired before 1985; 	                
        when (hiredate < '01JAN1985'd) do;
            *salary adjustment by jobcode of PRES and VICEPR;
		    if jobcode in ('PRES', 'VICEPR') then newsalary = salary*1.025 + 3500;
                *salary adjustment by division of FINANCE & IT without PRES and VICEPR;
                else if division = 'FINANCE & IT' and jobcode not in ('PRES', 'VICEPR')
			    then newsalary = salary*1.015 + 3500;
                    *salary adjustment for rest of the employees hired before 1985;
                    else newsalary = salary*1.01 + 3500;
		end;
		*salary adjustment for employees hired between 1985 and 1990;
        when ('31DEC1984'd < hiredate < '01JAN1990'd) do;
            *salary adjustment by jobcode of PRES and VICEPR;
            if jobcode in ('PRES', 'VICEPR') then newsalary = salary*1.02 + 2000;
                *salary adjustment by division of FINANCE & IT without PRES and VICEPR;
                else if division = 'FINANCE & IT' and jobcode not in ('PRES', 'VICEPR')
				then newsalary = salary*1.01 + 2000;
                    *salary adjustment for rest of the employees hired between 1985 and 1990;
                    else newsalary = salary*1.0075 + 2000;
		end;
		*salary adjustment for employees hired after 1990;
        when (hiredate > '31DEC1989'd) do;
            *salary adjustment by jobcode of PRES and VICEPR;
            if jobcode in ('PRES', 'VICEPR') then newsalary = salary*1.0175;
                *salary adjustment by division of FINANCE & IT without PRES and VICEPR;
                else if division = 'FINANCE & IT' and jobcode not in ('PRES', 'VICEPR')
				then newsalary = salary*1.0125;
                    *salary adjustment for rest of the employees hired after 1990;
                    else newsalary = salary*1.0075;
		end;
		*if hire date is missing, then display a note to log and its empid;
        otherwise do;
            newsalary = .;
			put empid 'no hire date and new salary information.';
		end;
	end;
run;

*set up options in global environment;
option nodate pageno = 2 orientation = landscape;
*close output data to list;
ods listing close;
*set up output destination to pdf file to a local address;
ods pdf file = "C:\\Users\u213493\Desktop\New Salary Report.pdf";

*use proc print to generate report with pdf format;
proc print data = Work.NewSalary label split = "*";
    *set up title and footnotes;
    title "New Salary Report";
	footnote "Updated: 2016-06-05";
	footnote2 "by: Brian Wang";
    *set up new names to variables;
    label empid = "Employee*ID"
	      firstname = "First Name"
		  lastname = "Last Name"
		  division = "Division"
		  jobcode = "Job*Code"
		  phone = "Phone*Extention"
		  hiredate = "Hire Date"
		  salary = "Old Salary"
		  newsalary = "New Salary"
		  ;
    *select variables to be displayed on the report;
    var empid firstname lastname division jobcode 
        phone hiredate salary newsalary;
run;

*resume output destination to list;
ods listing;
*close output destination to pdf;
ods pdf close;

quit;

