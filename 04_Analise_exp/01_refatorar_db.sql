
-- Quando criei o db usei SQalchemi para criar o db, ele criou as tabelas,
-- mas sem definir PK, FK e CONSTRAINS. Porem o SQLite não permite ALTER TABLE então a solução é renomar as tabelas 
-- criar tabelas  novas sem dados, depois migrar os dados para as tabelas criadas com as regras de negocio

PRAGMA foreign_keys = ON;
-- alterar nome de todas as tabelas para old
ALTER TABLE fato_gastos RENAME TO fato_gastos_old;
ALTER TABLE dim_categoria RENAME TO dim_categoria_old;
ALTER TABLE dim_responsaveis RENAME TO dim_responsaveis_old;
ALTER TABLE dim_subcategoria RENAME TO dim_subcategoria_old;

-- Criar e Migrar dados pra tabela dim_tipo nomalizada
ALTER TABLE dim_tipo RENAME TO dim_tipo_old;
CREATE TABLE dim_tipo (
    id_tipo BIGINT PRIMARY KEY,
    nome_tipo TEXT NOT NULL,
    
    CONSTRAINT UK_dim_tipo_nome_tipo 
        UNIQUE(nome_tipo)
);
INSERT INTO dim_tipo
SELECT * FROM dim_tipo_old;

-- Criar e Migrar dados pra tabela dim_tipo nomalizada
ALTER TABLE dim_categoria RENAME TO dim_categoria_old;
CREATE TABLE dim_categoria (
    id_categoria BIGINT PRIMARY KEY,
    nome_categoria TEXT NOT NULL,
    
    CONSTRAINT UK_dim_categoria_nome 
        UNIQUE(nome_categoria)
);
INSERT INTO dim_categoria 
SELECT id_categoria, nome_categoria FROM dim_categoria_old;

-- Criar Migrar dados pra tabela dim_subcategoria nomalizada
ALTER TABLE dim_subcategoria RENAME TO dim_subcategoria_old;

CREATE TABLE dim_subcategoria (
    id_subcategoria BIGINT PRIMARY KEY,
    nome_subcategoria TEXT NOT NULL,
    
    CONSTRAINT UK_dim_subcategoria_nome 
        UNIQUE(nome_subcategoria)
);

INSERT INTO dim_subcategoria 
SELECT id_subcategoria, nome_subcategoria FROM dim_subcategoria_old;

-- Criar Migrar dados pra tabela dim_responsaveis nomalizada
ALTER TABLE dim_responsaveis RENAME TO dim_responsaveis_old;

CREATE TABLE dim_responsaveis (
    id_responsavel BIGINT PRIMARY KEY,
    nome_responsavel TEXT NOT NULL,
    
    CONSTRAINT UK_dim_responsaveis_nome 
        UNIQUE(nome_responsavel)
);

INSERT INTO dim_responsaveis 
SELECT id_responsavel, nome_responsavel FROM dim_responsaveis_old;

-- Criar Migrar dados pra tabela fato nomalizada

ALTER TABLE fato_gastos RENAME TO fato_gastos_old;

CREATE TABLE fato_gastos (
    -- seus 9 campos...
    id BIGINT PRIMARY KEY,
    data DATETIME NOT NULL,
    competencia TEXT NOT NULL,
    id_responsavel BIGINT NOT NULL,
    descricao TEXT NOT NULL,
    valor FLOAT NOT NULL,
    id_categoria BIGINT NOT NULL,
    id_subcategoria BIGINT NOT NULL,
    id_tipo BIGINT NOT NULL,
    
    CONSTRAINT FK_fato_responsavel FOREIGN KEY (id_responsavel) REFERENCES dim_responsaveis(id_responsavel),
    CONSTRAINT FK_fato_categoria FOREIGN KEY (id_categoria) REFERENCES dim_categoria(id_categoria),
    CONSTRAINT FK_fato_subcategoria FOREIGN KEY (id_subcategoria) REFERENCES dim_subcategoria(id_subcategoria),
    CONSTRAINT FK_fato_tipo FOREIGN KEY (id_tipo) REFERENCES dim_tipo(id_tipo)
);
-- tiver que fazer um update pra migrar os dados , pq agora devido a restrição
-- não vai mais aceitar valores vazios
UPDATE fato_gastos_old
SET valor = 0.0
WHERE valor IS NULL;

INSERT INTO fato_gastos SELECT * FROM fato_gastos_old;

-- Agora excluir todas as tabelas antigas

DROP TABLE IF EXISTS dim_tipo_old;
DROP TABLE IF EXISTS dim_categoria_old;
DROP TABLE IF EXISTS dim_responsaveis_old;
DROP TABLE IF EXISTS dim_subcategoria_old;
DROP TABLE IF EXISTS fato_gastos_old;


