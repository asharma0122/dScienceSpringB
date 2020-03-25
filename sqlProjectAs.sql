--Some of the facilities charge a fee to members, but some do not.
--Q1: Please list the names of the facilities that do.
select name from country_club.facilities 
where membercost!='0.0';

--Q2: how many facilities do not charge a fee to members?
select count(1) from country_club.facilities
where membercost='0.0';

-- Q3: How can you produce a list of facilities that charge a fee to members,
-- where the fee is less than 20% of the facility's monthly maintenance cost?
-- Return the facid, facility name, member cost, and monthly maintenance of the
-- facilities in question. 
select * from country_club.facilities 
where membercost < (monthlymaintenance*0.2);

-- Q4: How can you retrieve the details of facilities with ID 1 and 5?
-- Write the query without using the OR operator.
select * from country_club.facilities 
where facid in (1,5);

-- Q5: How can you produce a list of facilities, with each labelled as
-- 'cheap' or 'expensive', depending on if their monthly maintenance cost is
-- more than $100? Return the name and monthly maintenance of the facilities
-- in question.
select name,monthlymaintenance, 
case 
when monthlymaintenance>100 then 
'expensive' 
else 'cheap' 
end as type 
from country_club.facilities;

-- Q6: You'd like to get the first and last name of the last member(s)
-- who signed up. Do not use the LIMIT clause for your solution.
select firstname,surname from country_club.members 
where joindate = (select max(joindate) from country_club.members);

-- Q7: How can you produce a list of all members who have used a tennis court?
-- Include in your output the name of the court, and the name of the member
-- formatted as a single column. Ensure no duplicate data, and order by
-- the member name.
select faci.name as facilityName,
concat(concat(mem.firstname,' '), mem.surname) as memberName
from country_club.bookings book 
join country_club.facilities faci on book.facid=faci.facid
join country_club.members mem on book.memid = mem.memid
where faci.name in ('Tennis Court 1','Tennis Court 2')
group by (faci.name,mem.firstname, mem.surname)
order by memberName;

-- Q8: How can you produce a list of bookings on the day of 2012-09-14 which
-- will cost the member (or guest) more than $30? Remember that guests have
-- different costs to members (the listed costs are per half-hour 'slot'), and
-- the guest user's ID is always 0. Include in your output the name of the
-- facility, the name of the member formatted as a single column, and the cost.
-- Order by descending cost, and do not use any subqueries.
select 
sum(case when book.memid = 0 then faci.guestcost else faci.membercost end) as total_cost,
concat(concat(mem.firstname,' '),mem.surname) as mem_name,
faci.name as faci_name
from country_club.bookings book 
join country_club.facilities faci on book.facid=faci.facid
join country_club.members mem on book.memid=mem.memid
where date(to_date(starttime,'YYYY-MM-DD HH24:MI:SS')::timestamp) = date('2012-09-14') 
group by (mem_name,faci_name)
having sum(case when book.memid = 0 then faci.guestcost else faci.membercost end)>30
order by total_cost desc;


-- Q9: This time, produce the same result as in Q8, but using a subquery.
select * from (select 
sum(case when book.memid = 0 then faci.guestcost else faci.membercost end) as total_cost,
concat(concat(mem.firstname,' '),mem.surname) as mem_name,
faci.name as faci_name
from country_club.bookings book 
join country_club.facilities faci on book.facid=faci.facid
join country_club.members mem on book.memid=mem.memid
where date(to_date(starttime,'YYYY-MM-DD HH24:MI:SS')::timestamp) = date('2012-09-14') 
group by (mem_name,faci_name)
order by total_cost desc) x where x.total_cost>30;


-- Q10: Produce a list of facilities with a total revenue less than 1000.
-- The output of facility name and total revenue, sorted by revenue. Remember
-- that there's a different cost for guests and members!
select 
sum(case when book.memid = 0 then faci.guestcost else faci.membercost end) as revenue,
faci.name as faci_name
from country_club.bookings book 
join country_club.facilities faci on book.facid=faci.facid
join country_club.members mem on book.memid=mem.memid 
group by (faci_name)
having sum(case when book.memid = 0 then faci.guestcost else faci.membercost end) < 1000
order by revenue desc;
