
-- Confirmar que o ETL funcionou (sem nulos, FKs corretas, sem duplicatas)

-- Contar total de registros na tabela fato (fato_gastos)
SELECT COUNT(id)
FROM fato_gastos

-- Contar total de registros na tabela fato Verificar valores nulos nas colunas principais 
--(valor, data, descricao)

SELECT 
    COUNT(*) as total_registros,
    SUM(CASE WHEN valor IS NULL THEN 1 ELSE 0 END) as nulos_valor,
    SUM(CASE WHEN data IS NULL THEN 1 ELSE 0 END) as nulos_data,
    SUM(CASE WHEN descricao IS NULL THEN 1 ELSE 0 END) as nulos_descricao
FROM fato_gastos;

-- verificar se tem FK sem correspondencia
SELECT 'responsavel' AS dimensao, COUNT(*) AS registros_sem_dim
    FROM fato_gastos f
    LEFT JOIN dim_responsaveis r ON f.id_responsavel = r.id_responsavel
    WHERE r.id_responsavel IS NULL

    UNION ALL

    SELECT 'categoria', COUNT(*)
    FROM fato_gastos f
    LEFT JOIN dim_categoria c ON f.id_categoria = c.id_categoria
    WHERE c.id_categoria IS NULL

    UNION ALL

    SELECT 'tipo', COUNT(*)
    FROM fato_gastos f
    LEFT JOIN dim_tipo c ON f.id_tipo = c.id_tipo
    WHERE c.id_tipo IS NULL

    UNION ALL

    SELECT 'subcategoria', COUNT(*)
    FROM fato_gastos f
    LEFT JOIN dim_subcategoria t ON f.id_subcategoria = t.id_subcategoria
    WHERE t.id_subcategoria IS NULL;

-- Verificar duplicatas na fato (mesmo ID + data)

SELECT id, data, COUNT(*) AS quantidade
    FROM fato_gastos
    GROUP BY id, data
    HAVING COUNT(*) > 1;
