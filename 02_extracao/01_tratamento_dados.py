#%%

import pandas as pd

df = pd.read_csv("../01_data/dados_financas.csv", sep=";")
df.shape
df.tail(10)

#  Drop linhas sem nome
df = df.dropna(subset=['nome'])
df.shape

# Formata Competencia para mm.YYYY
df = df.copy()
df['Competencia'] = pd.to_datetime(df['Competencia'], dayfirst=True, errors='coerce')
df['Competencia'] = df['Competencia'].dt.strftime('%m.%Y')


# Concat desc
df['descricao'] = df['descricao'].fillna('')
df['desc'] = df['nome'] + (' ') + df['descricao']

# excluir as colunas que não serão usadas
df = df.drop(['nome','descricao'],axis=1)


#  reordenar as colunas no formato correto.
df = df[['Data', 'Competencia', 'Responsavel', 'desc','Valor']]
print(df.columns)

# Limpa Valor: remove ., para float
df['Valor'] = df['Valor'].str.replace('.', '', regex=False)
df['Valor'] = df['Valor'].fillna(0)

# Normaliza acentos
df['desc'] = df['desc'].str.replace('[áàãâäÁÀÃÂÄ]', 'a', regex=True)
df['desc'] = df['desc'].str.replace('[éèêëÉÈÊË]', 'e', regex=True)
df['desc'] = df['desc'].str.replace('[íìîïÍÌÎÏ]', 'i', regex=True)
df['desc'] = df['desc'].str.replace('[óòõôöÓÒÕÔÖ]', 'o', regex=True)
df['desc'] = df['desc'].str.replace('[úùûüÚÙÛÜ]', 'u', regex=True)
df['desc'] = df['desc'].str.replace('[çÇ]', 'c', regex=True)

#exportar 
df.to_excel('dados_financas_tratados.xlsx', index=False)
