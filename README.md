# ACCESS-TO-WATER-
# The project will contain 4 parts(A,B,C,D)
# Begining our data-driven journey in our majindogo(fiction country)
- Clustering data to unveil Maji ndogo's water crisis

![mj1](https://github.com/ngangawairimu/Access-to-water-Part-A/assets/140246805/80d1e8ae-30ae-4adb-ade8-ddd2238bcf19)


### Project Overview
#### Maijndogo is a nation in Africa where once it was a beacon of hope and a thriving community, buzzing around fertile land and abundance of clean water . Today the picture is different a terrible drought made clean water a luxury, every day is a struggle people queue for hours in vain  the most basic  water  is no longer available.The legacy of mismanagement and corruption by government officials led  its water infrastructure to ruin. My first mission is clear, restore the flow of water in Majindogo using data-driven decisions.In this project, we’ll investigate access to safe and affordable drinking water focusing on inequalities in service levels between different countries and regions.
![mj2](https://github.com/ngangawairimu/Access-to-water-Part-A/assets/140246805/01f3ee62-62e8-4e5e-a8b2-ade5212e1411)


#### In this project volume 1
- I'm going to explore  a realistic database with SQL, I will use SQL to clean and explore data 60,000 unique records
- I will harness the power of SQL Functions, Including including intricate window functions, to draw insights from the data.
- Aggregate data to unravel the scale of the problem, and start to form some actionable insights.

## Data source
- The Sustainable Development Goals (SDGs) are an ongoing global call to action to end poverty, ensure prosperity and peace for all people, and protect our planet.

- There are 17 goals relating to poverty, health, education, basic services, inequality, climate, peace, and partnership.
    -    Goal 6: Clean water and sanitation
Ensure availability and sustainable management of water and sanitation for all.
- Due to changes in our climate, droughts are becoming more prevalent and water supplies are decreasing worldwide. This not only affects access to drinking water but also sanitation and hygiene which often results in unnecessary diseases and death.
##### datasource - WHO/UNICEF Joint Monitoring Programme for water supply, sanitation, and hygiene (JMP)).
### Tools
- SQL - Data analysis
- SQL - Data Cleaning
          -The emails for our department are easy: first_name.last_name@ndogowater.gov.
            - selecting the employee_name column - replacing the space with a full stop - making it
                    lowercase - and stitching it all together
We then use CONCAT() to add the rest of the email address: SELECT CONCAT(
LOWER(REPLACE(employee_name, &#39; &#39;, &#39;.&#39;)), &#39;@ndogowater.gov&#39;) AS new_email
−− add it all together FROM the employee

UPDATE employee SET email = CONCAT(LOWER(REPLACE(employee_name, &#39; &#39;, &#39;.&#39;)),
&#39;@ndogowater.gov&#39;)

  ## Results and finding
Water Accessibility and Infrastructure Summary Report
This survey aimed to identify the water sources people use and determine both the total and
average number of users for each source. Additionally, it examined the duration citizens typically
spend in queues to access water.
## Insights
    1. Most water sources are rural.
    2. 18% of our people are using wells of which, but within that, only 28% are clean. These
        are mostly in Hawassa, Kilimani and Akatsi.
    3. 43% of our people are using shared taps. 2000 people often share one tap.
    4. 31% of our population has water infrastructure in their homes, but within that group,
        45% face non-functional systems due to issues with pipes, pumps, and reservoirs.
    5. 45% face non-functional systems due to issues with pipes, pumps, and reservoirs. Towns
        like Amina, the rural parts of Amanzi, and a couple of towns across Akatsi and Hawassa
        have broken infrastructure.
    6. Our citizens often face long wait times for water, averaging more than 120 minutes.
    7. In terms of queues:

            - Queues are very long on Saturdays.
            - Queues are longer in the mornings and evenings.
            - Wednesdays and Sundays have the shortest queues.

## Recommendations
1. We want to focus our efforts on improving the water sources that affect the most people.
        - Most people will benefit if we improve the shared taps first.
        - Wells are a good source of water, but many are contaminated. Fixing this will benefit a
        lot of people.
        - Fixing existing infrastructure will help many people. If they have running water again,
        they won&#39;t have to queue, thereby shorting queue times for
        others. So, we can solve two problems at once.
        - Installing taps in homes will stretch our resources too thin, so for now, if the queue
        times are low, we won&#39;t improve that source.
2. Most water sources are in rural areas. We need to ensure our teams know this as this
means they will have to make these repairs/upgrades in rural areas where road
conditions, supplies, and labor are harder challenges to overcome.
