-- DATA CLEANING

select * 
from layoffs;





-- CREATING A STAGE TABLE
create table layoffs_stage
like layoffs;

INSERT layoffs_stage
select * 
from layoffs;

select * 
from layoffs_stage;

-- 1. REMOVE DUPLICATES
select *,
row_number() over( 
partition by company,industry,total_laid_off,`date`) as row_num
from layoffs_stage;

with duplicate_cte as(
select *,
row_number() over( 
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_stage
)

select *
from duplicate_cte
where row_num > 1;

select * 
from layoffs_stage
where company= "oda";


CREATE TABLE `layoffs_stage2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_stage2;

insert into layoffs_stage2
select *,
row_number() over( 
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_stage;

delete 
from layoffs_stage2
where row_num > 1;

select *
from layoffs_stage2;


-- 2. STANDARDIZE THE DATA

select company, trim(company)
from layoffs_stage2;

update layoffs_stage2
set company = trim(company);

select distinct industry
from layoffs_stage2
order by 1;

select * 
from layoffs_stage2
where industry like "Crypto%";

update layoffs_stage2
set industry = "Crypto"
where industry like "Crypto%";


select distinct location
from layoffs_stage2
order by 1;

select distinct country
from layoffs_stage2
order by 1;

select distinct country
from layoffs_stage2
where country like "United States%";

select distinct country, trim(trailing "." from country)
from layoffs_stage2;

update layoffs_stage2
set country = trim(trailing "." from country)
where country like "United States%";

select `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
from layoffs_stage2;

update layoffs_stage2
set `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

alter table layoffs_stage2
modify column `date` date;


-- 3. NULL OR BLANK VALUES AND POPULATING THE BLANKS
select * 
from layoffs_stage2
where total_laid_off is null;

update layoffs_stage2
set industry = NULL
where industry = "";

select *
from layoffs_stage2
where industry is null
or company = "";

select * 
from layoffs_stage2
where company = "Airbnb";

select * 
from layoffs_stage2
where company like "Bally%";

select t1.industry, t2.industry
from  layoffs_stage2 t1
join layoffs_stage2 t2
   on t1.company = t2.company
where(t1.industry is null or t1.industry="")
and t2.industry is not null;

update layoffs_stage2 t1
join layoffs_stage2 t2
   on t1.company = t2.company
set t1.industry = t2.industry
where(t1.industry is null)
and t2.industry is not null;


-- 4. REMOVE UNNECESSARY COLUMNS/ROWS

select * 
from layoffs_stage2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_stage2
where total_laid_off is null
and percentage_laid_off is null;

select * 
from layoffs_stage2;

alter table layoffs_stage2
drop column row_num;
 

















