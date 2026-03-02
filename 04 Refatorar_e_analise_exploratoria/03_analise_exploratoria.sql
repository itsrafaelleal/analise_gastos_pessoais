

-- BLOCO 2 = ANÁLISE DESCRITIVA GERAL
SELECT SUM(valor)
FROM fato_gastos;

-- TOP 10 mes com mais gastos 
SELECT f.competencia, SUM(f.valor) as total
    FROM fato_gastos f
    GROUP BY f.competencia
    ORDER BY total DESC
    LIMIT 10;

-- Catorias com mais gastos
SELECT c.nome_categoria, SUM(valor) as total
    FROM fato_gastos f
    INNER JOIN dim_categoria c
    ON f.id_categoria = c.id_categoria
    GROUP BY c.nome_categoria
    ORDER BY total DESC;

-- distribuição por tipo, media mes e percentual
SELECT t.nome_tipo, SUM(valor) as total, ROUND(SUM(valor)/36, 2) as media_mes,
ROUND( (SUM(f.valor) * 100.0) / (SELECT SUM(valor) FROM fato_gastos), 2 ) AS percentual
    FROM fato_gastos f
    INNER JOIN dim_tipo t
    ON f.id_tipo = t.id_tipo
    GROUP BY t.nome_tipo
    ORDER BY total DESC;


-- distribuição por categoria e tipo
SELECT c.nome_categoria, t.nome_tipo, SUM(valor) as total
    FROM fato_gastos f
    INNER JOIN dim_categoria c
    ON f.id_categoria = c.id_categoria
    INNER JOIN dim_tipo t
    ON f.id_tipo = t.id_tipo
    GROUP BY c.nome_categoria, t.nome_tipo
    ORDER BY total DESC;



-- GRUPO 2 OMGEOUTLIERS E ANOMALIAS -- Objetivo: Identificar gastos suspeitos
-- Top 10 maiores gastos únicos (maiores valores individuais)
SELECT f.descricao,c.nome_categoria, f.valor,
    ROW_NUMBER() OVER (ORDER BY f.valor DESC) AS posicao
    FROM fato_gastos f
    INNER JOIN dim_categoria c
    ON f.id_categoria = c.id_categoria
    ORDER BY f.valor DESC
    LIMIT 10;

-- Gastos acima da 4x acima da média por subcategoria ( procurando outlier)
-- // descobri 5 itens cagorizados errado ( fiz os updates para resolver).
WITH MEDIA AS(
    SELECT c.id_subcategoria as id_subcategoria, c.nome_subcategoria, 
    ROUND(AVG(f.valor),2) as media
    FROM fato_gastos f
    INNER JOIN dim_subcategoria c
    ON f.id_subcategoria = c.id_subcategoria
    GROUP BY c.id_subcategoria , c.nome_subcategoria
)
SELECT f.id, f.descricao, m.nome_subcategoria, f.valor, m.media
FROM MEDIA m
INNER JOIN fato_gastos f
ON f.id_subcategoria = m.id_subcategoria
WHERE f.valor > (4 * m.media)
ORDER BY (f.valor - m.media ) DESC;

-- Datas inconsistentes , data futura ou ano menor que 2023
SELECT *
    FROM fato_gastos f
    WHERE DATE(f.data) > DATE('now') 
    OR CAST(strftime('%Y', f.data) AS INTEGER) < 2023;

-- BLOCO 3: CONCENTRAÇÃO DOS GASTOS
-- Objetivo: Pareto 80/20
-- 80% dos gastos estão em quais subcategorias? (soma acumulada)

SELECT nome_subcategoria, sum(valor) as total, 
    ROUND( (SUM(valor) * 100.0) / (SELECT SUM(valor) FROM fato_gastos), 2 ) AS percentual
    FROM fato_gastos 
    INNER JOIN dim_subcategoria
    ON fato_gastos.id_subcategoria = dim_subcategoria.id_subcategoria
    GROUP BY nome_subcategoria
    ORDER BY percentual DESC;


-- Subcategorias com mais transações (não valor, mas quantidade), por ano
SELECT 
    s.nome_subcategoria,    
    COUNT(CASE WHEN strftime('%Y', f.data) = '2023' THEN 1 END) AS qtd_2023,
    COUNT(CASE WHEN strftime('%Y', f.data) = '2024' THEN 1 END) AS qtd_2024,
    COUNT(CASE WHEN strftime('%Y', f.data) = '2025' THEN 1 END) AS qtd_2025,
    COUNT(f.id) AS total
    FROM fato_gastos f
    INNER JOIN dim_subcategoria s
    ON f.id_subcategoria = s.id_subcategoria
    GROUP BY s.nome_subcategoria
    ORDER BY total DESC;

-- Subcategoria somando valores, por ano
WITH gastos_ano AS (
    SELECT 
        s.nome_subcategoria,
        strftime('%Y', f.data) AS ano,
        f.valor
    FROM fato_gastos f
    INNER JOIN dim_subcategoria s ON f.id_subcategoria = s.id_subcategoria
)
SELECT 
    nome_subcategoria,
    ROUND(SUM(CASE WHEN ano = '2023' THEN valor ELSE 0 END), 2) AS 2023,
    ROUND(SUM(CASE WHEN ano = '2024' THEN valor ELSE 0 END), 2) AS 2024,
    ROUND(SUM(CASE WHEN ano = '2025' THEN valor ELSE 0 END), 2) AS 2025,
    ROUND(SUM(valor), 2) AS total
FROM gastos_ano
GROUP BY nome_subcategoria
ORDER BY total DESC;










