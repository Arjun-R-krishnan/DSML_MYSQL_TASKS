USE SAKILA;

SHOW FULL TABLES;

/* Display the first and last name of each actor in a single column in upper case letters in alphabetic order.
Name the column Actor Name */
SELECT 
	CONCAT(UPPER(first_name), ' ',UPPER(last_name)) AS "Actor Name"
FROM
	actor
ORDER BY
	CONCAT(first_name, ' ',last_name);

-- Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE "%GEN%";


-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");


-- List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(*) AS "Number of actors with the same last name"
FROM actor
GROUP BY  last_name;


-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS "Number of actors with the same last name"
FROM  actor
GROUP BY last_name
HAVING COUNT(*) >= 2;


-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

SELECT * FROM actor WHERE first_name = 'HARPO';

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT s.first_name, s.last_name, a.address 
FROM staff s   
JOIN  address a ON s.address_id = a.address_id ;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join
SELECT f.title AS "Film Title",
    COUNT(*) AS "Number of actors listed"
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;

-- How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(*) AS "Number of Hunchback Impossible copies in the inventory"
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title="HUNCHBACK IMPOSSIBLE";


-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name

SELECT 
	c.first_name,
    c.last_name,
    SUM(p.amount) AS "Total paid by each customer"
FROM  customer c 
JOIN  payment p ON c.customer_id = p.customer_id
GROUP BY  c.first_name,c.last_name ;


-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English

SELECT
	f.title
FROM
	film f
WHERE
	(f.title LIKE "K%" OR f.title LIKE "Q%") AND f.language_id =
    ( SELECT l.language_id FROM language l WHERE name = "English");
    
    
    
-- Use subqueries to display all actors who appear in the film Alone Trip.   
SELECT
    CONCAT(first_name, ' ', last_name) AS `Actors in the film Alone Trip`
FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id = 
	(SELECT film_id FROM film WHERE title = 'ALONE TRIP'));

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information

SELECT c.first_name, c.last_name ,c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country ='Canada';

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT f.title AS "Family Movies" FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = "Family";

-- Create a Stored procedure to get the count of films in the input category (IN category_name, OUT count)
DELIMITER  //

CREATE PROCEDURE FilmCountByCategory(IN category_name VARCHAR(255), OUT film_count INT)
BEGIN 
	SELECT COUNT(*) INTO film_count
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = category_name;
    END //
    DELIMITER ;
    
    CALL FilmCountByCategory('Classics', @film_count);
    SELECT @film_count;



-- Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(r.rental_id) AS `Rental Count`
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY `Rental Count` DESC;

-- Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS `Store ID`, 
       ci.city AS `City`, 
       co.country AS `Country`
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;
 


--  List the genres and its gross revenue. 
SELECT c.name AS `Genre`, SUM(p.amount) AS `Gross Revenue`
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name;



-- Create a View for the above query

CREATE VIEW genre_revenue AS
SELECT c.name AS `Genre`, SUM(p.amount) AS `Gross Revenue`
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name;

SELECT * FROM genre_revenue;

-- Select top 5  genres in gross revenue view

SELECT * FROM genre_revenue
ORDER BY `Gross Revenue` DESC
LIMIT 5;



