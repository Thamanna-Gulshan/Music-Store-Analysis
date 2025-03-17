-- Create database
CREATE DATABASE music;
USE music;

-- Analysis

/* Who is the senior most employee based on job title */

SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Which countries have the most Invoices? */

SELECT  billing_country, COUNT(invoice_id) AS no_of_invoice
FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoice DESC;


/* What are top 3 values of total invoice? */

SELECT DISTINCT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Which Employee has the Highest Total Number of Customers? */

SELECT e.employee_id, concat(e.first_name,' ', e.last_name) as employee_name, count(c.customer_id) as customer_count
FROM employee e
JOIN customer c ON c.support_rep_id=e.employee_id
group by e.employee_id, concat(e.first_name,' ', e.last_name)
order by customer_count desc
limit 1;

/* Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

/* Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id, first_name, last_name, SUM(total) AS money_spent
FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
GROUP BY customer_id,first_name, last_name
ORDER BY money_spent DESC
LIMIT 1;


/* Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT distinct c.email, c.first_name, c.last_name, g.name
FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track t ON il.track_id=t.track_id
JOIN GENRE g ON t.genre_id=g.genre_id
WHERE g.name like 'rock'
ORDER BY c.email;

/* Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.name, COUNT(artist.name) AS track_count
FROM artist
JOIN album ON artist.artist_id=album.artist_id
JOIN track ON album.album_id=track.album_id
WHERE track_id IN (
SELECT track_id FROM track t 
JOIN genre g ON t.genre_id=g.genre_id
WHERE g.name LIKE 'rock'
)
GROUP BY artist.name
ORDER BY track_count DESC
LIMIT 10;

/* Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds> (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;
;

/* Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT concat(c.first_name, ' ', c.last_name) AS customer_name, ar.name, SUM(total) AS money_spent
FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track t ON il.track_id=t.track_id
JOIN album a ON t.album_id=a.album_id
JOIN artist ar ON a.artist_id=ar.artist_id
GROUP BY ar.name, concat(c.first_name, ' ', c.last_name)
ORDER BY ar.name, money_spent DESC;

/* Find how much amount spent by each customer on top most artist? Write a query to return customer name, artist name and total spent */

WITH best_selling_artist as
(SELECT ar.artist_id, ar.name as artist_name, SUM(il.unit_price*il.quantity) AS total_sales
FROM artist ar 
JOIN album a ON ar.artist_id=a.artist_id
JOIN track t on a.album_id=t.album_id
JOIN invoice_line il ON t.track_id=il.track_id
GROUP BY ar.artist_id, ar.name
ORDER BY total_sales DESC
LIMIT 1)

SELECT c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC; 

/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with a as
(SELECT 
billing_country, g.name, count(il.quantity) as purchase_count, 
rank() over(partition by i.billing_country order by count(il.quantity) desc) as ranking
FROM invoice i 
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track t ON il.track_id=t.track_id
JOIN genre g ON t.genre_id=g.genre_id
group by i.billing_country, g.name
order by i.billing_country, purchase_count desc)
select billing_country, name, purchase_count
from a 
where ranking=1;

/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with Customter_with_country as (SELECT c.country, c.customer_id, c.first_name, c.last_name, sum(i.total) as money_spent,
rank() over(partition by c.country order by sum(i.total) desc) as ranking
FROM customer c 
JOIN invoice i ON c.customer_id=i.customer_id
group by c.country, c.customer_id, c.first_name, c.last_name)
select country, customer_id, first_name, last_name, money_spent
from Customter_with_country 
where ranking=1;

-- Insights:
/* 
1. The majority of the countries have Rock music as their most Listened music. 
2. Feedback should be demanded from the customers as to why they prefer listening to Rock Music to other types of music and this feedback should be used to improve other music.
3. More publicity and promotions should be made for other genres of music to attract more customers thereby increasing the company’s revenue.
4. All artists who have written rock music should be celebrated as they contribute a large percentage to the company’s revenue.
5. Most rock music has a short length compared to other type of music. This might be one of the reasons why customers listen to rock music more often than the others. The company should work on informing their artists to always write songs not more than 400,000 milliseconds in length to help increase patronage.
6. USA has contributed more sales followed by canada and brazil
7. Incentives should be given to the top customers to motivate and encourage them to keep patronizing the company. 
*/





