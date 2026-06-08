
//Визначення супервузлів

// Знайти топ-15 вузлів із найбільшою кількістю зв'язків незалежно від типу
MATCH (n)
WITH n, size((n)-[]-()) AS degree
ORDER BY degree DESC
LIMIT 15
RETURN labels(n)[0] AS node_type,
       coalesce(n.title, n.name, toString(n.userId)) AS node_name,
       degree;

// Окремо переглянути на розріз по найпопулярніших фільмах
MATCH (m:Movie)
WITH m, size((m)<-[:RATED]-()) AS rating_count
ORDER BY rating_count DESC
LIMIT 5
RETURN m.title, rating_count;

// Окремо переглянути жанри
MATCH (g:Genre)
WITH g, size((g)<-[:HAS_GENRE]-()) AS movies_in_genre
ORDER BY movies_in_genre DESC
LIMIT 5
RETURN g.name, movies_in_genre;
