# ----- CONFIGURE YOUR EDITOR TO USE 4 SPACES PER TAB ----- #
import sys,os
sys.path.append(os.path.join(os.path.split(os.path.abspath(__file__))[0], 'lib'))
import pymysql

def connection():
    ''' User this function to create your connections '''    
    con = pymysql.connect(host='localhost', port=3306, user='root', passwd='eristef', db='movies') #update with your settings
    
    return con

def updateRank(rank1, rank2, movieTitle):

    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()

    
    try:
        float(rank1)
    except ValueError:
        return [("status",),("error",),]
    try:
        float(rank2)
    except ValueError:
        return [("status",),("error",),]

    rank1New = float(rank1)
    rank2New = float(rank2)

    if rank1New < 0 or rank1New > 10:
        return [("status",),("error : First rank is out of range",)]

    if rank2New < 0 or rank2New > 10:
        return [("status",),("error : Second rank is out of range",)]

    
    query1 = "SELECT * FROM movie m WHERE m.title = %s "

    cur.execute(query1, (movieTitle,))
    row = cur.fetchall()
    
    #μηκος της λιστας
    if len(row) > 1:
        return [("status",),("error : There is more than one movie",)]
    
    if len(row) == 0:
        return [("status",),("error:  No movie with this name is found",)]

    rankOfMovie = row[0][3]
    newRank = 0.0


    if rankOfMovie == None:
        newRank = (rank1New + rank2New)/2

    else:
        newRank = (rank1New + rank2New + rankOfMovie)/3

    query2 = "UPDATE movie m SET m.rank = %s WHERE m.title = %s"

    cur.execute(query2, (newRank, movieTitle))

    con.commit()
    return [("status",),("ok",),]


def colleaguesOfColleagues(actorId1, actorId2):

# Create a new connection
    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()

    # ελέγχουμε αν υπάρχει το actor_id1
    check1 = """
    SELECT *
    FROM actor a
    WHERE a.actor_id = %s
    """

    cur.execute(check1, (actorId1))
    res1 = cur.fetchall()

    if (len(res1)) == 0:
        return [("status",),("error: No actor with id1 found",),]

    # ελέγχουμε αν υπάρχει το actor_id2

    cur.execute(check1, (actorId2))
    res2 = cur.fetchall()

    if (len(res2)) == 0:
        return [("status",),("error: No actor with id2 found",),]


    #επιστρέφει τις κοινές ταινίες του κάθε c - d που πληρούν τις προυποθέσεις του ερωτήματος
    query3 = """
        select m.title, c.actor_id, d.actor_id
        from role c , role d, movie m 
        ##### οι ηθοποιοί c και d να μην ειναι οι a , b
        where c.actor_id <> d.actor_id and c.actor_id <> %s and c.actor_id <> %s and d.actor_id <> %s and d.actor_id <> %s
            ##### να παίζουν στην ίδια ταινία οι c - d
            and c.movie_id = d.movie_id and m.movie_id = c.movie_id
            ##### ο  actor c να ειναι μέσα στο σύνολο όλων των συνεργατών του a
            and c.actor_id in
            (select r1.actor_id
                from role a , role r1
                where a.actor_id = %s and r1.actor_id <>a.actor_id and r1.movie_id = a.movie_id
            )
            ##### ο  actor d να ειναι μέσα στο σύνολο όλων των συνεργατών του b
            and d.actor_id in
            (select r2.actor_id
                from role b , role r2
                where b.actor_id = %s and r2.actor_id <>b.actor_id and r2.movie_id = b.movie_id
            )   
    """




    cur.execute(query3, (actorId1, actorId2, actorId1, actorId2, actorId1, actorId2))
    res = cur.fetchall() #ολες οι κοινες  ταινιες των c, d που πληρουν τις προυποθεσεις


    if (len(res)) == 0:
        return [("status",),("error: No movies found",),]
        
    #εξαιτίας της διαφορετικοτητας του συνδυασμου(c,d) απο τον (d,c) - πρέπει να τους ελεγχουμε και τους δυο γιατι μπορει 
    #ο c πχ να μην εχει ταινία κοινή με τον α αλλα να έχει ο b- προκύπτουν αρκετά διπλότυπα αποτελέσματα (ίδιες ταινίες με c_id - d_id σε διαφορετική σειρά)
    #Aυτό το πετυχαίνουμε βάζοντας τα ονόματα  των ηθοποιών σε sorted tuple έτσι ωστε ο c-d == d-c και τα προσθέτουμε 
    #στο set(λόγω της μοναδικότητας του set δεν θα βάλει ίδια αποτελεσματα)

    uniqueRes = set()
    for row in res:
        movieTitle = row[0]
        actorPair = tuple(sorted([row[1], row[2]]))
        uniqueRes.add((movieTitle, actorPair)) # εισαγουμε ενα tuple που αποτελειται απο το movietitle και το tuple actorpairs: tuple(movieTitle, tuple(actorPair))


    actor1 = actorId1 
    actor2 = actorId2

    header = ("movieTitle", "colleagueOfActor1", "colleagueOfActor2", "actor1","actor2")

    li = [header]
    
    for row in uniqueRes:
        movieTitle = row[0]
        colleagueOfActor1 = row[1][0] #πρωτο στοιχειο εσωτερικου tuple
        colleagueOfActor2 = row[1][1] #δευτερο στοιχειο εσωτερικου tuple
        li.append((movieTitle, colleagueOfActor1, colleagueOfActor2, actor1, actor2))

    con.commit()
    return(li)        



def actorPairs(actorId):

   # Create a new connection
    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()

    check = """
    SELECT *
    FROM actor a
    WHERE a.actor_id = %s
    """

    cur.execute(check, (actorId))
    res = cur.fetchall()

    if (len(res)) == 0:
        return [("status",),("error : No actor with id found",),]


    #οι ηθοποιοι που σε κοινες ταινιες με τον δοθέντα ηθοποιο εχουν τουλαχιστον 7 ειδη
    query1 = """
    select r.actor_id
    from role r, movie_has_genre mg
    where mg.movie_id = r.movie_id and r.movie_id IN 

        (select r1.movie_id
        from role r1
        where r1.actor_id = %s and r1.actor_id <> r.actor_id)

    group by r.actor_id
    having count(distinct(mg.genre_id)) >= 7


    """
    cur.execute(query1, (actorId))
    actors = cur.fetchall()


    #επιστρεφουμε ολα τα ειδη που εχει παιξει ο actorId σε ΑΤΟΜΙΚΕΣ ταινιες
    #δηλαδη σε ταινιες που ΔΕΝ εχει παιξει και ο συγκεκριμενος ηθοποιος που εξεταζουμε καθε φορα
    query2 = """
    SELECT DISTINCT mg.genre_id
    FROM movie m , movie_has_genre mg, role r
    WHERE r.movie_id = m.movie_id and mg.movie_id = m.movie_id and r.actor_id= %s and r.movie_id NOT IN
        (select m1.movie_id
        from movie m1, role r1, role r2
        where m1.movie_id = r1.movie_id and m1.movie_id = r2.movie_id and r1.movie_id = r2.movie_id 
            and r1.actor_id = %s and r2.actor_id = %s)
    """
    

    header = ("actor",)

    li = [header]

    for actor in actors:
        
        actor_id = actor[0]
        
        #επιστρεφει τα ειδη του συγκριμενου ηθοποιου ΟΧΙ ομως στις κοινες ταινιες με τον δοθέντα από την είσοδο ηθοποιό
        query3 = """
        select distinct(mg.genre_id)
        from role r, movie_has_genre mg
        where mg.movie_id = r.movie_id and r.actor_id = %s and r.movie_id not in 

            (select DISTINCT(m.movie_id)
            from movie m, role r1
            where m.movie_id = r1.movie_id and r1.actor_id = %s
            )
        """

        cur.execute(query3, (actor_id, actorId))
        tempGenres = cur.fetchall() # τα genres των ταινιων του συγκεκριμενου ηθοποιου actor_id

        
        #τα ειδη των ΑΤΟΜΙΚΩΝ ταινιων του δοθεντος ηθοποιου actorId, δηλαδη που
        #δεν εχει παιξει ο actor_id μαζι του
        cur.execute(query2, (actorId, actorId, actor_id))
        genresOfGivenActor = cur.fetchall()


        #αν το set με τα είδη απο ταινίες που παίζει μόνος του ο ηθοποιός, 
        #δεν έχει κοινά στοιχεία με το set των ειδών που παίζουν μαζί κρατάμε τον ηθοποιό αυτον
        commonElements = set(genresOfGivenActor) & set(tempGenres)
        hasCommonElement = len(commonElements)

        if hasCommonElement > 0:
            continue

        else:
            li.append((actor))

    return (li)

def selectTopNactors(n):

    # Create a new connection
    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()

    try:
        int(n)
    except ValueError:
        return [("status",),("error",),]


    n1 = int(n)
    if n1 < 0:
        return [("status",),("error : N cannot be negative",),]

    #βρισκουμε τον αριθμο των ειδων
    query = "SELECT * FROM genre g "
    cur.execute(query)
    genres = cur.fetchall()

    count = len(genres)

    header = ("genre", "actorId", "count")
    li = [header]

    for i in genres:
        gId = i[0]

        #βρισκει για το συγκεκριμενο ειδος τον αριθμο εμφανισεων καθε ηθοποιου στο ειδος αυτο
        #τα εμφανιζει κατα φθινουσα σειρα εμφανισεων
        #πχ για Action ο πρωτος θα εχει 7 εμφανισεις, ο δευτερος 4 κοκ
        query1 = """
        SELECT g.genre_name, r.actor_id, COUNT(mg.movie_id) AS count
        FROM genre g, role r, movie m, movie_has_genre mg
        WHERE g.genre_id = mg.genre_id and mg.movie_id = m.movie_id 
	        and r.movie_id = m.movie_id and g.genre_id = %s
        GROUP BY g.genre_id, r.actor_id
        ORDER BY g.genre_name, count DESC
        """

        cur.execute(query1, gId)
        fetched = cur.fetchall()

        #θα κρατησουμε τις πρωτες n πλειαδες απο καθε συνολο που επιστρεφει το query 
        #και θα τις αποθηκευσουμε στη τελικη λιστα li
        if fetched:
            for j in range(n1):
                toInsert = fetched[j]
                li.append(toInsert)

    con.commit()

    return (li)

def traceActorInfluence(actorId):
    # Create a new connection
    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()


    return [("influencedActorId",),]