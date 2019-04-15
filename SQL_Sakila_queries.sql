-- SQL exercise with Sakila Database
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name, " ", last_name)) as 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name 
from actor
where first_name = 'joe'; 

-- 2b. Find all actors whose last name contain the letters GEN:
select * 
from actor
where last_name like '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * 
from actor
where last_name like '%li%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor 
add column description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor 
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*)
from actor 
group by last_name
having count(*)>=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor 
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor set first_name='GROUCHO' WHERE first_name='HARPO' and last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address; 

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address
from staff s
join address a
on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) as 'total amount'
from staff s 
join payment p
on s.staff_id = p.staff_id
where p.payment_date >= '2005-08-01' and p.payment_date < '2005-09-01'
group by s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(*) as 'total actors'
from film f
inner join film_actor a 
on f.film_id = a.film_id
group by f.title

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(i.film_id) as 'total copies'
from inventory i
inner join film f 
on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) as 'total paid'
from payment p 
inner join customer c 
on p.customer_id = c.customer_id
group by c.first_name, c.last_name
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title 
from film
where title like '%K%' or title like '%Q%' 
and language_id in
(select language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id in
(select actor_id from film_actor where film_id in
(select film_id from film where title = 'Alone Trip'))

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email 
from customer
where address_id in 
(select address_id from address where city_id in
(select city_id from city where country_id in
(select country_id from country where country = 'Canada')));

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title 
from film 
where film_id in
(select film_id from film_category where category_id in
(select category_id from category where name = 'Family'));

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_date) as "rental"
from film f inner join inventory i on f.film_id = i.film_id
inner join rental r on r.inventory_id = i.inventory_id
group by title 
order by rental desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as 'amount'
from store s inner join customer c on c.store_id = s.store_id
inner join payment p on p.customer_id = c.customer_id
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, ct.country
from store s join address a on s.address_id = a.address_id
join city c on a.city_id = c.city_id
join country ct on ct.country_id = c.country_id
group by store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name, sum(payment.amount) as 'sum'
from payment join rental on payment.rental_id = rental.rental_id
join inventory on inventory.inventory_id =  rental.inventory_id
join film_category on film_category.film_id = inventory.film_id
join category on category.category_id = film_category.category_id
group by category.name
order by sum desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genre as 
select category.name, sum(payment.amount) as 'sum'
from payment join rental on payment.rental_id = rental.rental_id
join inventory on inventory.inventory_id =  rental.inventory_id
join film_category on film_category.film_id = inventory.film_id
join category on category.category_id = film_category.category_id
group by category.name
order by sum desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genre;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genre;

