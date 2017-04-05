/* Import data that has frequencies of usage statistics */

PROC IMPORT OUT= WORK.FITBIT_Frequency
	DATAFILE= "C:\Users\Stevens\Desktop\SAS\FITBIT_Frequency.csv" 
    DBMS=csv REPLACE;
    GETNAMES=YES;
    DATAROW=2; 
	guessingrows=4019;
RUN;

/* Aggregating and Averaging by User and Weekends*/

proc sql;
create table FITBIT_Weekend_Avg as
select
        Name, Weekday,
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
group by Name, Weekday;
quit;

/* Replacing all Zero Values with Nulls */

data FITBIT_Weekend_Nulls;
	set FITBIT_Weekend_Avg;
	if Floors_Avg=0 then Floors_Avg='';
	if Minutes_Lightly_Active_Avg=0 then Minutes_Lightly_Active_Avg='';
	if Minutes_Fairly_Active_Avg=0 then Minutes_Fairly_Active_Avg='';
	if Minutes_Very_Active_Avg=0 then Minutes_Very_Active_Avg='';
run;

/* Histogram of Correlation between Weekday/Weekend and calories burned or Intense Activity */

proc sgplot data=FITBIT_Weekend_Avg;
title "Weekends vs activity level";
  yaxis label="Minutes_Very_Active_Avg" ;
  xaxis label="Weekend" ;
  vbar Weekday / response= Minutes_Very_Active_Avg;
 
run;


proc sgplot data=FITBIT_Weekend_Nulls;
title "Weekends vs activity level";
  yaxis label="Calories Burned" ;
  xaxis label="Weekend" ;
  vbar Weekday / response= Calories_Burned_Avg;
 
run;

/* Scatterplot of Correlation between Weekday/Weekend and calories burned */

proc corr data=FITBIT_Weekend_Nulls plots=scatter(ellipse=prediction);
   var Weekday Calories_Burned_Avg ;
run;

proc corr data=FITBIT_Weekend_Nulls plots=scatter(ellipse=prediction);
   var Weekday Minutes_Very_Active_Avg ;
run;

/* Regression to predict calories burned by Weekday and Activity Metrics */

Title1 "Proc Reg to predict calorie burned";
Title2 "Regression Analysis " ;
proc reg data=FITBIT_Weekend_Nulls outest=est_FITBIT_Weekend_Nulls;
	model Activity_Calories_Avg= Weekday Steps_Avg Distance_Avg Minutes_Very_Active_Avg
		/ dwProb selection= rsquare partial noint VIF details; 
	OUTPUT OUT = reg_fitbitOUT PREDICTED=PRCDT RESIDUAL=c_Res
	h=lev cookd=Cookd dffits=dffit ;

run;
quit;

/* Exploring aforementioned analyses with standardized data */

proc standard data=FITBIT_Weekend_Nulls mean=0 std=1
              out=FITBIT_Weekend_STD;
run;

proc print data=FITBIT_Weekend_STD;
run;
