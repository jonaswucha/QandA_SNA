CREATE TABLE stackoverflow.outdegree_user_u
Select count(*) as OutDegreeCentrality, a.user_u
	from(
	Select count(*)as c1, user_u, user_v
		from stackoverflow.a2q
		where user_v != user_u
		group by user_u, user_v
	)a 
	group by a.user_u;
    
CREATE TABLE stackoverflow.tiestrength
Select (a.c1) as TieStrength, a.user_u, a.user_v
from (
	Select count(*)as c1, user_u, user_v
	from stackoverflow.a2q
	where user_v != user_u
	group by user_u, user_v
) a;

CREATE TABLE stackoverflow.rezi
Select (a.c1+ b.c2 ) as Counter, a.user_u, a.user_v
from (
	Select count(*)as c1, user_u, user_v
	from stackoverflow.a2q
	where user_v != user_u
	group by user_u, user_v
) a
inner join
(	Select count(*) as c2, user_v, user_u
	from stackoverflow.a2q
 	where user_v != user_u
	group by user_v, user_u
) b
on
a.user_u = b.user_v
and a.user_v = b.user_u;

CREATE TABLE ts_with_rezi
select ts.user_u, ts.user_v, ts.tiestrength, rezi.counter
			from stackoverflow.tiestrength as ts
			left join stackoverflow.rezi as rezi
			on ts.user_u = rezi.user_u and ts.user_v = rezi.user_v;
   
CREATE TABLE ts_with_rezi_with_odc
Select tsRezi.user_u, tsRezi.user_v, tsRezi.tiestrength, tsRezi.counter, odc.outdegreecentrality
from stackoverflow.outdegree_user_u as odc
	left join 
		ts_with_rezi
		as tsRezi
	on tsRezi.user_u = odc.user_u;

CREATE TABLE stackoverflow.a2q_with_metrics
Select  original.user_u, original.user_v, original.time_t ,allinAll.outdegreecentrality, allinAll.tiestrength, allinAll.counter as rezi
from stackoverflow.a2q as original
left join 
	ts_with_rezi_with_odc
	 as allinAll
on original.user_u = allinAll.user_u and original.user_v = allinAll.user_v
where original.user_u != original.user_v
order by original.user_u, original.user_v asc;

SELECT original.user_u, AVG(original.outdegreecentrality), AVG(original.tiestrength), AVG(original.rezi), AVG(original.firstAnswer), AVG(answers.answers) as answerSum INTO OUTFILE '/Users/jonas/Downloads/A2Q_with_answerSum2_distinctUser.csv'
  FIELDS TERMINATED BY ';'
  LINES TERMINATED BY '\n'
FROM stackoverflow.a2q_final as original
LEFT JOIN
	(SELECT user_v, Count(*) as answers
	FROM stackoverflow.a2q
    GROUP BY user_v) answers
ON user_u = answers.user_v
GROUP BY user_u;
