-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
DROP VIEW IF EXISTS lslg;
DROP VIEW IF EXISTS bin_2016;
DROP VIEW IF EXISTS bins_2016;
DROP VIEW IF EXISTS max_2000_2001;

DROP TABLE IF EXISTS binids;

-- Question 0
CREATE VIEW q0(era)
AS
  --SELECT 1 -- replace this line
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  --SELECT 1, 1, 1 -- replace this line
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  --SELECT 1, 1, 1 -- replace this line
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  --SELECT 1, 1, 1 -- replace this line
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  --SELECT 1, 1, 1 -- replace this line
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  --SELECT 1, 1, 1, 1 -- replace this line
  SELECT namefirst, namelast, playerid, yearid
  FROM people NATURAL JOIN halloffame
  WHERE halloffame.inducted = 'Y'
  ORDER BY yearid DESC, playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  --SELECT 1, 1, 1, 1, 1 -- replace this line
  SELECT namefirst, namelast, q.playerid, s.schoolid, yearid
  FROM q2i q INNER JOIN CollegePlaying c
  ON q.playerid = c.playerid
  INNER JOIN schools s
  ON c.schoolid = s.schoolid
  WHERE s.schoolState = 'CA'
  ORDER BY yearid DESC, s.schoolid, q.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  --SELECT 1, 1, 1, 1 -- replace this line
  SELECT q.playerid, namefirst, namelast, schoolid
  FROM q2i q LEFT OUTER JOIN CollegePlaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  --SELECT 1, 1, 1, 1, 1 -- replace this line
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, (H + H2B + 2 * H3B + 3 * HR + 0.0) / (AB + 0.0) AS slg
  FROM people p NATURAL JOIN batting b
  WHERE b.AB > 50
  ORDER BY slg DESC, b.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW lslg(playerid, lslgValue)
AS
  SELECT playerid, (SUM(H) + SUM(H2B) + SUM(2.0 * H3B) + SUM(3.0 * HR)) / SUM(AB)
  FROM batting
  GROUP BY playerid
  HAVING SUM(AB) > 50
;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  --SELECT 1, 1, 1, 1 -- replace this line
  SELECT playerid, namefirst, namelast, lslgValue
  FROM lslg l NATURAL JOIN people p
  ORDER BY lslgValue DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  --SELECT 1, 1, 1 -- replace this line
  SELECT namefirst, namelast, lslgValue
  FROM lslg l NATURAL JOIN people p
  WHERE l.lslgValue > (
    SELECT lslgValue
    FROM lslg
    WHERE playerid = 'mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  --SELECT 1, 1, 1, 1 -- replace this line
  SELECT yearID, min(salary), max(salary), avg(salary)
  FROM salaries
  GROUP BY yearID
  ORDER BY yearID
;

-- Question 4ii
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

CREATE VIEW bin_2016(starts, ends, width)
AS
  SELECT MIN(salary) starts, MAX(salary) ends, (MAX(salary) - MIN(salary)) / 10.0 width
  FROM salaries
  WHERE yearid = 2016
;

CREATE VIEW bins_2016(binid, starts, width)
AS
  SELECT MIN(CAST((salary - starts) / width AS INT), 9) binid, starts, width
  FROM salaries, bin_2016
  WHERE yearid = 2016
;

CREATE VIEW q4ii(binid, low, high, count)
AS
  --SELECT 1, 1, 1, 1 -- replace this line
  SELECT binid, starts + binid * width, starts + (binid + 1) * width, COUNT(*)
  FROM bins_2016
  GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  --SELECT 1, 1, 1, 1 -- replace this line
  SELECT year2.yearid, year2.min - year1.min, year2.max - year1.max, year2.avg - year1.avg
  FROM q4i year1 INNER JOIN q4i year2 ON year1.yearid + 1 = year2.yearid
  ORDER BY year1.yearid
;

-- Question 4iv
CREATE VIEW max_2000_2001(yearid, salary)
AS
  SELECT yearid, MAX(salary)
  FROM salaries
  WHERE yearid = 2000 OR yearid = 2001
  GROUP BY yearid
;

CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  --SELECT 1, 1, 1, 1, 1 -- replace this line
  SELECT p.playerid, p.namefirst, p.namelast, max.salary, max.yearid
  FROM max_2000_2001 max INNER JOIN salaries s 
  ON max.yearid = s.yearid AND max.salary = s.salary
  INNER JOIN people p
  ON s.playerid = p.playerid
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  --SELECT 1, 1 -- replace this line
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary)
  FROM allstarfull a INNER JOIN salaries s
  ON a.playerid = s.playerid AND a.yearid = s.yearid
  WHERE s.yearid = 2016
  GROUP BY a.teamid
;

