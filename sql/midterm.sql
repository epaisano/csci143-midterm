/* PROBLEM 1:
 *
 * The Office of Foreign Assets Control (OFAC) is the portion of the US government that enforces international sanctions.
 * OFAC is conducting an investigation of the Pagila company to see if you are complying with sanctions against North Korea.
 * Current sanctions limit the amount of money that can be transferred into or out of North Korea to $5000 per year.
 * (You don't have to read the official sanctions documents, but they're available online at <https://home.treasury.gov/policy-issues/financial-sanctions/sanctions-programs-and-country-information/north-korea-sanctions>.)
 * You have been assigned to assist the OFAC auditors.
 *
 * Write a SQL query that:
 * Computes the total revenue from customers in North Korea.
 *
 * NOTE:
 * All payments in the pagila database occurred in 2022,
 * so there is no need to do a breakdown of revenue per year.
 */


select sum(amount) as "total revenue", country from 
country
join city using (country_id)
join address using (city_id)
join customer using (address_id)
join rental using (customer_id)
join payment using (rental_id)
where country = 'North Korea'
group by country;



/* PROBLEM 2:
 *
 * Management wants to hire a family-friendly actor to do a commercial,
 * and so they want to know which family-friendly actors generate the most revenue.
 *
 * Write a SQL query that:
 * Lists the first and last names of all s who have appeared in movies in the "Family" category,
 * but that have never appeared in movies in the "Horror" category.
 * For each actor, you should also list the total amount that customers have paid to rent films that the actor has been in.
 * Order the results so that actors generating the most revenue are at the top.
 */


select first_name, last_name, total_paid from 
    (select actor_id, sum(amount) as total_paid from
        (select first_name, last_name, actor_id
         from actor 
         join film_actor using (actor_id)
         join film using (film_id)
         join film_category using (film_id)
         join category using (category_id)
         where name = 'Family'

         EXCEPT

         select first_name, last_name, actor_id
         from actor 
         join film_actor using (actor_id)
         join film using (film_id)
         join film_category using (film_id)
         join category using (category_id)
         where name = 'Horror'
         ) as t
    join film_actor using (actor_id)
    join film using (film_id)
    join inventory using (film_id)
    join rental using (inventory_id)
    join payment using (rental_id)
    group_by actor_id
) as q
join actor using (actor_id)
order by total_paid desc;



/* PROBLEM 3:
 *
 * You love the acting in AGENT TRUMAN, but you hate the actor RUSSELL BACALL.
 *
 * Write a SQL query that lists all of the actors who starred in AGENT TRUMAN
 * but have never co-starred with RUSSEL BACALL in any movie.
 */


select first_name || ' ' || last_name as "Actor Name" from
        (select actor_id, first_name, last_name
        from actor
        join film_actor using (actor_id)
        join film using (film_id)
        where title = 'AGENT TRUMAN'
        ) as y
        
EXCEPT

select "Actor Name" from
        (select actor_id, first_name || ' ' || last_name as "Actor Name" from
                (select t.actor_id, actor.first_name as first_name, actor.last_name as last_name from                   (SELECT DISTINCT mc.actor_id
                   FROM film_actor mc
                   JOIN film m ON mc.film_id = m.film_id
                   JOIN film_actor mc_bacon ON m.film_id = mc_bacon.film_id
                   JOIN actor a ON mc_bacon.actor_id = a.actor_id
                   WHERE mc_bacon.actor_id = 112
                   ) as t
                join actor on t.actor_id=actor.actor_id
                ) as w
        ) as z
where "Actor Name" != 'RUSSELL BACALL';



/* PROBLEM 4:
 *
 * You want to watch a movie tonight.
 * But you're superstitious,
 * and don't want anything to do with the letter 'F'.
 * List the titles of all movies that:
 * 1) do not have the letter 'F' in their title,
 * 2) have no actors with the letter 'F' in their names (first or last),
 * 3) have never been rented by a customer with the letter 'F' in their names (first or last).
 *
 * NOTE:
 * Your results should not contain any duplicate titles.
 */


select title
from film 
where title not ilike '%f%'

intersect

select distinct film.title
from actor
join film_actor using (actor_id)
join film using (film_id)
where actor.first_name not ilike '%f%' and actor.last_name not ilike '%f%'

intersect

select distinct film.title
from customer 
join rental using (customer_id)
join inventory using (inventory_id)
join film using (film_id)
where customer.first_name not ilike '%f%' and customer.last_name not ilike '%f%';
