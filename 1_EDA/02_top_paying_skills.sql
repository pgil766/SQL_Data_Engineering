/*
Question: What are the highest paying skills for data engineers?
-Calculate the median salary for each skill required in data engineer positions
-Focus on remote positions with specified salaries
-Include skill frecuency to identify both salary and demand
why?
-because it will help to identify which skills are not only in demand but also offer higher compensation
 but also showing how common those skills are.

-The median is used instead of the average to reduce the impacto of outliers salaries.
*/

SELECT
    sd.skills,
    MEDIAN(jpf.salary_year_avg) AS salary_median,
    COUNT(jpf.*) AS demand_count
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_work_from_home = TRUE 
    AND jpf.job_title_short = 'Data Engineer'
GROUP BY sd.skills
HAVING 
    COUNT(jpf.*) > 100
ORDER BY 
    salary_median DESC
LIMIT 25;

/*
Conclusions of the highest-paying skills for Data Engineers:

- Rust remains the top-paying skill at $210K median salary, though demand is still relatively limited (232 postings).
- Terraform and Golang both have high median salaries at $184K, with strong demand (Terraform: 3,248 postings; Golang: 912 postings).
- Other notable skills with both high pay and moderate-to-high frequency include:
    - Spring: $175.5K median salary (364 postings)
    - Neo4j: $170K median salary (277 postings)
    - GDPR: $169.6K median salary (582 postings)
    - GraphQL: $167.5K median salary (445 postings)
    - Kubernetes: $150.5K median salary (4,202 postings)
    - Airflow: $150K median salary (9,996 postings)
- Bitbucket, Ruby, Redis, Ansible, and Jupyter also appear in the top 25 for pay, each with hundreds of postings.
- Most skills on the list have more than just a handful of postings, making the salary estimates more informative, although sample sizes still vary.

Takeaway:
While Rust offers the highest median salary, it has less demand than major cloud and data engineering tools. 
Terraform stands out for combining high pay with substantial demand, while Airflow and Kubernetes are widely requested skills with competitive median salaries.
*/
