-- Number of movies in each category

SELECT 
	c.name AS category,
	COUNT(fc.film_id) AS film_count
FROM film f
LEFT JOIN film_category fc
	ON f.film_id = fc.film_id
LEFT JOIN category c
	ON c.category_id = fc.category_id
GROUP BY fc.category_id, c.name
ORDER BY film_count DESC;


-- Top 10 actors whose movies were rented the most

SELECT 
	a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(r.rental_id) AS rental_count
FROM actor a
LEFT JOIN film_actor fc	
	ON fc.actor_id = a.actor_id
LEFT JOIN inventory i
	ON i.film_id = fc.film_id
LEFT JOIN rental r
	ON i.inventory_id = r.inventory_id
GROUP BY 
	a.actor_id,
    a.first_name,
    a.last_name
ORDER BY rental_count DESC
LIMIT 10


-- Category that generated the most rental revenue

SELECT 
	c.category_id,
	c.name,
	SUM(p.amount) AS rental_sum
FROM category c
LEFT JOIN film_category fc
	ON c.category_id = fc.category_id
LEFT JOIN inventory i
	ON i.film_id = fc.film_id
LEFT JOIN rental r
	ON r.inventory_id = i.inventory_id
LEFT JOIN payment p
	ON p.rental_id = r.rental_id
GROUP BY c.category_id, c.name
ORDER BY rental_sum DESC
LIMIT 1


-- Movies that are not in the inventory

SELECT f.title
FROM film f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory i
    WHERE i.film_id = f.film_id
);


-- Top 3 actors with the most appearances in Children movies

WITH actor_counts AS (
	SELECT 
		a.actor_id,
		a.first_name,
	    a.last_name,
		COUNT(DISTINCT fa.film_id) AS children_films_count
	FROM film_actor fa
	LEFT JOIN actor a
		ON fa.actor_id = a.actor_id
	LEFT JOIN film f
		ON fa.film_id = f.film_id
	LEFT JOIN film_category fc
		ON fc.film_id = fa.film_id
	LEFT JOIN category c
		ON c.category_id = fc.category_id
	WHERE c.name = 'Children'
	GROUP BY 
		a.actor_id,
		a.first_name,
	    a.last_name
),
actor_ranks AS (
	SELECT 
		*,
		DENSE_RANK() OVER(ORDER BY children_films_count DESC) AS children_film_rank
	FROM actor_counts
)
SELECT *
FROM actor_ranks
WHERE children_film_rank <= 3
ORDER BY children_film_rank;


-- Number of active and inactive customers in each city

SELECT 
	ci.city_id, 
	ci.city,
	COUNT(CASE WHEN c.active = 1 THEN 1 END) AS active_customers,
    COUNT(CASE WHEN c.active = 0 THEN 1 END) AS inactive_customers
FROM customer c
LEFT JOIN address a
	ON a.address_id = c.address_id
LEFT JOIN city ci
	ON ci.city_id = a.city_id
GROUP BY ci.city_id, ci.city
ORDER BY inactive_customers DESC

-- Category with the most total rental hours for movies starting with 'A' and for cities containing '-'

WITH rental_data AS (
    SELECT
        c.name AS category_name,
        f.title,
        ci.city AS city_name,
        EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600
            AS rental_hours
    FROM category c
    JOIN film_category fc
        ON c.category_id = fc.category_id
    JOIN film f
        ON fc.film_id = f.film_id
    JOIN inventory i
        ON i.film_id = f.film_id
    JOIN rental r
        ON r.inventory_id = i.inventory_id
    JOIN customer cu
        ON cu.customer_id = r.customer_id
    JOIN address a
        ON a.address_id = cu.address_id
    JOIN city ci
        ON ci.city_id = a.city_id
    WHERE r.return_date IS NOT NULL
)

SELECT
    category_name,
    SUM(rental_hours) AS total_rental_hours
FROM rental_data
WHERE title LIKE 'A%'
GROUP BY category_name
ORDER BY total_rental_hours DESC
LIMIT 1;

SELECT
    category_name,
    SUM(rental_hours) AS total_rental_hours
FROM rental_data
WHERE city_name LIKE '%-%'
GROUP BY category_name
ORDER BY total_rental_hours DESC
LIMIT 1;
