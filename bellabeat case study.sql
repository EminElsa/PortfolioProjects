select * from daily_activity  
select * from sleep_day  
select * from heart_rate
select * from sleep_day 
select * from weight_log
select * from minutesleep

select * from hourlyintensities
select * from hourlycalories





--- find Average Heart rate---
select id,avg(value) as Average_heart_rate from heart_rate
group by id order by Average_heart_rate

---find average hour of sleep---
select Id,round(avg(cast(TotalHoursAsleep  as float)),2) as average_sleep from  sleep_day
 where Id!=' ' group by Id order by Id

 --- Find the average calories burnt from each person[dbo].[hourlySteps_merged]
 select Id,round(avg(Calories),2) as cal from daily_activity
 group by id order by cal desc

 ---fing average weight,BMI fro weight log---
 select Id,round(avg(WeightKg),2)as Weight_Kg ,round(avg(BMI),2)as BMI from weight_log
 group by Id 

 --- Find out the weight drop ----
 select Id,round(max(BMI)-Min(BMI),2) as Weigt_drop from weight_log
 group by Id order by Weigt_drop desc


 ---Join all 3 tables to find the trend---
 select daily_activity.Id,round(avg(Calories),2) as calories_burnt,round(avg(cast(TotalHoursAsleep  as float)),2) as avaerge_hour_of_sleep 
 from daily_activity  inner join sleep_day on daily_activity.Id=sleep_day.Id group by daily_activity.Id order by calories_burnt desc

 ---find out realtion between daily activities and weight log---

 select daily_activity.Id,round(avg(Calories),2)as cal,round(max(BMI)-Min(BMI),2)as BMI,round(avg(SedentaryHours),2)as Not_active_time
--- ,round(avg(cast(TotalHoursAsleep  as float)),2) as average_sleep---
 from daily_activity inner  join weight_log  on daily_activity.Id=weight_log.Id ---inner join sleep_day on daily_activity.Id=sleep_day.Id---
 Group by daily_activity.Id order by cal desc

 ---find out relation between active distance and calories---

 with Cal_activedistance (Id,Cal,Very_active_distance)
 as
 (
 select Id,round(avg(Calories),2)as Cal,round(avg(VeryActiveDistance),2)as Very_active_distance from daily_activity
 group by Id 
 )

 select * from  Cal_activedistance


 ---Temp Table

 Create Table Cal_activedistance
 (
  Id numeric,
  Cal float,
  Very_active_distance float
  )

  insert into Cal_activedistance
   select Id,round(avg(Calories),2)as Cal,round(avg(VeryActiveDistance),2)as Very_active_distance from daily_activity
 group by Id 

 select * from  Cal_activedistance

 ---Find out sleeping pattern from Sleep day 
 select sub.Id,round(Avg(sub.TotalHoursAsleep),2)as Average_sleep,sub.part_of_week
 from
 (select Id,Cast(TotalHoursAsleep as float) as TotalHoursAsleep ,Cast([TotalHoursIn Bed] as float) as TotalHoursIn_Bed,
 Datename(weekday,SleepDay)as [day],
 case when Datename(weekday,SleepDay)='Sunday' then 'WeekEnd'
      When Datename(weekday,Sleepday)='Saturday' then 'WeekEnd'
	  else 'Weekday' end as part_of_week
 from sleep_day) as sub
 group by sub.Id,sub.part_of_week
 order by 1,2 desc

 --find out the people who is sleeping more than 7 hours
 select Id,round(Avg(Cast(TotalHoursAsleep as float)),2) as AverageHoursAsleep from sleep_day
 group by Id order by 2 desc

 --Find out Relation between sleep and calories

 select daily_activity.Id ,round(Avg(Calories),2) as Calories,round(Avg(Cast(TotalHoursAsleep as float)),2) as AverageHoursAsleep,
 round(avg(TotalDistance),2) as Avg_distance,round(avg(TotalSteps),2) as Avg_steps 
 from daily_activity inner join sleep_day
 on daily_activity.Id=sleep_day.Id
 group by daily_activity.Id 
 Having round(Avg(Cast(TotalHoursAsleep as float)),2)<6
 order by 2 desc

  select daily_activity.Id ,round(Avg(Calories),2) as Calories,round(Avg(Cast(TotalHoursAsleep as float)),2) as AverageHoursAsleep,
 round(avg(TotalDistance),2) as Avg_distance,round(avg(TotalSteps),2) as Avg_steps 
 from daily_activity inner join sleep_day
 on daily_activity.Id=sleep_day.Id
 group by daily_activity.Id 
 Having round(Avg(Cast(TotalHoursAsleep as float)),2)>=6
 order by 2 desc

 --Find out Sleep and ActiveMinutes
 --Minimum hours of  sleep 

 select sub.Id,sub.SleepDay,Datename(weekday,SleepDay)as [day],cast(TotalHoursAsleep as float) as hour_of_sleep,daily_activity.Calories,
 daily_activity.TotalDistance as total_distance,daily_activity.VeryActiveMinutes as active_miuntes, 
 daily_activity.FairlyActiveMinutes as fairly_active_miuntes,daily_activity.SedentaryHours
 from
 (select * from sleep_day where cast(TotalHoursAsleep as float) in (select min(cast(TotalHoursAsleep as float)) from sleep_day group by Id)
 and Id IN (select distinct(Id) from sleep_day where cast(TotalHoursAsleep as float) in(select min(cast(TotalHoursAsleep as float)) from sleep_day group by Id))) as sub
 inner join daily_activity on sub.Id=daily_activity.Id where sub.SleepDay=daily_activity.ActivityDate
 order by Id
 ---Maximunm hours of sleep  sleep

  select sub.Id,sub.SleepDay,Datename(weekday,SleepDay)as [day],cast(TotalHoursAsleep as float) as hour_of_sleep,daily_activity.Calories,
 daily_activity.TotalDistance as total_distance,daily_activity.VeryActiveMinutes as active_miuntes, 
 daily_activity.FairlyActiveMinutes as fairly_active_miuntes,daily_activity.SedentaryHours
 from
 (select * from sleep_day where cast(TotalHoursAsleep as float) in (select max(cast(TotalHoursAsleep as float)) from sleep_day group by Id)
 and Id IN (select distinct(Id) from sleep_day where cast(TotalHoursAsleep as float) in(select max(cast(TotalHoursAsleep as float)) from sleep_day group by Id))) as sub
 inner join daily_activity on sub.Id=daily_activity.Id where sub.SleepDay=daily_activity.ActivityDate
 order by Id 

 ---Findout the sleeping pattern as days go and productivitysleep_day
  select sleep_day.Id,sleep_day.SleepDay,Datename(weekday,SleepDay)as [day],cast(TotalHoursAsleep as float) as hour_of_sleep,daily_activity.Calories,
 daily_activity.TotalDistance as total_distance,daily_activity.VeryActiveMinutes as active_miuntes, 
 daily_activity.FairlyActiveMinutes as fairly_active_miuntes
  from sleep_day
  inner join daily_activity on sleep_day.Id=daily_activity.Id where sleep_day.Id='8792009665' and sleep_day.SleepDay=daily_activity.ActivityDate
  order by hour_of_sleep desc

  select distinct(Id) from sleep_day where cast(TotalHoursAsleep as float) in(select max(cast(TotalHoursAsleep as float)) from sleep_day group by Id)

  ----most of them follow their daily routine but if there is any change that affect their productivity
  --- people have less sleep more sedentary hours



  ---find out realtion between weight and calories
  ---I assume that people stick with the workout schedule throughout 2 month
 
   Create  View  new_weight_log 
	as
	(
	select Id,Max(WeightKg)as Max_Weight,Min(weightKg)as Min_weight from weight_log group by Id
	)

	 With new_active_calories (id,Calories)
	as
	(
     select Id,round(Avg(daily_activity.Calories),2) as Calories from daily_activity
	group by Id
	)
 
	select new_active_calories.Id,new_active_calories.Calories,new_weight_log.Max_Weight,new_weight_log.Min_weight
	from new_active_calories inner join new_weight_log
	on new_active_calories.Id=new_weight_log.Id
	order By Calories

	---Find out average minute sleep

	select Id ,DATEDIFF(MI,Min([date]),Max([date])) as date1 from minutesleep group by Id,[date]
	select Id,Min([date]),Max([date]) from minutesleep group  by [date],Id


	-----Find out average minute sleep


	---Find the user type
	Create View New2
	as (

	select Avg(Calories)as calories ,Avg(TotalSteps) as totalstep,Avg(TotalDistance)as distance,
	case when Avg(TotalSteps)>10000 then 'Very Active'
	     when Avg(TotalSteps)<10000 and Avg(TotalSteps)>=8000 then 'Lightly Active'
		 when avg(TotalSteps)<8000 and  Avg(TotalSteps)>=4000 then 'Fairly Active'
		 else 'Sedentary Active' end as [Level]
    from daily_activity 
	
	group by Id
	)

select [level] as [level],count([level])as [count] ,Avg(totalstep)as total_step from New2
group by [level]


 /*Create Table Cal_activedistance
 (
  Id numeric,
  Cal float,
  Very_active_distance float
  )

  insert into Cal_activedistance
   select Id,round(avg(Calories),2)as Cal,round(avg(VeryActiveDistance),2)as Very_active_distance from daily_activity
 group by Id8*/
 

 Create Table usertype1
 (
 [level] varchar(50),
 [count] int,
 total_step int
 )

 insert into usertype1
 select [level] as [level],count([level])as [count] ,Avg(totalstep)as total_step from New2
group by [level]