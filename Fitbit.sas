proc import datafile="C:\Users\HARSHITA\Desktop\BIA652\Project\fitbit_new.csv"
     out=FITBIT
     dbms=csv
     replace;
     getnames=yes;
	 datarow=2;
run;

/* Applying univariate*/
proc univariate data=fitbit normaltest plot ;
  var Calories_Burned Steps Distance Floors Minutes_Sedentary Minutes_Lightly_Active Minutes_Fairly_Active
		Minutes_Very_Active	Activity_Calories Minutes_Asleep Minutes_Awake Number_of_Awakenings Time_in_Bed; 
		
quit;

*Initial Exploration Regression Analysis;
proc reg data= fitbit outest=est_fitbit_02  PLOTS(MAXPOINTS=15000 );
     model  Activity_Calories = Steps Distance Minutes_Sedentary Minutes_Lightly_Active 
			Minutes_Fairly_Active Minutes_Very_Active Minutes_Asleep Minutes_Awake Number_of_Awakenings 
			Time_in_Bed/ noint dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
			OUTPUT OUT = reg_fitbitOUT PREDICTED=PRCDT RESIDUAL=c_Res
			L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
			rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
			STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;
run;
quit;

/* aggregating weekdays and weekends*/
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


/* Applying univariate*/
proc univariate data=fitbit_02  normaltest plot ;
  var Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg Minutes_Fairly_Active_avg
		Minutes_Very_Active_avg	Activity_Calories_avg Minutes_Asleep_Avg Minutes_Awake_Avg Number_of_Awakenings_Avg Time_in_Bed_Avg; 
		
quit;

*Second Exploration Regression Analysis after cleaning data;
proc reg data= fitbit_02 outest=est_fitbit_02  PLOTS(MAXPOINTS=15000 );
     model  Activity_Calories_avg = Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg 
			Minutes_Fairly_Active_avg Minutes_Very_Active_avg /dwProb pcorr1 noint VIF selection=stepwise ALPHA=0.05; 
			OUTPUT OUT = reg_fitbit_03_OUT PREDICTED=PRCDT RESIDUAL=c_Res
			L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
			rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
			STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

/*Minutes_Asleep_Avg Minutes_Awake_Avg Number_of_Awakenings_Avg Time_in_Bed_Avg*/ 
			
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
	model Activity_Calories_avg= Weekday Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg 
		  Minutes_Fairly_Active_avg Minutes_Very_Active_avg	/ dwProb pcorr1 noint VIF selection=MAXR ALPHA=0.05; 
			OUTPUT OUT = reg_fitbit_03_OUT PREDICTED=PRCDT RESIDUAL=c_Res
			L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
			rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
			STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

run;
quit;


proc reg data=fitbit_03 utest=est;
title "Regression of steps on calorie burned"; 
model Steps_avg = Activity_Calories_avg / stb;
plot Steps_avg*Activity_Calories_avg='*' ;
run;
quit;

proc sgplot data=fitbit_02;
 title "Box Plot for distance";
 vbox Distance_avg;
run;

proc standard data=fitbit_03 MEAN=0 STD=1
 	OUT=fitbit_z;
VAR  Weekday Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg 
	Minutes_Fairly_Active_avg Minutes_Very_Active_avg;
RUN;

proc corr data=fitbit_z;
quit;

proc princomp data=fitbit_z out=pca_fitbit;
	var Weekday Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg 
	Minutes_Fairly_Active_avg Minutes_Very_Active_avg;
run;

Title1 "Proc Reg ";
Title2 "Regression Analysis of Calories" ;
proc reg data=pca_fitbit outest=est_pca_fitbit  PLOTS(MAXPOINTS=15000 );
	model Activity_Calories_avg=  prin1 prin2 prin3 prin4 prin5 prin6 prin7  / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
OUTPUT OUT = reg_fitbit_OUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

run;
quit;

/**********************************************************************************************/
proc standard data=fitbit_03 MEAN=0 STD=1
 	OUT=fitbit_y;
VAR  Calories_Burned_avg Steps_avg Distance_avg Minutes_Sedentary_avg Activity_Calories_avg Time_in_Bed_Avg;		 
RUN;

proc corr data=fitbit_y;
quit;

proc princomp data=fitbit_y out=pca_fitbit_02;
	var Calories_Burned_avg Steps_avg Distance_avg Minutes_Sedentary_avg Activity_Calories_avg Time_in_Bed_Avg;
run;

Title1 "Proc Reg ";
Title2 "Regression Analysis of Calories" ;
proc reg data=pca_fitbit_02 outest=est_pca_fitbit_02  PLOTS(MAXPOINTS=15000 );
	model Activity_Calories_avg=  prin1 prin2 prin3 prin4 prin5 prin6/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
OUTPUT OUT = reg_fitbit_OUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

run;
quit;
/**************************************************************************************************/


data fitbit_04;
    set fitbit_03;
    if (Calories_Burned_avg='') then delete;
run;

data fitbit_05;
	set fitbit_04;

	if Calories_Burned_avg < 1800 then Calories=0;
	else if Calories_Burned_avg < 2200 then Calories=1;
	else Calories=2;
run;

proc sgplot data=fitbit_05;
  title "Calories";
  histogram Calories;
  density Calories / type=kernel;
run;

data fitbit_06;
	set fitbit_03;

	if Steps_Avg < 3000 then Step=0;
	else if Steps_Avg < 6000 then Step=1;
	else Step=2;
run;

proc sgplot data=fitbit_06;
  title "Step";
  histogram Step;
  density Step / type=kernel;
run;

/******************************************************************************************/

*** Normalize the test data ***;
PROC STANDARD DATA=fitbit_03
             MEAN=0 STD=1 
             OUT=fitbit_all_01_z;
  VAR  Calories_Burned_avg Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg Minutes_Fairly_Active_avg 
		Minutes_Very_Active_avg	Minutes_Asleep_Avg Minutes_Awake_Avg Number_of_Awakenings_Avg Time_in_Bed_Avg;
RUN;



*factory Analysis on test data;
proc factor data = fitbit_all_01_z   score corr scree residuals EIGENVECTORS  fuzz=0.3 method = principal nfactors=11
			rotate=VARIMAX   outstat=fact out=factout_all;
var Calories_Burned_avg Steps_avg Distance_avg Minutes_Sedentary_avg Minutes_Lightly_Active_avg Minutes_Fairly_Active_avg 
		Minutes_Very_Active_avg	Minutes_Asleep_Avg Minutes_Awake_Avg Number_of_Awakenings_Avg Time_in_Bed_Avg ;
run;


*sixth Exploration Regression Analysis on factors removing factor 3;
Title1 "Proc Reg for the Fitbit dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout_all outest=est_fitbit  PLOTS(MAXPOINTS=15000 );
	model Activity_Calories_avg=  factor1  factor2  factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_fitbit_OUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

run;
quit;


*New Exploration Regression Analysis on factors removing factor 3;
Title1 "Proc Reg for the Fitbit dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout_all outest=est_fitbit  PLOTS(MAXPOINTS=15000 );
	model Activity_Calories_avg=  factor1  factor2  factor4 factor5 factor6 factor7 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

run;
quit;
