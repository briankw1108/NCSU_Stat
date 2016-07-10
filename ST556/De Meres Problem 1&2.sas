data demere2;
    seed = 1234;
	do i = 1 to 10000;
	    atleast1 = 0;
	    do pair = 1 to 24;
		    die1 = ceil(6 * ranuni(seed));
			die2 = ceil(6 * ranuni(seed));
            snakeeye = (max(die1, die2) = 1);
			atleast1 = max(atleast1, snakeeye);
		end;
		success = atleast1;
		output;
	end;
run;

data demere1;
    seed = 123;
	do i = 1 to 10000;
	    die1 = ceil(6 * ranuni(seed));
		die2 = ceil(6 * ranuni(seed));
		die3 = ceil(6 * ranuni(seed));
		die4 = ceil(6 * ranuni(seed));
		atleast1 = (min(of die1 - die4) = 1);
        totalSuc + atleast1;
        output;
	end;
run;

proc means data = demere1 mean;
    var atleast1;
run;

proc means data = demere2 mean;
    var success;
run;
