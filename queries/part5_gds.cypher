
// 5.1 PAGERANK НА ГРАФІ ФІЛЬМІВ

// 1 Матеріалізація ребер фільм-фільм через спільних користувачів
MATCH (m1:Movie)<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE r1.rating >= 4 AND r2.rating >= 4 AND id(m1) < id(m2)
WITH m1, m2, count(u) AS weight
WHERE size([(m1)<-[:RATED]-() | 1]) > 20
  AND size([(m2)<-[:RATED]-() | 1]) > 20
WITH m1, m2, weight
ORDER BY weight DESC
LIMIT 50000
MERGE (m1)-[co:CO_RATED]-(m2)
SET co.weight = weight;

// 2 Створення проєкції графа фільмів у пам'яті GDS
CALL gds.graph.project(
  'movieGraph',
  'Movie',
  { CO_RATED: { orientation: 'UNDIRECTED', properties: 'weight' } }
)
YIELD graphName, nodeCount, relationshipCount;

// 3 Запуск алгоритму PageRank (стрімінг результатів)
CALL gds.pageRank.stream('movieGraph', {
  relationshipWeightProperty: 'weight'
})
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS movie, score
RETURN movie.title AS title, score
ORDER BY score DESC
LIMIT 15;

// 4 Видалення проєкції та тимчасових ребер матеріалізації
CALL gds.graph.drop('movieGraph');
MATCH ()-[co:CO_RATED]-() DELETE co;

// 5.2/5.3 LOUVAIN ТА DIJKSTRA (ГРАФ КОРИСТУВАЧІВ)

// Крок 1: Матеріалізація ребер користувач-користувач через спільні фільми
MATCH (u1:User)-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User)
WHERE r1.rating >= 4 AND r2.rating >= 4 AND id(u1) < id(u2)
WITH u1, u2, count(m) AS weight
WITH u1, u2, weight
ORDER BY weight DESC
LIMIT 50000
MERGE (u1)-[sim:SIMILAR]-(u2)
SET sim.weight = weight;

// 2 Створення проєкції графа користувачів у пам'яті GDS
CALL gds.graph.project(
  'userGraph',
  'User',
  { SIMILAR: { orientation: 'UNDIRECTED', properties: 'weight' } }
)
YIELD graphName, nodeCount, relationshipCount;

// 3 Запуск алгоритму Louvain із записом ID кластера у вузли User
CALL gds.louvain.write('userGraph', {
  relationshipWeightProperty: 'weight',
  writeProperty: 'communityId'
})
YIELD communityCount, modularity;

// 4 Запуск алгоритму Дейкстри
MATCH (source:User {userId: 1}), (target:User {userId: 50})
CALL gds.shortestPath.dijkstra.stream('userGraph', {
  sourceNode: source,
  targetNode: target
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN [node in nodes(path) | node.userId] AS path_user_ids,
       length(path) AS hop_count;

// 5 Видалення проєкції графа користувачів з пам'яті GDS
CALL gds.graph.drop('userGraph');
