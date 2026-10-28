/*
Question: What are the most optimal skills for Data Engineers, balancing both demand and salary?

- Create a ranking column that combines skill demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.

Why?
- This approach highlights skills that balance market demand and financial reward.
- It prioritizes in-demand skills with competitive salaries rather than allowing rare, high-paying skills to distort the results.
*/


/*
Option 1: Calculate an optimal score by multiplying skill demand by median salary.

Formula:
optimal_score = demand_count * salary_median

Observation:
This approach prioritizes skills with higher demand because demand_count varies significantly across skills.
As a result, highly frequent skills such as Python and SQL rank above less common skills, even when those less common skills offer higher median salaries.

*/

SELECT
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS salary_median,
    ROUND(COUNT(jpf.*),1) AS demand_count,
    COUNT(jpf.*) * MEDIAN(jpf.salary_year_avg) AS optimal_score
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    job_work_from_home = TRUE
    AND jpf.job_title_short = 'Data Engineer'
    AND jpf.salary_year_avg IS NOT NULL
GROUP BY sd.skills
HAVING
    COUNT(sd.skill_id)>100
ORDER BY 
    optimal_score DESC
LIMIT 10;

/*

┌────────────┬───────────────┬──────────────┬─────────────────┐
│   skills   │ salary_median │ demand_count │  optimal_score  │
│  varchar   │    double     │    int64     │     double      │
├────────────┼───────────────┼──────────────┼─────────────────┤
│ python     │      135000.0 │         1133 │     152955000.0 │
│ sql        │      130000.0 │         1128 │     146640000.0 │
│ aws        │      137320.0 │          783 │  107521804.6875 │
│ spark      │      140000.0 │          503 │      70420000.0 │
│ azure      │      128000.0 │          475 │      60800000.0 │
│ snowflake  │      135500.0 │          438 │      59349000.0 │
│ airflow    │      150000.0 │          386 │      57900000.0 │
│ kafka      │      145000.0 │          292 │      42340000.0 │
│ java       │      135000.0 │          303 │      40905000.0 │
│ redshift   │      130000.0 │          274 │      35620000.0 │
└────────────┴───────────────┴──────────────┴─────────────────┘

Observation:
This approach prioritizes skills with higher demand because demand_count varies significantly across skills.
As a result, highly frequent skills such as Python and SQL rank above less common skills, 
even when those less common skills offer higher median salaries.

*/

/*
Option 2: Apply a logarithmic transformation to demand before combining it with median salary.

Formula:
optimal_score = (salary_median * LN(demand_count)) / 1,000,000

*/

SELECT
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS salary_median,
    ROUND(LN(COUNT(jpf.*)),1) AS ln_demand_count,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.*)))/1_000_000,2) AS optimal_score
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    job_work_from_home = TRUE
    AND jpf.job_title_short = 'Data Engineer'
    AND jpf.salary_year_avg IS NOT NULL
GROUP BY sd.skills
HAVING
    COUNT(sd.skill_id)>100
ORDER BY 
    optimal_score DESC
LIMIT 25;

/*
┌────────────┬───────────────┬─────────────────┬───────────────┐
│   skills   │ salary_median │ ln_demand_count │ optimal_score │
│  varchar   │    double     │     double      │    double     │
├────────────┼───────────────┼─────────────────┼───────────────┤
│ terraform  │      184000.0 │             5.3 │          0.97 │
│ python     │      135000.0 │             7.0 │          0.95 │
│ sql        │      130000.0 │             7.0 │          0.91 │
│ aws        │      137320.0 │             6.7 │          0.91 │
│ airflow    │      150000.0 │             6.0 │          0.89 │
│ spark      │      140000.0 │             6.2 │          0.87 │
│ snowflake  │      135500.0 │             6.1 │          0.82 │
│ kafka      │      145000.0 │             5.7 │          0.82 │
│ azure      │      128000.0 │             6.2 │          0.79 │
│ java       │      135000.0 │             5.7 │          0.77 │
│ scala      │      137290.0 │             5.5 │          0.76 │
│ kubernetes │      150500.0 │             5.0 │          0.75 │
│ git        │      140000.0 │             5.3 │          0.75 │
│ databricks │      132750.0 │             5.6 │          0.74 │
│ redshift   │      130000.0 │             5.6 │          0.73 │
│ gcp        │      136000.0 │             5.3 │          0.72 │
│ nosql      │      134415.0 │             5.3 │          0.71 │
│ hadoop     │      135000.0 │             5.3 │          0.71 │
│ pyspark    │      140000.0 │             5.0 │           0.7 │
│ mongodb    │      135750.0 │             4.9 │          0.67 │
│ docker     │      135000.0 │             5.0 │          0.67 │
│ r          │      134775.0 │             4.9 │          0.66 │
│ go         │      140000.0 │             4.7 │          0.66 │
│ bigquery   │      135000.0 │             4.8 │          0.65 │
│ github     │      135000.0 │             4.8 │          0.65 │
└────────────┴───────────────┴─────────────────┴───────────────┘

Observation:
Using the natural logarithm reduces the impact of large differences in skill demand. Unlike Option 1, 
which strongly favors the most frequent skills, 
this approach gives greater consideration to skills with higher median salaries while still accounting for market demand.

Results:
Terraform ranks first because it combines a high median salary ($184,000) with meaningful demand. 
Python and SQL remain highly ranked due to their strong demand, 
while Airflow and AWS also perform well by balancing competitive salaries with frequent job postings.

Conclusion:
The logarithmic approach provides a more balanced ranking between salary and demand, 
reducing the dominance of highly frequent skills. However, 
the score is a custom metric rather than a standardized measure of skill value, 
and its ranking depends on the chosen formula.

