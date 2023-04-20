--1. SENIOR MOST EMPLOYEE BASED ON JOB TITLE
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

--2. WHICH COUNTRIES HAVE THE MOST INVOICES (TOP 5)?
SELECT COUNT (*) AS C, billing_country
FROM invoice
GROUP BY billing_country 
ORDER BY c DESC
LIMIT 5

--3. TOP 3 VALUES OF TOTAL INVOICES
SELECT billing_country AS country, total
FROM invoice
ORDER BY total DESC
LIMIT 3

--4. BEST CITY ACCORDING TO CUSTOMERS & INVOICE TOTAL
SELECT billing_city AS Best_City, SUM(total) AS Total_Invoice
FROM invoice
GROUP BY Best_City
ORDER BY Total_Invoice DESC
LIMIT 1

--5. BEST CUSTOMER (i.e., customer who spent the most amount of money)
SELECT c.customer_id, first_name, last_name, city, country, email, SUM (total)AS Total_Amount_spent
FROM customer AS c
JOIN invoice AS i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_amount_spent DESC
LIMIT 5

--6. TO RETURN EMAIL. FIRST NAME, LAST NAME & GENRE OF ALL ROCK MUSIC LISTENERS (ARRANGED ALPHABETICALLY THROUGH EMAIL)
SELECT DISTINCT c.email, c.first_name First_Name, c.last_name Last_Name, g.name Genre_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE t.track_id IN(
	SELECT track_id FROM track AS t
	JOIN genre AS g
	ON t.genre_ID = g.genre_id
	WHERE g.name LIKE 'Rock')
ORDER BY email


--7. ARTIST WHO HAVE WRITTEN MOST ROCK SONGS. RETURN ARTIST NAME AND TOTAL NUMBER OF SONGS (TOP 10)
SELECT ARTIST.name, ARTIST.ARTIST_ID, COUNT(artist.artist_id) AS number_of_tracks FROM TRACK
JOIN GENRE ON TRACK.GENRE_ID = GENRE.GENRE_ID
JOIN ALBUM ON TRACK.ALBUM_ID = ALBUM.ALBUM_ID
JOIN ARTIST ON ALBUM.ARTIST_ID = ARTIST.ARTIST_ID
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
order by number_of_tracks DESC
LIMIT 10


--8. TO FIND THE TOTAL NUMBER OF SONGS OF ARTIST AND IT'S GENRE BY USING HIS ARTIST ID
SELECT artist.artist_id, artist.name AS artist_name, genre.name AS genre_name, COUNT(artist.artist_id) AS no_of_songs
FROM track
JOIN genre ON track.GENRE_ID = genre.GENRE_ID
JOIN album ON track.ALBUM_ID = album.ALBUM_ID
JOIN artist ON album.ARTIST_ID = artist.ARTIST_ID
WHERE artist.artist_id LIKE '150'
GROUP BY artist.artist_id, genre_name


--9. LIST OF SONGS WHO HAVE SONG LENGTH LONGER THAN AVERAGE SONG LENGTH
SELECT name, milliseconds AS song_length FROM track
WHERE milliseconds> (
SELECT AVG(milliseconds) AS avg_song_length 
FROM track
)
ORDER BY 2 DESC



--10. AMOUNT SPENT BY EACH CUSTOMER ON ARTIST 
WITH total_amount_spent AS (
		SELECT artist.artist_id artistid, artist.name artist_name, SUM(il.unit_price*il.quantity) total_sales
		FROM invoice_line AS il
		JOIN track AS t ON t.track_id = il.track_id
		JOIN album AS a ON a.album_id = t.album_id
		JOIN artist ON artist.artist_id = a.artist_id
		GROUP BY 1
		ORDER BY 3 DESC
)
SELECT c.customer_id, c.first_name, c.last_name, c.country, artist.name AS artist_name, tas.total_sales 
FROM customer as c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album a ON  t.album_id = a.album_id
JOIN artist ON artist.artist_id = a.artist_id
JOIN total_amount_spent tas ON tas.artistid = a.artist_id
GROUP BY 1, 5, 6
ORDER BY 6 DESC

--11. MOST POPULAR GENRE ACCORDING TO EACH COUNTRY
WITH most_popular_genre AS (
	SELECT COUNT(il.quantity) AS songs_sold, c.country, g.genre_id, g.name genre_name,
	DENSE_RANK() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS dnsrnk 
	FROM customer as c 
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
	GROUP BY 2, 3, 4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM most_popular_genre WHERE dnsrnk = 1


----12. CUSTOMERS WHO HAVE MOST AMOUNT OF MONEY ON MUSIC FROM EACH COUNTRY
WITH most_spending_users AS(
	SELECT c.customer_id, c.first_name, c.last_name, c.country,  SUM(il.unit_price) total_amount_spent,
	DENSE_RANK() OVER(PARTITION BY c.country ORDER BY SUM(il.unit_price) DESC) AS dnsrnk
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	GROUP BY 1, 4	
)
SELECT * FROM most_spending_users WHERE dnsrnk <= 1

--13. Employees reporting manager
SELECT t2.employee_id, t2.first_name ||' '|| t2.last_name AS employee_name, 
t2.title, t2.levels, t1.first_name ||' '|| t1.last_name AS reporting_manager, t1.title
FROM employee T1, employee T2
WHERE t1.employee_id = t2.reports_to

--14. EMPLOYEES HANDLING THE HIGHEST NUMBER OF CUSTOMERS
SELECT e.employee_id, e.first_name, e.last_name, e.title AS desgination, COUNT(c.support_rep_id) AS no_of_customers 
FROM employee e
JOIN customer c ON c.support_rep_id = e.employee_id::int
GROUP BY e.employee_id
ORDER BY no_of_customers DESC