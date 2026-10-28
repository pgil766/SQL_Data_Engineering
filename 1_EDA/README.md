# SQL Data Engineering Projects

SQL work exploring the data engineering job market: what skills employers want, which ones pay best, and which give the best mix of the two. The queries run on a job postings dataset arranged as a star schema and are written for **DuckDB**.

## Repository Structure

```
SQL_Data_Engineering_Projects/
├── images/                         # Diagrams used in this README
├── 1_EDA/                          # Exploratory data analysis project
│   ├── 01_top_demanded_skills.sql  # Most in-demand skills
│   ├── 02_top_paying_skills.sql    # Highest-paying skills
│   └── 03_optimal_skills.sql       # Skills that balance demand and salary
└── Lessons/                        # Practice queries from the course
    ├── 1.9/   1.9_vscode_intro.sql
    ├── 1.10/  1.10_Data_Modeling.sql
    └── 1.11/  1.11_JOINS.sql
```

## Data Model

The dataset is a star schema built around a fact table of job postings:

| Table               | Type      | Description                                                        |
|---------------------|-----------|--------------------------------------------------------------------|
| `job_postings_fact` | Fact      | One row per job posting (title, salary, remote flag, company, etc.) |
| `skills_job_dim`    | Bridge    | Links job postings to the skills they ask for (many-to-many)      |
| `skills_dim`        | Dimension | Skill names                                                        |
| `company_dim`       | Dimension | Company details                                                    |

![Data Warehouse schema](../images/1_2_Data_Warehouse.png)

## Exploratory Data Analysis (`1_EDA/`)

All three analyses only look at **remote** (`job_work_from_home = TRUE`) **Data Engineer** postings.

### 1. Most In-Demand Skills — [`01_top_demanded_skills.sql`](01_top_demanded_skills.sql)

Counts how many postings mention each skill and returns the top 10.

| Rank | Skill      | Postings |
|------|------------|---------:|
| 1    | SQL        | 29,221   |
| 2    | Python     | 28,776   |
| 3    | AWS        | 17,823   |
| 4    | Azure      | 14,143   |
| 5    | Spark      | 12,799   |
| 6    | Airflow    | 9,996    |
| 7    | Snowflake  | 8,639    |
| 8    | Databricks | 8,183    |
| 9    | Java       | 7,267    |
| 10   | GCP        | 6,446    |

**Takeaway:** SQL and Python lead by a wide margin, followed by cloud platforms (AWS, Azure, GCP) and data tooling (Spark, Airflow, Snowflake, Databricks).

### 2. Highest-Paying Skills — [`02_top_paying_skills.sql`](02_top_paying_skills.sql)

Finds the **median** annual salary for each skill. The median is used instead of the average so outlier salaries have less effect. Only skills with more than 100 postings are kept.

| Skill      | Median Salary | Postings |
|------------|--------------:|---------:|
| Rust       | $210,000      | 232      |
| Terraform  | $184,000      | 3,248    |
| Golang     | $184,000      | 912      |
| Spring     | $175,500      | 364      |
| Neo4j      | $170,000      | 277      |
| GDPR       | $169,600      | 582      |
| GraphQL    | $167,500      | 445      |
| Kubernetes | $150,500      | 4,202    |
| Airflow    | $150,000      | 9,996    |

**Takeaway:** Rust has the highest median salary but fairly few postings. Terraform pays well and is also widely requested. Airflow and Kubernetes are both in high demand and pay competitively.

### 3. Optimal Skills (Demand × Salary) — [`03_optimal_skills.sql`](03_optimal_skills.sql)

Ranks skills with a score that combines demand and median salary. Only postings with a stated annual salary are included. Two scoring methods are compared:

**Option 1: Linear score**

```
optimal_score = demand_count * salary_median
```

Demand counts vary much more than salaries do, so the most common skills dominate this ranking: Python, SQL, AWS, Spark, Azure, and so on.

**Option 2: Log-scaled score**

```
optimal_score = (salary_median * LN(demand_count)) / 1,000,000
```

Taking the natural log of demand shrinks the gaps between very common and less common skills, which gives salary more weight.

| Rank | Skill     | Median Salary | ln(Demand) | Score |
|------|-----------|--------------:|-----------:|------:|
| 1    | Terraform | $184,000      | 5.3        | 0.97  |
| 2    | Python    | $135,000      | 7.0        | 0.95  |
| 3    | SQL       | $130,000      | 7.0        | 0.91  |
| 4    | AWS       | $137,320      | 6.7        | 0.91  |
| 5    | Airflow   | $150,000      | 6.0        | 0.89  |
| 6    | Spark     | $140,000      | 6.2        | 0.87  |
| 7    | Snowflake | $135,500      | 6.1        | 0.82  |
| 8    | Kafka     | $145,000      | 5.7        | 0.82  |
| 9    | Azure     | $128,000      | 6.2        | 0.79  |
| 10   | Java      | $135,000      | 5.7        | 0.77  |

**Takeaway:** The log-scaled ranking balances the two factors better. Terraform comes out on top because it pairs a high salary with solid demand. Python and SQL stay near the top on demand alone, and Airflow and AWS balance both well. This is a custom metric, so the ranking depends on the formula chosen.

## Key Findings

1. **SQL and Python are the foundation.** They are the most requested skills by far and still rank near the top once salary is factored in.
2. **Cloud skills are essential.** AWS, Azure, and GCP appear in every ranking.
3. **Infrastructure-as-code pays.** Terraform has the best combined demand and salary score.
4. **Orchestration and streaming matter.** Airflow, Spark, and Kafka offer both demand and above-average pay.

## SQL Concepts Used

- `INNER JOIN` / `LEFT JOIN` across fact, bridge, and dimension tables
- Aggregations: `COUNT`, `MEDIAN`
- `GROUP BY` with `HAVING` filters
- Math functions: `LN`, `ROUND`
- Table aliases, `ORDER BY`, `LIMIT`


```
