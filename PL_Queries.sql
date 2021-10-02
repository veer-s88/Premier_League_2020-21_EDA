-- select the average age per club for each player who made an appearance
SELECT club, AVG(age) AS avg_age FROM prem_proj.epl_playerstats
GROUP BY club
ORDER BY avg_age;

-- create age reliance column and combine this with avg_age to compare
SELECT foo.club, foo.age_reliance, bar.avg_age 
FROM
(SELECT club, SUM(mins), SUM(mins*age) AS age_mins, CAST(SUM(mins*age) AS double precision) / SUM(mins) AS age_reliance
FROM prem_proj.epl_playerstats
GROUP BY club
ORDER BY age_reliance) AS foo
JOIN 
(SELECT club, AVG(age) AS avg_age FROM prem_proj.epl_playerstats
GROUP BY club
ORDER BY avg_age) AS bar
ON foo.club = bar.club;

-- Calculate % importance in team for Manchester United
SELECT 
	name, 
	((xg+xa) / (SELECT SUM(xg+xa) FROM prem_proj.epl_playerstats
			  WHERE club = 'Manchester United'
			   AND mins > 500)) * 100 AS imp_perc
FROM prem_proj.epl_playerstats
WHERE club = 'Manchester United'
AND mins > 500 AND position <> 'GK'
ORDER BY imp_perc DESC;

-- Check the unluckiest players, underperforming xg
SELECT 
	name, 
	goals, 
	ROUND(CAST(xg*mins/90 AS numeric),2) AS total_xg, 
	CAST(xg*(mins/90)-goals AS numeric) AS xg_g_diff
FROM prem_proj.epl_playerstats
ORDER BY xg_g_diff DESC
LIMIT 10;

-- check players overperforming xg, luckiest players
SELECT 
	name, 
	goals,
	ROUND(CAST(xg*mins/90 AS numeric),2),
	CAST(goals - xg*(mins/90) AS numeric) AS xg_g_diff
FROM prem_proj.epl_playerstats
WHERE mins > 750
ORDER BY xg_g_diff DESC
LIMIT 10;

-- top 10 goalscorers
SELECT name, goals FROM prem_proj.epl_playerstats
ORDER BY goals DESC
LIMIT 10;

-- top 10 assisters
SELECT name, assists FROM prem_proj.epl_playerstats
ORDER BY assists DESC
LIMIT 10;

-- top 10 goalscorers (no penalties)
SELECT name, goals - penalty_goals AS goals_no_penalties
FROM prem_proj.epl_playerstats
ORDER BY goals_no_penalties DESC
LIMIT 10;

-- top players with best goal to game ratio (no penalties)
SELECT 
	name, 
	ROUND(CAST(goals - penalty_goals AS numeric) / (CAST(mins AS numeric)/90),2) AS goal_ratio_no_pens
FROM prem_proj.epl_playerstats
WHERE mins > 500
ORDER BY goal_ratio_no_pens DESC
LIMIT 10;

-- top players attacking action per game ratio
SELECT
	name,
	ROUND(CAST(goals +assists - penalty_goals AS numeric) / (CAST(mins AS numeric)/90),2) AS goal_ratio_no_pens
FROM prem_proj.epl_playerstats
WHERE mins > 500
ORDER BY goal_ratio_no_pens DESC
LIMIT 10;

-- Most aggressive players
SELECT 
	name, 
	club, 
	ROUND(CAST(yellow_cards +red_cards*2 AS numeric) / (CAST(mins AS numeric)/90),2) AS aggres_score,
	mins,
	yellow_cards,
	red_cards
FROM prem_proj.epl_playerstats
WHERE mins > 500
ORDER BY aggres_score DESC
LIMIT 20;

-- most aggressive teams by by aggressiveness score
SELECT 
	club, 
	SUM(yellow_cards) + SUM(red_cards)*2 AS aggress_score, 
	SUM(yellow_cards) AS total_yellow_cards,
	SUM(red_cards) AS total_red_cards
FROM prem_proj.epl_playerstats
GROUP BY club
ORDER BY aggress_score DESC;

