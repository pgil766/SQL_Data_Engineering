/*
Question: What are the top 10 most demanded skills for data engineers in Colombia?
-Identifiy the top 10 in-demand skills for data engineers
-Focus on job postings from Colombia
because i want to see which are the top skills that are being requested for data engineering positions in my country
*/  

SELECT
    sd.skills,
    COUNT(sjd.skill_id) as skill_count
FROM job_postings_fact as jpf
INNER JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'Colombia'
GROUP BY sd.skills
ORDER BY skill_count DESC
LIMIT 10;

/*
Here are the top 10 most demanded skills for data engineers in Colombia based on job postings:

┌────────────┬─────────────┐
│   skills   │ skill_count │
│  varchar   │    int64    │
├────────────┼─────────────┤
│ sql        │       29221 │
│ python     │       28776 │
│ aws        │       17823 │
│ azure      │       14143 │
│ spark      │       12799 │
│ airflow    │        9996 │
│ snowflake  │        8639 │
│ databricks │        8183 │
│ java       │        7267 │
│ gcp        │        6446 │
└────────────┴─────────────┘

The results show that SQL and Python are the most in-demand skills,
followed by cloud technologies and data engineering tools. Overall, 
the data highlights the importance of combining programming, database management,
and cloud computing skills to meet the demands of the data engineering job market.

*/



