
//Створення індексів

CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE u.userId IS UNIQUE;
CREATE CONSTRAINT movie_id IF NOT EXISTS FOR (m:Movie) REQUIRE m.movieId IS UNIQUE;
CREATE CONSTRAINT genre_name IF NOT EXISTS FOR (g:Genre) REQUIRE g.name IS UNIQUE;

//Завантаження вузлів

// Користувачі
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.userId)})
SET u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = toInteger(row.occupation);

// Фільми та жанри
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET m.title = row.title
WITH m, row
UNWIND split(row.genres, '|') AS genreName
MERGE (g:Genre {name: genreName})
MERGE (m)-[:HAS_GENRE]->(g);

// Завантаження ребер

CALL apoc.periodic.iterate(
    "LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row RETURN row",
    "MATCH (u:User {userId: toInteger(row.userId)})
     MATCH (m:Movie {movieId: toInteger(row.movieId)})
     MERGE (u)-[r:RATED]->(m)
     SET r.rating = toInteger(row.rating)",
    {batchSize: 10000, iterateList: true, parallel: false}
);

//Перевірка

MATCH (u:User) RETURN count(u) AS users;
MATCH (m:Movie) RETURN count(m) AS movies;
MATCH ()-[r:RATED]->() RETURN count(r) AS ratings;