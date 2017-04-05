PROC IMPORT OUT= WORK.Fitbit
            DATAFILE= "C:\Users\Aalisha Sheth\Documents\BIA652_Multivariate\fitbit_new.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*Initial Exploration Regression Analysis;
proc reg data= fitbit outest=est_fitbit_02  PLOTS(MAXPOINTS=15000 );
     model  Activity_Calories = Steps Distance Minutes_Sedentary Minutes_Lightly_Active 
			Minutes_Fairly_Active Minutes_Very_Active/ VIF selection=stepwise; 
run;
quit;

* aggregating rows per user;
proc sql;
create table fitbit_02 as
select
        Name, Weekday,
        avg(Calories_Burned) as Calories_Burned_avg,
        avg(Steps) as Steps_Avg,
        avg(Distance) as Distance_Avg,
        avg(Floors)as Floors_Avg,
        avg(Minutes_Sedentary)as Minutes_Sedentary_Avg,
        avg(Minutes_Lightly_Active) as Minutes_Lightly_Active_Avg,
        avg(Minutes_Fairly_Active) as Minutes_Fairly_Active_Avg,
        avg(Minutes_Very_Active) as Minutes_Very_Active_Avg,
        avg(Activity_Calories) as Activity_Calories_Avg,
        avg(Minutes_Asleep) as Minutes_Asleep_Avg,
        avg(Minutes_Awake) as Minutes_Awake_Avg,
        avg(Number_of_Awakenings)as Number_of_Awakenings_Avg,
        avg(Time_in_Bed) as Time_in_Bed_Avg
        from fitbit
group by Name,Weekday;
quit;



*Second Exploration Regression Analysis after cleaning data;
proc reg data= fitbit_02 outest=est_fitbit_02  PLOTS(MAXPOINTS=15000 );
     model  Activity_Calories_avg = Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg 
			Minutes_Fairly_Active_avg Minutes_Very_Active_avg/ VIF selection=stepwise;
run;
quit;

*replace 0 values with null;
data fitbit_03;
	set fitbit_02;
	if Floors_Avg=0 then Floors_Avg='';
	if Minutes_Lightly_Active_Avg=0 then Minutes_Lightly_Active_Avg='';
	if Minutes_Fairly_Active_Avg=0 then Minutes_Fairly_Active_Avg='';
	if Minutes_Very_Active_Avg=0 then Minutes_Very_Active_Avg='';
	if Minutes_Asleep_Avg=0 then Minutes_Asleep_Avg='';
	if Minutes_Awake_Avg=0 then Minutes_Awake_Avg='';
	if Number_of_Awakenings_Avg=0 then Number_of_Awakenings_Avg='';
	if Time_in_Bed_Avg=0 then Time_in_Bed_Avg='';
run;

*third Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg to predict calorie burned";
Title2 "Regression Analysis " ;
proc reg data=fitbit_03 outest=est_fitbit_03  PLOTS(MAXPOINTS=15000 );
	model Activity_Calories_avg=Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg 
		  Minutes_Fairly_Active_avg Minutes_Very_Active_avg	/VIF selection=stepwise;
run;
quit;

*Regression between activity calories and steps;
proc reg data=fitbit_03 outest=est_fitbit_03  PLOTS(MAXPOINTS=15000 );
	model Activity_Calories_avg=Steps_avg;
	run;

*Removing steps;
proc reg data=fitbit_03 outest=est_fitbit_03  PLOTS(MAXPOINTS=15000 );
	model Activity_Calories_avg=Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg 
		  Minutes_Fairly_Active_avg Minutes_Very_Active_avg	/VIF selection=stepwise;

*Correlation between steps and distance;
proc corr data=fitbit_03;
var steps_avg distance_avg;
run;
