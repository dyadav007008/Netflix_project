--Netflix Project
DROP table if exists netflix;
create table netflix
(
	show_id	VARCHAR(6),
	type	VARCHAR(10),	
	title	varchar(150),
	director	varchar(208),
	casts	varchar(1000),
	country	varchar(150),
	date_added	varchar(50),
	release_year	INT,
	rating	varchar(10),
	duration	varchar(15),
	listed_in	varchar(250),
	description varchar(258)
);

select * from netflix;

--To get the total count of rows
select 
		count(*) as total_content
from netflix;


-- To check how many type are available

select 
		distinct type 
from netflix;


--Q1 Count the number of movies vs tv shows
SELECT 
	type,count(*) 
	from netflix
	group by type;

--Q2 Find the most common rating for movies and tv shows

--Using CTE:

with a as (
select type,rating,count(*) from netflix where type = 'Movie' group by type,rating order by count(*) desc limit 1
),
b as (select type,rating,count(*) from netflix where type = 'TV Show' group by type,rating order by count(*) desc limit 1
)
select * from a
union 
select * from b


--------------------------------------------------------------------------------------

--Using window_function:

select type,rating,count from (
select type,rating,count(*) as count,
row_number() over (partition by type order by count(*) desc) as rn from netflix
WHERE type IN ('Movie', 'TV Show')
GROUP BY type, rating) as common_rating
where rn = 1;


--Q3  List all movies in a specific year	
select 
	*
from netflix 
where release_year = 2020 
and type = 'Movie';

--Q4 Top 5 countries with the most content on netflix

--Using Subqueries
select countries,count(*) from (
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS countries from netflix)
group by countries
order by count(*) desc
limit 5;

------------------------------------------------------------------
-- direct

select unnest(string_to_array(country,','))  as countries,
	count(show_id) from netflix
	group by countries
	order by 2 desc
	limit 5;


--Q5 Identify the longest movie or TV Show duration

select type,
max(cast((string_to_array(duration,' '))[1] AS INTEGER))  as time from netflix
group by type;

--Q6 Find content added in the last 5 year

SELECT *
FROM netflix
WHERE CAST(date_added AS DATE) >= (CURRENT_DATE - INTERVAL '5 years');

-----------------------------------------------------------------------------------

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


--Q7 Find All Movies/TV Shows by Director 'Rajiv Chilaka'


--Using CTE
with a as (
select * , unnest(string_to_array(Director,',')) as directors
	from netflix
)
select * 
from a
where directors = 'Rajiv Chilaka';

----------------------------------------------------------------------------
--Using Like Operator

select * from netflix
where director like '%Rajiv Chilaka%';

----------------------------------------------------------------------------
--Using Regular Expression

select * from netflix
where director ~ '.*Rajiv Chilaka.*';


--Q8 List All TV Shows with More Than 5 Seasons

select * from netflix 
where type = 'TV Show'
and cast((string_to_array(duration,' '))[1] as integer) >5;

----------------------------------------------------------------------------------

select *
from netflix
where type = 'TV Show'
and cast(split_part(duration,' ',1) as integer) > 5;


--Q9 Count the Number of Content Items in Each Genre

select trim(unnest(String_to_array(listed_in,','))) as genre,count(show_id)
from netflix
group by 1;

--Q10 Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--Q11 List All Movies that are Documentaries

select *
from netflix
where listed_in like '%Documentaries%'
and type = 'Movie';

--Q12 Find All Content Without a Director

select * from netflix where director is null;

--Q13 Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select *
from netflix
where type = 'Movie'
and casts like '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


--Q14 Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select trim(unnest(string_to_array(casts,','))),count(show_id) from netflix
where country like '%India%'
group by 1
order by 2 desc
limit 10;

------------------------------------------------------------------------------------
--Window Function

select * from (
select trim(unnest(string_to_array(casts,','))) as actors,count(show_id) as overall_count,
rank() over (ORDER BY COUNT(show_id) DESC) as rn
from netflix
where country like '%India%'
group by 1)
where rn <11;

--Q15 Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
--Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

