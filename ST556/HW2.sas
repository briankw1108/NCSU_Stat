data a;
do i=1 to 5; a=rannor(i); output; end;
run;

data b;
do i=1 to 5; b=rannor(i+1); output; end;
run;

data c;
do i=1 to 5; c=rannor(1); output; end;
run;

data all3;
merge a b c;
run;

proc print data=all3;run;

title;

libname st556 "C:/Users/u213493/Desktop/NC_State/ST556/HW2";

options ls=75 nocenter;
data st556.d;
retain seed1 seed2 1;
do i=1 to 5;
    call rannor(seed1,d1);
    call rannor(seed2,d2);
    d3 = rannor(seed1);
    output;
    if i=4 then seed2=4;
end;
run;
proc print;run;
