# 🎬 Movie Star – Relational Database Design & SQL Analytics

## Project Overview

**Movie Star** is a relational database management project created for the **Design and Use of Databases** course. The project is split into two parts:

1. **Part 1: Conceptual & Relational Design:** Entity-Relationship (ER) modeling and schema generation for an interactive film-directing simulation game.
2. **Part 2: SQL Analytics & Data Querying:** Execution of complex relational SQL queries on a structured movie database (`movies` schema).


## Part 1: Relational Database Design

The first part models a simulation game where players act as movie directors managing actors, AI-generated screenplays, filming sets, sponsorships, and festival entries.

### Key Conceptual Features & Constraints
* **Production Rules:** Enforces specialized subtyping (`Local` vs. `International` movies) where domestic films can share sets within their home country, while international films feature strictly isolated sets.
* **AI Screenplay Tracing:** Supports AI script generation with linked text segments and recursive tracking.
* **Actor Progression:** Tracks physical, mental, and technical actor attributes with numerical ratings, allowing technical skills to evolve through training programs.
* **Competitions & Pantheon:** Models festival entries, awards, points, director friendships, and social media likes to build global high-score leaderboards ("Pantheon").



## Part 2: SQL Analytics (`movies` Database)

The second part focuses on querying a populated relational movie database (`movies` schema) comprising actors, directors, movies, genres, and their junction tables (`role`, `movie_has_genre`, `movie_has_director`).

> **Note:** Per assignment requirements, explicit `JOIN` operations (e.g., `INNER JOIN`, `LEFT JOIN`) were restricted, requiring all table relationships to be solved using implicit joins (e.g., Cartesian products in the `FROM` clause with `WHERE` filtering conditions) and subqueries.

### Database Schema Summary
* **`actor`** (`actor_id`, `first_name`, `last_name`, `gender`)
* **`director`** (`director_id`, `first_name`, `last_name`)
* **`movie`** (`movie_id`, `title`, `year`, `rank`)
* **`genre`** (`genre_id`, `genre_name`)
* **Junction Tables:** `role`, `movie_has_genre`, `movie_has_director`

### Key Query Highlights
The provided SQL script answers 10 complex analytical questions, including:
* Multi-genre director aggregation and cross-genre filtering.
* Conditional existence checking (e.g., verifying 1995 "Drama" films without control-flow statements like `IF`/`CASE`).
* Director co-direction analytics and single-genre restriction filtering.
