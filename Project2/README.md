## Part 2: SQL Queries

The second module of the project focuses on querying a relational movie database (simplified version of `movies` database schema).

### Database Schema

* `actor` (`actor_id`, `first_name`, `last_name`, `gender`, `film_count`)
* `director` (`director_id`, `first_name`, `last_name`)
* `movie` (`movie_id`, `title`, `year`, `rank`)
* `genre` (`genre_id`, `genre_name`)
* `role` (`movie_id`, `actor_id`, `role`)
* `movie_has_genre` (`genre_id`, `movie_id`)
* `movie_has_director` (`movie_id`, `director_id`)

---
!ER Diagram](ER.png)

