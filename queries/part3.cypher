
//Базові запити

// Запит 1. Знайти всі фільми жанру «Thriller» із середнім рейтингом вище 4.0
MATCH (g:Genre {name: 'Thriller'})<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-(u:User)
WITH m, avg(r.rating) AS avg_rating
WHERE avg_rating > 4.0
RETURN m.title AS movie, avg_rating
ORDER BY avg_rating DESC;

// Запит 2. Знайти користувачів, які поставили оцінку 5 більш ніж 50 фільмам
MATCH (u:User)-[r:RATED {rating: 5}]->(m:Movie)
WITH u, count(m) AS five_star_count
WHERE five_star_count > 50
RETURN u.userId, five_star_count
ORDER BY five_star_count DESC;

//Середні запити

// Запит 3. Знайти фільми, які обидва користувачі (userId=1 і userId=2) оцінили високо (≥ 4)
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User {userId: 2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.title AS movie, r1.rating AS user1_rating, r2.rating AS user2_rating;

// Запит 4. Знайти жанри, чиї фільми стабільно отримують високі оцінки
MATCH (g:Genre)<-[:HAS_GENRE]-(:Movie)<-[r:RATED]-(:User)
WITH g, avg(r.rating) AS avg_rating, count(r) AS rating_count
RETURN g.name AS genre, avg_rating, rating_count
ORDER BY avg_rating DESC;

//Складні запити

// Запит 5. Колаборативна фільтрація (Рекомендації для userId=1)
MATCH (u1:User {userId: 1})-[r1:RATED]->(m1:Movie)<-[r2:RATED]-(u2:User)
WHERE r1.rating >= 4 AND r2.rating >= 4
// Знаходимо фільми, які високо оцінили ці "схожі" користувачі
MATCH (u2)-[r3:RATED]->(m2:Movie)
WHERE r3.rating >= 4
  AND NOT (u1)-[:RATED]->(m2) // Відкидаємо те, що u1 вже бачив
WITH m2, count(u2) AS recommendation_strength
RETURN m2.title AS recommended_movie, recommendation_strength
ORDER BY recommendation_strength DESC
LIMIT 10;

// Запит 6. Найкоротший ланцюжок зв’язку між двома користувачами
MATCH p = shortestPath((u1:User {userId: 1})-[:RATED*..10]-(u2:User {userId: 3}))
RETURN p, length(p) AS path_length;