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
