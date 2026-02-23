#%%
# 01_tratamento_orcamento.py
# Objetivo: transformar o arquivo OrcamentoV3.csv em uma tabela fato + dimensões normalizadas
# para depois carregar em um banco SQLite e consumir no Power BI.

import pandas as pd
from sqlalchemy import create_engine
# 1) Ler arquivo bruto de orçamento
df = pd.read_csv("../01_data/OrcamentoV3.csv", sep=",")

# Remover linhas sem data (registros incompletos)
df = df.dropna(subset=['data'])

# Remover coluna 'observacao' que não será usada na análise
df = df.drop(['observacao'], axis=1)

# 2) Limpar coluna 'valor' (remover R$, espaço, pontos e trocar vírgula por ponto)
df['valor'] = df['valor'].str.replace('[R$ ]', '', regex=True)
df['valor'] = df['valor'].str.replace('[.]', '', regex=True)
df['valor'] = df['valor'].str.replace('[,]', '.', regex=True)

# 3) Criar dimensão de responsáveis (valores únicos)
df_responsaveis = df[['responsavel']].drop_duplicates().reset_index(drop=True)

# Renomear coluna para deixar mais clara como dimensão
df_responsaveis.columns = ['nome_responsavel']

# Criar surrogate key sequencial (id_responsavel)
df_responsaveis['id_responsavel'] = range(1, len(df_responsaveis) + 1)

# Reordenar: PK primeiro, depois atributo descritivo
df_responsaveis = df_responsaveis[['id_responsavel', 'nome_responsavel']]


# criar a tabela de categoria
df_categoria = df[['categoria']].drop_duplicates().reset_index(drop=True)
df_categoria.columns = ['nome_categoria']
df_categoria['id_categoria'] = range(1,len(df_categoria)+1)
df_categoria = df_categoria [['id_categoria', 'nome_categoria']]
df_categoria

# criar a tabela subcategoria
df_subcategoria = df[['subcategoria']].drop_duplicates().reset_index(drop=True)
df_subcategoria.columns = ['nome_subcategoria']
df_subcategoria['id_subcategoria'] = range(1, len(df_subcategoria) + 1)
df_subcategoria = df_subcategoria[['id_subcategoria', 'nome_subcategoria']]
df_subcategoria

# criar a tabela tipo
df_tipo = df[['tipo']].drop_duplicates().reset_index(drop=True)
df_tipo.columns = ['nome_tipo']
df_tipo['id_tipo'] = range(1, len(df_tipo) + 1)
df_tipo = df_tipo[['id_tipo', 'nome_tipo']]
df_tipo

# 4) Criar dicionários de lookup: nome → id (usados para substituir texto pelos FKs)
dic_responsavel = dict(zip(df_responsaveis['nome_responsavel'], df_responsaveis['id_responsavel']))
dic_categoria = dict(zip(df_categoria['nome_categoria'], df_categoria['id_categoria']))
dic_subcat = dict(zip(df_subcategoria['nome_subcategoria'], df_subcategoria['id_subcategoria']))
dic_tipo = dict(zip(df_tipo['nome_tipo'], df_tipo['id_tipo']))


# 5) Substituir colunas textuais por chaves estrangeiras (normalização da fato)

df['id_categoria'] = df['categoria'].map(dic_categoria)
df['id_responsavel'] = df['responsavel'].map(dic_responsavel)
df['id_subcategoria'] = df['subcategoria'].map(dic_subcat)
df['id_tipo'] = df['tipo'].map(dic_tipo)

# 6) Converter coluna 'data' para tipo datetime 

df['data'] = pd.to_datetime(df['data'], format='%d/%m/%Y')

# 7) Definir tipos finais de cada coluna (schema da fato)

tipos = {
    "id": "int64",
    "competencia": "string",
    "responsavel": "string",
    "descricao": "string",
    "valor": "float64",
    "id_categoria": "int64",
    "id_responsavel": "int64",
    "id_subcategoria": "int64",
    "id_tipo": "int64"
}
df = df.astype(tipos)

# 8) Reordenar colunas da tabela fato
df = df[['id', 'data', 'competencia', 'id_responsavel', 'descricao', 'valor',
         'id_categoria', 'id_subcategoria', 'id_tipo']]
df.head(10)
#%%
# 9) conexão e criação do db

engine = create_engine(r"sqlite:///E:\repo_cursos\Proj_dados_financeiros\01_data\orcamento.db")

# Dimensões primeiro
df_responsaveis.to_sql('dim_responsaveis', engine, if_exists='replace', index=False)
df_categoria.to_sql('dim_categoria', engine, if_exists='replace', index=False)
df_subcategoria.to_sql('dim_subcategoria', engine, if_exists='replace', index=False)
df_tipo.to_sql('dim_tipo', engine, if_exists='replace', index=False)

# Fato por último
df.to_sql('fato_gastos', engine, if_exists='replace', index=False)

# Validações
print(pd.read_sql("SELECT COUNT(*) as registros FROM fato_gastos", engine))

engine.dispose()
# %%
