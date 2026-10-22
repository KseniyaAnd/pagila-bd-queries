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
