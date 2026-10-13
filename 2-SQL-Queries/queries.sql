

#1

select m.titmle AS movie_title
from movie m, actor a, genre g, role r, movie_has_genre mg
where a.last_name = 'Allen' and g.genre_name = 'Comedy' and g.genre_id = mg.genre_id and m.movie_id = mg.movie_id and 
	r.movie_id = m.movie_id and a.actor_id = r.actor_id
Order by m.title asc;


#2

select d.last_name AS director_last_name, m.title As movie_title
from actor a, role r, movie m, director d, movie_has_director md
where a.last_name = 'Allen' and a.actor_id = r.actor_id and r.movie_id = m.movie_id and m.movie_id = md.movie_id and
	md.director_id = d.director_id and d.director_id IN

	# find the directors with at least 2 different movie genres
	(select d1.director_id
	from genre g, movie_has_genre mg, movie m1 , movie_has_director md1, director d1
	where g.genre_id = mg.genre_id and m1.movie_id = mg.movie_id and d1.director_id = md1.director_id and md1.movie_id = m1.movie_id
	group by d1.director_id
	having count(distinct g.genre_id) >= 2 
	)
order by d.last_name;

    
#3

# actors in movies of directors of same surname
select DISTINCT(a.last_name) AS actor_last_name
from director d, actor a, role r, movie m, movie_has_director md
where d.last_name = a.last_name and a.actor_id = r.actor_id and r.movie_id = m.movie_id and m.movie_id = md.movie_id 
	and md.director_id = d.director_id and a.actor_id IN (
		
	
	# actors in movies of a director of a different surname, but with specific movie genre
	select a.actor_id
    from movie m2, role r2, director d2, movie_has_director md2, genre g2, movie_has_genre mg2
    where (a.last_name <> d2.last_name) and a.actor_id = r2.actor_id and r2.movie_id = m2.movie_id 
		and g2.genre_id = mg2.genre_id and mg2.movie_id = m2.movie_id
		and md2.director_id = d2.director_id and md2.movie_id = m2.movie_id and mg2.genre_id IN 

		(
		# the genres of the movies that the actor does not play in, but have a director
		# with the same surname
		select DISTINCT(mg3.genre_id)
		from movie m3, movie_has_director md3, genre g3, movie_has_genre mg3
		where g3.genre_id = mg3.genre_id and m3.movie_id = mg3.movie_id and md3.movie_id = m3.movie_id
			and md3.director_id = d.director_id and (r.movie_id <> m3.movie_id)
		)
    );
    

#4

select DISTINCT 'Yes' AS result
from movie m, genre g, movie_has_genre mg
where m.year = '1995' and m.movie_id = mg.movie_id and g.genre_id = mg.genre_id and g.genre_name = 'Drama'

UNION

select DISTINCT 'No' AS result
from movie m, genre g, movie_has_genre
where not exists (
	select *
    from movie m, genre g, movie_has_genre mg
    where m.year = '1995' and g.genre_name = 'Drama'and m.movie_id = mg.movie_id and g.genre_id = mg.genre_id
    );
    
    
    
#5

select d1.last_name AS director_1, d2.last_name AS director_2
from director d1, director d2, movie m, movie_has_director md1 , movie_has_director md2, movie_has_genre mg 
where (d1.director_id <> d2.director_id and d1.director_id < d2.director_id) # so as (b1,b2 = b2,b1) 
	and d1.director_id = md1.director_id and d2.director_id = md2.director_id and
	md1.movie_id = m.movie_id and m.movie_id = md2.movie_id and mg.movie_id = m.movie_id 
	and m.year >= 2000 and m.year <= 2006 

group by d1.director_id, d2.director_id, m.movie_id # for each (director, movie) pair, we calculate the number of genres of the movie
having count(*) >= 6; # total genres of both directors must be >= 6


 #6 
    
select a1.first_name AS actor_first_name, a1.last_name AS actor_last_name, count(DISTINCT md.director_id) AS number_of_directors
from actor a1, movie m1, role r1, movie_has_director md
where r1.actor_id = a1.actor_id and m1.movie_id = r1.movie_id and md.movie_id = m1.movie_id and a1.actor_id in
   # actors that have played in exactly 3 movies
   ( select a.actor_id 
	from actor a, role r, movie m
	where a.actor_id = r.actor_id and r.movie_id = m.movie_id
	group by a.actor_id
	having count(distinct(m.movie_id)) = 3)
group by a1.last_name, a1.first_name
order by a1.last_name;

#7

# for each genre that was returned by the nested select(group by), we find the count 
# of distinct directors that have directed a movie of that genre 

select mg.genre_id, count(distinct md.director_id) as number_of_directors_for_genre 
from  movie_has_director md , movie_has_genre mg, movie m
where m.movie_id = mg.movie_id and m.movie_id = md.movie_id and  mg.genre_id in

		# finds the genres of those movies
		(select  mg1.genre_id
		from  movie_has_genre mg1
		where mg1.movie_id  in

			# returns the movies with a single genre
			(select m1.movie_id
			from movie_has_genre mg2 ,movie m1
			where m1.movie_id = mg2.movie_id 
			group by m1.movie_id
			having count(*) = 1))
		
group by mg.genre_id 
;

#8

select distinct(a.actor_id)
from actor a 
where  not exists( 
# we need all the ids of actors for which a genre in which they have not played in does not exist,
# meaning they have played in every genre
     select  distinct(g.genre_id)	# all the genre of movies that do not exist in ...
     from genre g  
     where not exists(
     
		select *				
        from role r, movie m , movie_has_genre mg 	# all the movies, their genres and their roles
        where r.actor_id = a.actor_id and m.movie_id = r.movie_id and mg.movie_id = m.movie_id and g.genre_id = mg.genre_id
	 )
);
    
    
#9

select g1.genre_id AS genre_1, g2.genre_id AS genre_2, COUNT(DISTINCT director_id) AS number_of_directors_with_both_genres
from genre g1, genre g2, director d
where g1.genre_id <> g2.genre_id and g1.genre_id < g2.genre_id # so that we do not have duplicates
	and director_id IN (

			# for each director we check if for any two of his movies (m1, m2), their genres are equal to (g1, g2).

			# for each (g1, g2) pair of genres from the outer select, 
			# the nested select returns the set of directors that have directed movies of both genres     

            select md1.director_id
            from movie m1, movie m2, movie_has_genre mg1, movie_has_genre mg2, movie_has_director md1, movie_has_director md2
            where	m1.movie_id = md1.movie_id and m2.movie_id = md2.movie_id and mg1.movie_id = m1.movie_id 
				and	mg2.movie_id = m2.movie_id and mg1.genre_id = g1.genre_id and mg2.genre_id = g2.genre_id 
                and md1.director_id = d.director_id and md2.director_id = d.director_id
        )
        
group by g1.genre_id, g2.genre_id;


#10


select mg1.genre_id, a.actor_id, count(*) AS count
from movie m2,actor a, role r,  movie_has_genre mg1 
where  m2.movie_id = mg1.movie_id and mg1.movie_id = m2.movie_id and
  m2.movie_id = r.movie_id and a.actor_id = r.actor_id and m2.movie_id in 


	# movie ids with a director that has directed only a single genre
	(select m1.movie_id
	from movie m1, movie_has_director md1
	where m1.movie_id = md1.movie_id and md1.director_id in 
    
         # directors with 1 genre
		(select d.director_id
		from genre g, movie_has_genre mg, movie m , movie_has_director md, director d
		where g.genre_id = mg.genre_id and m.movie_id = mg.movie_id and d.director_id = md.director_id and md.movie_id = m.movie_id
		group by d.director_id
		having count(distinct g.genre_id) = 1 
		)
        
	group by m1.movie_id, md1.director_id
    
        
	)

group by mg1.genre_id,  a.actor_id
order by mg1.genre_id, a.actor_id
;


