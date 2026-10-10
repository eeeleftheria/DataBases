# 🎬 Movie Star – Relational Database Design

##  Overview

**Movie Star** is a relational database schema designed for an interactive film-directing simulation game. The database manages game instances, directors, actors with dynamic skill profiles, AI-generated screenplays, sets across global locations, sponsors, and festival competitions.

## Core Entity-Relationship Requirements & Design Constraints

### 1. Game State Persistence & Multi-Session Architecture
* **Static vs. Dynamic Data:** Static baseline records (actor base entities, countries) remain immutable across all games, whereas session-specific attributes (skill ratings, awards, score leaderboards) update dynamically per active game instance.
* **Director Scope:** Directors belong to a specific game instance and can establish self-referencing relationships with other directors (role models/admirers).

### 2. Film Production & Set Allocation Rules
* **Production Categorization:** Movies are categorized as either **Domestic** or **International**.
* **Set Isolation & Location Sharing:** 
  * *Domestic movies* have a primary home country and can share filming sets with other domestic films in that country.
  * *International movies* can shoot across multiple countries, but their filming sets are strictly unshared and isolated.
* **Production Quotas:** A director can manage at most **1 Domestic** and **1 International** film per active game instance.

### 3. AI-Generated Screenplays
* **Recursive Script Tracing:** Screenplays are created by an AI engine and consist of sequential text segments. Each segment recursively references its preceding segment to maintain narrative flow.

### 4. Dynamic Actor Skill System & Contracts
* **Attribute Normalization:** Actor traits are categorized into **Physical**, **Mental**, and **Technical** categories, with numerical quality scores assigned to each trait.
* **Skill Evolution:** Technical skills dynamically upgrade when actors participate in training modules over specified time intervals.
* **Multi-Movie Contracts:** Contracts link actors to movies with explicit start/end dates and annual compensation, allowing actors to hold overlapping contracts across multiple films.

### 5. Festivals, Social Dynamics & Leaderboards
* **Competitions & Statistics:** Movies compete in international festivals, recording category performance statistics and earning ability points.
* **Social Engagement:** Tracks friendships between directors on social network pages, as well as movie likes. Social popularity directly impacts director skill points, driving high-score rankings in the game's hall of fame ("Pantheon").

## Key Design & Architecture Decisions

This relational schema reflects the following design choices:

* **Director Role Models (`Director_model` Self-Relationship):**
  * Implemented as an $N:M$ self-referencing table (`Director_model`) linking `Director_id` to `Director_is_model_ID` to capture mentorship dynamics between directors.

* **Inheritance & Specialized Movie Types (`Local_movie` & `International_movie`):**
  * Designed an **ISA inheritance hierarchy** derived from the base `Movie` entity, using `Movie_ID` as a Foreign Key in both child entities (`Local_ID` and `International_ID`).
  * **Shared Attributes:** General properties (title, year, duration, genre/scenario, primary language/country) reside in the base `Movie` table to avoid duplication.
  * **Set & Country Rules:**
    * `Local_movie`: Connects to `Set_of_movie` via `local_has_Set` ($1:N$), allowing sets from the same country to be reused across domestic films.
    * `International_movie`: Connects directly to `Set_of_movie` via `International_movie_ID` ($1:N$), representing isolated filming sets across different shooting countries.
  * Enforces the game rule limiting a director to at most **1 local** and **1 international** movie per session (`local_Movie_id` and `International_Movie_id` attributes on `Director`).

* **AI Screenplay & Script Structure (`AI_machine`, `Scenario`, `Script`):**
  * The `AI_machine` produces a `Scenario` (holding a category/genre).
  * A `Scenario` contains multiple `Script` segments. Sequential scripts are linked via a self-referencing recursive foreign key (`Previous_Script_code`) within the `Script` table.
  * Each `Movie` references its chosen `Scenario_ID`.

* **Actor Roles & Contracts (`Actor_plays_a_role_in_a_movie(contract)`):**
  * Actor participation is modeled as an $N:M$ relationship between `Actor` and `Movie`.
  * The relationship table explicitly stores the **role type** (`Type_of_role` ENUM: protagonist, supporting role, extra, etc.) as well as the **contract parameters** (`Start_date`, `Expiration_date`, `Annual_salary`).

* **Categorized Actor Traits & Skill Training:**
  * **Physical & Mental Characteristics:** Stored directly inside the `Actor` entity with individual quality scores (`Height`, `Weight`, `Athletic`, `Imaginative`, `Emotional_intelligence`, `Body_language`, `Articulation`, etc.).
  * **Technical Attributes:** Normalized into the `Technical_characteristics` entity and connected via `Actor_has_characteristics` ($N:M$) with custom ratings (`Quality_of_characteristic_for_this_actor`).
  * **Training Modules:** The `Actor_takes_part_in_training_course` table maps actors to `Training_course` entries, explicitly tracking the targeted technical skill enhanced by the course (`Technical_characteristic_that_is_enhanced_by_course`).

* **Dual Competition Relationships & Social Dynamics:**
  * **Participation & Statistics:** The `Movie_participates_in_competition(and_statistics)` table tracks entries and category nominations (`Number_of_nominations_for_different_awards`).
  * **Awards & Points:** The `Movie_wins_an_award_in_competition` table records wins, award types (`Name_of_award`), and earned skill points (`Points`).
  * **Social Network Uploads:** The `Movie_is_uploaded_in_Social_media_page_of_a_Competition` table logs festival social media pages and movie likes (`Likes`).

* **Leaderboards / Pantheon:**
  * Overall director rankings ("Pantheon") are derived at the application layer by aggregating total award points and social media engagement (`Likes`).

* **Festival Friendship Tracking (`Directors_of_a_competition_are_friends`):**
  * Implemented via a **ternary relationship** (`Directors_of_a_competition_are_friends`) combining two directors, a competition, and the player account to determine existing or new social friendships during specific festival events.

