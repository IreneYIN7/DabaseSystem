-- eg:
-- find all of the employees with a title of “Sales Support Agent”:
-- astName, FirstName FROM employees WHERE Title = "Sales Support Agent";
-- Find all of Led Zeppelin’s albums in the database (this does a join between two tables):
-- elect * from artists, albums where name="Led Zeppelin" and albums.ArtistId=artists.ArtistId
-- SELECT * from customers WHERE Country = "USA";

-- @ Name: Zhebin Yin
-- @ Date: Feb, 18, 2023
-- @ Course: Database System

-- Q1: Using the invoices table, find the billing cities in Germany that have the second most invoices.
-- Two German cities are tied on this. (Note that the invoices table has orders from many countries.)
SELECT BillingCity, COUNT(*) AS resNum FROM invoices WHERE BillingCountry = 'Germany'
GROUP BY BillingCity
ORDER BY resNum DESC
LIMIT 2,1;

-- answer: Frankfurt   7
--SELECT * FROM tracks where Composer = "Bossa Nova";

-- Q2:
-- number of tracks purchased per customer
select count(*)
from tracks
join invoice_items ii on tracks.TrackId = ii.TrackId
join invoices i on i.InvoiceId = ii.InvoiceId
group by CustomerId;

SELECT AVG(num_tracks) AS avg_tracks_purchased
FROM (
  SELECT c.customerId, COUNT(DISTINCT ii.trackId) AS num_tracks
  FROM customers c
  JOIN invoices i ON c.customerId = i.customerId
  JOIN invoice_items ii ON i.invoiceId = ii.invoiceId
  GROUP BY c.customerId
) t;

-- answer: 37.97

-- Q3:How many albums have classical tracks?
select count(DISTINCT albums.AlbumId) from albums
    join tracks on albums.AlbumId = tracks.AlbumId
    join genres g on tracks.GenreId = g.GenreId
where g.Name = 'Classical';

-- answer: 72

-- Q4: How many Bossa Nova tracks were purchased in total?
-- (Note you can ignore the Quantity field in the invoice_items table which is always one.)

select count(tracks.TrackId) as numTracks_BossaNova
from tracks
join invoice_items ii on tracks.TrackId = ii.TrackId
join genres g on tracks.GenreId = g.GenreId
where g.Name = 'Bossa Nova';


-- answer: 15

-- Q5 : What is the name of the customer who purchased the most jazz tracks?

-- count num of jazz tracks purchased by customer
select customers.LastName, customers.FirstName, count(customers.CustomerId) as numJazz
from customers
join invoices i on customers.CustomerId = i.CustomerId
join invoice_items ii on i.InvoiceId = ii.InvoiceId
join tracks t on ii.TrackId = t.TrackId
join genres g on t.GenreId = g.GenreId
where g.Name = 'Jazz'
group by customers.CustomerId
order by numJazz desc
limit 4;



select customers.FirstName, customers.LastName, count(*) as numJazzPur
from customers
    join invoices i on customers.CustomerId = i.CustomerId
    join invoice_items ii on i.InvoiceId = ii.InvoiceId
    join tracks t on ii.TrackId = t.TrackId
    join genres g on t.GenreId = g.GenreId
where g.Name = 'Jazz'
group by customers.CustomerId
order by numJazzPur desc
limit 1;
-- answer: Dominique Lefebvre (6 jazz tracks)

--Q6:
select t.Name as trackName
    from playlists
    join playlist_track pt on playlists.PlaylistId = pt.PlaylistId
    join tracks t on pt.TrackId = t.TrackId
    join albums a on t.AlbumId = a.AlbumId
where playlists.Name = 'Brazilian Music'
order by trackName asc
limit 1 offset 1;

-- answer:  A Luz De Tieta

-- Q7:
select count( albums.AlbumId) as numAlbs
from albums
join tracks t on albums.AlbumId = t.AlbumId
join invoice_items ii on t.TrackId = ii.TrackId
group by albums.AlbumId
having sum(ii.UnitPrice) > 25;


-- answer: 6

-- Q8

select round(AVG(numPerEmployee),1)  as average
from (select count(*) as numPerEmployee
      from employees
               join customers c on employees.EmployeeId = c.SupportRepId
      where employees.Title = 'Sales Support Agent'
      group by employees.EmployeeId
);
-- answer: 19.7

-- Q9
select count(*)
from (
SELECT COUNT(DISTINCT g.genreId)
FROM genres g
JOIN tracks t ON g.genreId = t.genreId
JOIN invoice_items ii ON t.trackId = ii.trackId
JOIN invoices i ON ii.invoiceId = i.invoiceId
GROUP BY g.genreId
HAVING SUM(ii.unitPrice) > 50
);
-- answer 8

-- Q10
SELECT artist.Name AS name, COUNT(DISTINCT alb.AlbumId) AS num_alb
FROM artists artist
JOIN albums alb ON artist.ArtistId = alb.ArtistId
JOIN tracks track ON alb.AlbumId = track.AlbumId
GROUP BY artist.ArtistId
ORDER BY num_alb DESC
LIMIT 1 OFFSET 3;

-- answer: Metallica 10 albums

-- Q11
-- Find the names of the tracks on the album "Blue Moods" and put them in alphabetical order.
select tracks.Name
from tracks
join albums a on tracks.AlbumId = a.AlbumId
where a.Title = 'Blue Moods'
order by tracks.Name asc
limit 1 offset 2;

-- answer：deep waters

-- Q12
-- How many artists in the database do not have any albums in the database


SELECT count(*)
from artists
Left JOIN albums ON artists.ArtistId = albums.ArtistId
where albums.ArtistId is NULL;

-- answer: 71

-- Q13
-- What is the name of the second longest album,
-- in terms of the total milliseconds of its tracks stored in the database

select tracks.AlbumId, sum(Milliseconds) as total_time
from tracks
join albums a on tracks.AlbumId = a.AlbumId
group by tracks.AlbumId
order by total_time desc;



select albums.Title, total_time
from albums, (
select tracks.AlbumId, sum(Milliseconds) as total_time
from tracks
join albums a on tracks.AlbumId = a.AlbumId
group by tracks.AlbumId
order by total_time desc ) as a
where albums.AlbumId = a.AlbumId;



select Title, sum(Milliseconds) as total_time
from albums
Inner join tracks on albums.AlbumId = tracks.AlbumId
group by albums.AlbumId
order by total_time DESC
LIMIT 1 , 1;


-- answer: Battlestar Galactica (Classic), Season 1 --- time: 70213784

-- Q14
-- Find the number of invoices per billing city.
-- Six cities are tied for the most invoices per billing city. Which are these cities

select invoices.BillingCity, count(*) as Num_Invoices
from invoices
group by BillingCity
order by Num_Invoices desc
limit 6;

-- Using Window Functions.
select DISTINCT invoices.BillingCity, count(*) over (partition by invoices.BillingCity) as Num_Invoices
from invoices
order by Num_Invoices desc
limit 6;

-- answer : Sao Paulo, Prague, Paris, Mountain View, London, Berlin --- number: 14

-- midterm question
-- find the total sales for Germany and for France, separately.
-- The query should output a two row, two column table with the results.
-- # Midterm

-- 1. using the invoices table,
-- write a query to find the total sales for Germany and for France, separately.
-- The query should output a two row, two column table with the results.

SELECT
	BillingCountry,
	SUM(invoices.Total) AS TotalSales
FROM
	Invoices
WHERE
	BillingCountry in ('Germany',  'France')
GROUP BY
	BillingCountry;
-- 2.
-- Write a query that partitions the invoices table by Customerid,
-- and add a rank column called r which ranks the invoice rows within each customer by the invoice total
-- in descending order of total.
-- The query should output the invoiceid, customerid, total, and r.

select InvoiceId, CustomerId, Total,
       rank() over(partition by CustomerId order by total desc ) as r
from invoices;

-- 3.
-- add a column "average" which is the average invoice value per customer.

select InvoiceId, CustomerId, Total,
       AVG(total) over(partition by CustomerId) as average,
       rank() over(partition by CustomerId order by total desc ) as r,
       ((Total - AVG(total) over(partition by CustomerId)) / AVG(total) over(partition by CustomerId)) * 100 AS pct_diff
from invoices;

-- 4.
-- Write a query that joins the customers and invoices tables to produce a table containing the customerid,
-- firstname and lastname of the customer,
-- and the average value of that customer's invoices.

select customers.CustomerId, FirstName, LastName, avg(i.Total) as average
from customers
join invoices i on customers.CustomerId = i.CustomerId
group by customers.CustomerId, FirstName, LastName;

-- 5.
-- There are two albums that have tracks with three distinct genres.
-- Write a query to determine their albumids.

select albums.AlbumId
from albums
join tracks t on albums.AlbumId = t.AlbumId
join genres g on t.GenreId = g.GenreId
group by albums.AlbumId
HAVING
    COUNT(DISTINCT g.genreid) = 3;


-- 6.
-- find the tracks which were not on any of the invoices
select count(*) as numTracksNotInInvoices
from tracks
where TrackId not in (
    select DISTINCT TrackId
    from invoice_items
    );

-- 7.
-- compute the total spent (new column total_spent) on tracks by genre
select g.GenreId, g.Name, sum(ii.UnitPrice) as total_spent
from tracks
join invoice_items ii on tracks.TrackId = ii.TrackId
join genres g on tracks.GenreId = g.GenreId
group by g.GenreId, g.Name
having total_spent > 0
order by total_spent desc;

-- 8.
-- does a left join with the genres table on the left and the query from the last exercise on the right
-- to find the genreid and sales of any genres that have no sales
select genres.genreid, genres.name
from genres
left join (
    select g.GenreId, g.Name, sum(ii.UnitPrice) as total_spent
    from tracks
    join invoice_items ii on tracks.TrackId = ii.TrackId
    join genres g on tracks.GenreId = g.GenreId
    group by g.GenreId, g.Name
    having total_spent > 0
    order by total_spent desc
) as s on genres.GenreId = s.GenreId
where s.GenreId is null;

-- 9.
--  outputs a table containing the total sales (a new column, "totalSales") of rock tracks by albums,
--  sorted in descending order of total sales.
-- The output should contain one line per album, including the albumid, title of the album,
-- and total sales of rock tracks for that album, in descending order of total sales.

select a.AlbumId, a.Title, sum(ii.UnitPrice) as totalSales
from tracks
join albums a on tracks.AlbumId = a.AlbumId
join invoice_items ii on tracks.TrackId = ii.TrackId
join genres g on tracks.GenreId = g.GenreId
where g.Name = 'Rock'
group by a.AlbumId, a.Title
order by totalSales desc;

-- 10.
-- adds the artistid to the previous query and modify it so it outputs a table with the albums associated with each artist
-- ranked by descending totalSales within each artist.
-- The columns output should be artistid, albumid, title, totalSales, and r, a rank column.

select a.ArtistId, a.AlbumId, a.Title, sum(ii.UnitPrice) as totalSales,
rank() over (partition by a.ArtistId order by sum(ii.UnitPrice) desc) as r
from tracks
join albums a on tracks.AlbumId = a.AlbumId
join invoice_items ii on tracks.TrackId = ii.TrackId
join genres g on tracks.GenreId = g.GenreId
where g.Name = 'Rock'
group by a.AlbumId, a.Title
order by totalSales desc;

