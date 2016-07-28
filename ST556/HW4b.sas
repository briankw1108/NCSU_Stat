*Question 3;
ods trace on;
options pageno=1 nodate formdlim="=";

proc freq data=orion.customer_dim;
    table customer_group;
	ods output onewayfreqs=owf;
run;

proc sort data=work.owf;
    by descending Frequency;
run;

data _null_;
    set work.owf (obs=1);
    call symputx("most", customer_group);
run;

data _null_;
    set work.owf end=last;
	call symputx("least", customer_group);
	if last;
run;

proc print data=orion.customer_dim (obs=5);
    where customer_group="&most";
	title "the most abundant group is %upcase(&most)!!!";
	var customer_name customer_gender customer_age customer_group;
run;

*create a macro that can print the the same report as what the previous steps can do;
%macro frequent(freq);
    %if &freq=most %then %do;
	    data _null_;
		    set work.owf (obs=1);
			call symputx("most", customer_group);
		run;
	%end;
	%else %if &freq=least %then %do;
	    data _null_;
		    set work.owf end=last;
			call symputx("least", customer_group);
			if last;
		run;
    %end;
	%else %put ERROR: "&freq" is not a valid argument. This function can only take argument either "most" or "least";
    %if &freq=most or &freq=least %then %do;
        proc print data=orion.customer_dim (obs=5);
	        where customer_group="&&&freq";
		    title "the &freq abundant group is %upcase(&&&freq)";
		    var customer_name customer_gender customer_age customer_group;
        run;
	%end;
	%else;
%mend frequent;

%put _user_;

%frequent(least)
%frequent(most)
%frequent(a)

ods trace off;

*Question 4;
title;
proc contents data=orion.customer;
run;

proc freq data=orion.customer;
    where country in ("AU", "ZA");
    table country;
	title "Southern Hemisphere";
proc freq data=orion.customer;
    where country not in ("AU", "ZA");
	table country;
	title "Northern Hemisphere";
run;

options minoperator mindelimiter=',' mcompilenote=all;
%macro hemifreq(hemi);
    %let hemi1=%upcase(&hemi);
    %if &hemi1 in (S, SOUTH, SOUTHERN) %then %do; 
        proc freq data=orion.customer;
            where country in ("AU", "ZA");
            table country;
            title "Southern Hemisphere";
		run;
    %end;
	%else %if &hemi1 in (N, NORTH, NORTHERN) %then %do;
	    proc freq data=orion.customer;
		    where country not in ("AU", "ZA");
		    table country;
		    title "Northern Hemisphere";
	    run;
	%end;
	%else %put ERROR: Invalid argument of "&hemi";
%mend hemifreq;

options pageno=1 mlogic mprint;
%hemifreq(SOUTHERN)
%hemifreq(n)
%hemifreq(western)

*Question 5;
options ls=75 nocenter mlogic;
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

title;


proc sort data=one;
    by county;
run;
proc means data=NC mean maxdec=2;
    by county;
	var popn income;
run;

%macro countysum(id);
    %if &id=1 %then %let id=Wake;
	%else %if &id=2 %then %let id=Mecklenburg;
	%else %put ERROR: &id is an invalid county id;
    proc means data=one mean maxdec=2;
        title "report for county=&id";
        where county="&id";
        var popn income;
    run;
%mend countysum;

%countysum(1)
%countysum(2)

options mlogic mprint symbolgen;
%macro munisum(mtype,id);
    %if not (&mtype in (city,county)) %then %do; 
        %put ERROR: &mtype is an invalid argument;
		%abort;
	%end;
	%else %if (&mtype = county) and (&id in (3, 4)) %then %do;
	    %put ERROR: &mtype does not have id=&id;
		%abort;
	%end;
    %if not (&id in (1,2,3,4)) %then %do;
        %put ERROR: &id is an invalid number;
		%abort;
	%end;
    proc means data=one mean maxdec=2;
	    title "&mtype report";
		title2 "Hi";
		where &mtype._id = &id;
		var popn income;
	run;
%mend munisum;

%munisum(county,2)
%munisum(a,1)


%put _user_;
%put &mtype._id;
%symdel mtype;

options minoperator mindelimiter=',';
%put ERROR: mtype is an invalid argument;

%macro frequent1(frequency);
    data owf;
        set owf ;
        if _n_=1 then do;
            call symputx("most", Customer_Group);
        end;
        if _n_=3 then do;
            call symputx("least", Customer_Group);
        end;
    run;
    proc print data =orion.customer_dim (obs=5);
        where customer_group ="&&&frequency";
        title " the &&frequency abundant group is %upcase(&&&frequency) ";
        var customer_name customer_gender customer_age customer_group ;
    run;
%mend frequent1;

/*tests the macro call function frequent for the two possible input values*/
options formdlim="=";
%frequent(most)
%frequent1(most)
%frequent(least)
%frequent1(least)

proc print data=owf;
run;

data owf;
        set owf ;
        if _n_=1 then do;
            call symputx("most", Customer_Group);
        end;
        if _n_=3 then do;
            call symputx("least", Customer_Group);
        end;
    run;

*Robin's code;
%macro frequent1(frequency);
    data owf;
        set owf ;
        if _n_=1 then call symputx("most", Customer_Group);
        if _n_=3 then call symputx("least", Customer_Group);
    run;
    proc print data =orion.customer_dim (obs=5);
        where customer_group ="&&&frequency";
        title " the &&frequency abundant group is %upcase(&&&frequency) ";
        var customer_name customer_gender customer_age customer_group ;
    run;
%mend frequent1;
