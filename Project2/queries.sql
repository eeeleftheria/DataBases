# 1115202200183 - Στέφανος Τζαφέρης
# 1115202200025 - Ελευθερία Γαλιατσάτου


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

	#βρίσκουμε τους σκηνοθέτες με τουλαχιστον 2 ΔΙΑΦΟΡΕΤΙΚΑ είδη ταινιών
	(select d1.director_id
	from genre g, movie_has_genre mg, movie m1 , movie_has_director md1, director d1
	where g.genre_id = mg.genre_id and m1.movie_id = mg.movie_id and d1.director_id = md1.director_id and md1.movie_id = m1.movie_id
	group by d1.director_id
	having count(distinct g.genre_id) >= 2 # δε θέλουμε να μετράει 2 ταινίες comedy πχ σαν 2 είδη 
	)
order by d.last_name;

    
#3

# ηθοποιοι σε ταινιες σκηνοθετων με το ιδιο επιθετο
select DISTINCT(a.last_name) AS actor_last_name
from director d, actor a, role r, movie m, movie_has_director md
where d.last_name = a.last_name and a.actor_id = r.actor_id and r.movie_id = m.movie_id and m.movie_id = md.movie_id 
	and md.director_id = d.director_id and a.actor_id IN (
		
	# ηθοποιοι που συμμετεχουν σε μια ταινια με σκηνοθετη χωρις το ιδιο επιθετο αλλα με το ειδος της ταινιας να ταυτιζεται με ...
	select a.actor_id
    from movie m2, role r2, director d2, movie_has_director md2, genre g2, movie_has_genre mg2
    where (a.last_name <> d2.last_name) and a.actor_id = r2.actor_id and r2.movie_id = m2.movie_id 
		and g2.genre_id = mg2.genre_id and mg2.movie_id = m2.movie_id
		and md2.director_id = d2.director_id and md2.movie_id = m2.movie_id and mg2.genre_id IN 

		(
        # τα ειδη των ταινιων στις οποιες δεν συμμετεχει ο συγκεκριμενος ηθοποιος αλλα εχουν σκηνοθετη με το ιδιο επωνυμο με αυτο του ηθοποιου
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
where (d1.director_id <> d2.director_id and d1.director_id < d2.director_id) #για να να μην συνδυαζεται με τον εαυτο του και να θεωρούνται οι συνδυασμοι (β1,β2 = β2,β1) 
	and d1.director_id = md1.director_id and d2.director_id = md2.director_id and
	md1.movie_id = m.movie_id and m.movie_id = md2.movie_id and mg.movie_id = m.movie_id  #συνθηκες ζευξης
	and m.year >= 2000 and m.year <= 2006 #συνθηκη επιλογης

group by d1.director_id, d2.director_id, m.movie_id #για καθε ζευγος σκηνοθετων και ταινια, μετραμε τα ειδη της 
having count(*) >= 6; # ειδη της ταινιας που συσχετιζει τους δυο σκηνοθέτες >= 6


 #6 
    
select a1.first_name AS actor_first_name, a1.last_name AS actor_last_name, count(DISTINCT md.director_id) AS number_of_directors
from actor a1, movie m1, role r1, movie_has_director md
where r1.actor_id = a1.actor_id and m1.movie_id = r1.movie_id and md.movie_id = m1.movie_id and a1.actor_id in
   # ηθοποιοί που έχει παίξει σε ακριβώς 3 ταινίες
   ( select a.actor_id 
	from actor a, role r, movie m
	where a.actor_id = r.actor_id and r.movie_id = m.movie_id
	group by a.actor_id
	having count(distinct(m.movie_id)) = 3)
group by a1.last_name, a1.first_name
order by a1.last_name;

#7

#για κάθε genre που μας επεστρεψε το εμφωλευμένο select (group by) βρίσκουμε το πληθος των distinct σκηνοθετων που έχουν 
#σκηνοθετησει μια ταινία με τέτοιο είδος (δες μας νοιαζει αν ο ίδιος σκηνοθέτης έχει πολλές ταινίες αυτού του είδους)

select mg.genre_id, count(distinct md.director_id) as number_of_directors_for_genre 
from  movie_has_director md , movie_has_genre mg, movie m
where m.movie_id = mg.movie_id and m.movie_id = md.movie_id and  mg.genre_id in

		#βρίσκει τα είδη αυτών των ταινιών
		(select  mg1.genre_id
		from  movie_has_genre mg1
		where mg1.movie_id  in

			#επιστρεφει τις ταινίες που εχουν ακριβώς ένα είδος
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
where  not exists( #θελουμε ολους τους κωδικους των ηθοποιων για τους οποιους να ΜΗΝ υπαρχει ειδος στο οποιο να ΜΗΝ εχουν παιξει
				   #δηλαδη εχουν παιξει σε ολα τα ειδη

     select  distinct(g.genre_id)	#ολα τα ειδη ταινιων που να μην υπαρχουν σε ...
     from genre g  
     where not exists(
     
		select *				
        from role r, movie m , movie_has_genre mg 	#ολες οι ταινιες, το ειδος τους και οι ρολοι για καθε μια
        where r.actor_id = a.actor_id and m.movie_id = r.movie_id and mg.movie_id = m.movie_id and g.genre_id = mg.genre_id
	 )
);
    
    
#9

select g1.genre_id AS genre_1, g2.genre_id AS genre_2, COUNT(DISTINCT director_id) AS number_of_directors_with_both_genres
from genre g1, genre g2, director d
where g1.genre_id <> g2.genre_id and g1.genre_id < g2.genre_id #gia na mh bgazei dipla
	and director_id IN (
			
            #για καθε σκηνοθετη ελεγχουμε αν για δυο του τυχαιες ταινιες (m1, m2) τα ειδη τους ταυτιζονται με το ζευγος (g1, g2) καθε φορα.
            #για καθε ζευγος (g1, g2) το εμφωλευμενο select επιστρεφει ενα συνολο με ολους τους σκηνοθετες που εχουν σκηνοθετησει ταινιες
            #και των δυο ειδων.
                 
            select md1.director_id
            from movie m1, movie m2, movie_has_genre mg1, movie_has_genre mg2, movie_has_director md1, movie_has_director md2
            where	m1.movie_id = md1.movie_id and m2.movie_id = md2.movie_id and mg1.movie_id = m1.movie_id 
				and	mg2.movie_id = m2.movie_id and mg1.genre_id = g1.genre_id and mg2.genre_id = g2.genre_id 
                and md1.director_id = d.director_id and md2.director_id = d.director_id
        )
        
group by g1.genre_id, g2.genre_id;


#10


select mg1.genre_id, a.actor_id, count(*) AS count
from movie m2,actor a, role r,  movie_has_genre mg1 #δεν χρειαζεται να βαλουμε και genre αφου οι ταινιες που εππεστρεψε το σελεκτ ειναι 1ος μονο ειδους
where  m2.movie_id = mg1.movie_id and mg1.movie_id = m2.movie_id and
  m2.movie_id = r.movie_id and a.actor_id = r.actor_id and m2.movie_id not in #ηθοποιοι που παιζουν σε ταινιες με ενα σκηνοθετη με ενα ειδος



	(select m1.movie_id
	from movie m1, movie_has_director md1
	where m1.movie_id = md1.movie_id and md1.director_id not in 
    
    #skhno8etes me 1 eidos
		(select d.director_id
		from genre g, movie_has_genre mg, movie m , movie_has_director sk, director d
		where g.genre_id = mg.genre_id and m.movie_id = mg.movie_id and d.director_id = sk.director_id and sk.movie_id = m.movie_id
		group by d.director_id
		having count(distinct g.genre_id) = 1 # δε θέλουμε να μετράει 2 ταινίες comedy πχ σαν 2 είδη 
		)
        
	group by m1.movie_id, md1.director_id
    
        
	)

group by mg1.genre_id,  a.actor_id
order by mg1.genre_id, a.actor_id
;


