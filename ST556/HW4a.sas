data one;
    length county $20 city $20;
    input county_id county $ city_id city $ popn income;
    call symputx("county"||left(county_id), county);
    call symputx("city"||left(city_id), city);
    datalines;
1 Wake 1 Raleigh 404 32.6
1 Wake 2 Cary 135 32.6
2 Mecklenburg 3 Charlotte 731 31.8
2 Mecklenburg 4 Davidson 11 31.8
;
run;

options nomlogic nomprint symbolgen formdlim="=" minoperator mindelimiter=',' nodate pageno=1;
%macro munisum(mtype,id);
    proc means data=one mean maxdec=2;
        title "%sysfunc(propcase(&mtype)) Report";
        title2 "Average Population & Per-Capita Income";
        where &mtype._id=&id;
        by &mtype;
        var popn income;
    run;
%mend munisum;

%munisum(county,1)
%munisum(county,2)
%munisum(city,1)

options nosymbolgen;

title;
proc sql;
    select employee_gender "Gender", marital_status, salary format=dollar8.,
	    salary*0.25 as Tax format=dollar8.
        from orion.employee_payroll;
	describe table orion.employee_payroll;
quit;

proc contents data=orion.employee_payroll;
run;

proc sql;
    create table work.males as
	select employee_id, marital_status, 
           salary format=dollar8., salary*0.25 as Tax format=dollar8.
	    from orion.employee_payroll
	where employee_gender = "M";
quit;
