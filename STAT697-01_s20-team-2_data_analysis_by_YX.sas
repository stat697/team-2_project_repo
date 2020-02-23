*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* load external file that will generate final analytic file */
%include "./STAT697-01_s20-team-2_data_preparation.sas";


*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 3: What are the top ten counties that have the highest 
average Estimated FTE? 

Rationale: This would help identify counties with high level of average 
Estimated FTE.

Note: This needs to get the average of the column 'EstimatedFTE' for all the 
observation units with the same input on the column 'CountyName' from 
StaffAssign16.

Limitations: Missing and incomplete data are omitted. And the results of 
different counties could be of little difference. 
*/


proc sql;
    create table q1 as
        select
            AvgEstimatedFTE
            ,COUNTY
        from
            analytic_file_raw_checked
        order by 
            AvgEstimatedFTE desc
        ;
quit;

proc sql outobs=10;
    select 
        *
    from
        q1
    ;
quit;

proc sgplot data=q1;
    hbox AvgEstimatedFTE / category=COUNTY;
run;
    
    
*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: What are the top ten counties that have the highest percentage
of graduates meeting UC/CSU entrance requirement out of all the students
enrolled into Grade twelve? 

Rationale: This would help identify counties with high percentage of students 
meeting UC/CSU requirements.

Note: This needs to find out observation units with column 'GR_12' not equal to 
zero in the dataset enr16, and divide their number of Grade twelve enrollments 
by the value of column 'TOTAL' of the observation units with the same SchoolCode 
in the dataset gradaf17, then get the average of these results from observation 
units with the same name of county.

Limitations: Missing and incomplete data are omitted. And the 'Total' column in
the gradaf17 dataset might not be best possible denonminator of the ratio as it
does not include students with high school equivalencies. And the results from
different counties could be of little difference. 
*/


proc sql;
    create table q2 as
        select
            Avg_Rate_of_Univ
            ,COUNTY
        from
            analytic_file_raw_checked
        order by 
            Avg_Rate_of_Univ desc
        ;
quit;

proc sql outobs=10;
    select 
        *
    from
        q2
    ;
quit;

proc sgplot data=q2;
    hbox Avg_Rate_of_Univ / category=COUNTY;
run;

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Is there any relationship between the two variables 
respectively explored by the above two questions?

Rationale: This would help inform whether the level of average Estimated FTE is 
associated with the percentage of students meeting university requirements.

Note: This needs to obtain the correlation of the two variables explored above.

Limitations: The comparison between the rankings produced by the previous two
questions could be preliminary. And the overlaps on the two rankings could be 
caused by other confounding factors.
*/


proc sql;
    create table q3 as
        select
            Avg_Rate_of_Univ
            ,q2.COUNTY
            ,AvgEstimatedFTE
        from
            q1
            ,q2
        where
            q1.COUNTY = q2.COUNTY
        ;
quit;

proc corr data=q3 noprob nosimple PEARSON SPEARMAN;
   var AvgEstimatedFTE Avg_Rate_of_Univ;
run;

proc sgplot data=q3;
    scatter x=AvgEstimatedFTE y=Avg_Rate_of_Univ;
    ellipse x=AvgEstimatedFTE y=Avg_Rate_of_Univ;
run;
