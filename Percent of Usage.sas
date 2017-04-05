/* Import data that has frequencies of usage statistics */

PROC IMPORT OUT= WORK.FITBIT_Frequency
	DATAFILE= "C:\Users\Stevens\Desktop\SAS\FITBIT_Frequency.csv" 
    DBMS=csv REPLACE;
    GETNAMES=YES;
    DATAROW=2;
	guessingrows=4019; 
RUN;

/* Aggregating Averages with Percent of Time Used */

proc sql;
create table FITBIT_Perc_of_Use as
select
        Name, Perc_of_Use,
        avg(Calories_Burned) as Calories_Burned_Avg,
        avg(Steps) as Steps_Avg,
        avg(Distance) as Distance_Avg,
        avg(Floors)as Floors_Avg,
        avg(Minutes_Sedentary)as Minutes_Sedentary_Avg,
        avg(Minutes_Lightly_Active) as Minutes_Lightly_Active_Avg,
        avg(Minutes_Fairly_Active) as Minutes_Fairly_Active_Avg,
        avg(Minutes_Very_Active) as Minutes_Very_Active_Avg,
        avg(Activity_Calories) as Activity_Calories_Avg
		from FITBIT_Frequency
group by Name,Perc_of_Use;
quit;

/* Replacing all Zero Values with Nulls */

data FITBIT_Usage_Nulls;
	set FITBIT_Perc_of_Use;
	if Floors_Avg=0 then Floors_Avg='';
	if Minutes_Lightly_Active_Avg=0 then Minutes_Lightly_Active_Avg='';
	if Minutes_Fairly_Active_Avg=0 then Minutes_Fairly_Active_Avg='';
	if Minutes_Very_Active_Avg=0 then Minutes_Very_Active_Avg='';
run;

/* Putting decimal ranges into percent ranges */

data FITBIT_Usage;
	set FITBIT_Usage_Nulls;
	if Perc_of_Use<.1 then Perc_of_Use=10;
	if Perc_of_Use<.2 then Perc_of_Use=20;
	if Perc_of_Use<.3 then Perc_of_Use=30;
	if Perc_of_Use<.4 then Perc_of_Use=40;
	if Perc_of_Use<.5 then Perc_of_Use=50;
	if Perc_of_Use<.6 then Perc_of_Use=60;
	if Perc_of_Use<.7 then Perc_of_Use=70;
	if Perc_of_Use<.8 then Perc_of_Use=80;
	if Perc_of_Use<.9 then Perc_of_Use=90;
	if Perc_of_Use<=1 then Perc_of_Use=100;
run;

/* Histogram of Correlation between time used and calories burned */

proc sgplot data=FITBIT_Usage;
title "Percent Usage vs activity level";
  yaxis label="Calories Burned" ;
  xaxis label="Percent Used" ;
  vbar Perc_of_Use / response=Calories_Burned_Avg;
 
run;

/* Scatterplot of Correlation between time used and calories burned */
ods graphics on;
proc corr data=FITBIT_Usage plots=scatter(ellipse=prediction);
   var Perc_of_Use Calories_Burned_Avg ;
run;
