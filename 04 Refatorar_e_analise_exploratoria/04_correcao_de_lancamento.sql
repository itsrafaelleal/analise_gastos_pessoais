
-- Durante a analise exploratorio encontrei 
-- alguns lançamentos errados

SELECT * 
FROM fato_gastos f
INNER JOIN dim_categoria c
ON f.id_categoria = c.id_categoria
INNER JOIN dim_subcategoria s
ON f.id_subcategoria = s.id_subcategoria
WHERE descricao LIKE '%carro%';

-- Correção dos lançamentos

UPDATE fato_gastos 
SET id_subcategoria = 3 
WHERE descricao LIKE '%carro%';

UPDATE fato_gastos 
SET id_subcategoria = 3 
WHERE id = 48;

UPDATE fato_gastos 
SET id_subcategoria = 3 
WHERE id = 63;

UPDATE fato_gastos 
SET id_subcategoria = 3 
WHERE id = 85;
