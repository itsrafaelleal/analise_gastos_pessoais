#%%

import pandas as pd

df = pd.read_csv("./data/dados_financas4.csv", sep=";")
df.shape

#%%
df.tail(10)

#%% se o nome é vazio a linha não deveria existir

df = df.dropna(subset=['nome'])
df.shape
#%% converter a coluna competencia para data e transformar em mês.ano (formato 01.2023)

df = df.copy()
df['Competencia'] = pd.to_datetime(df['Competencia'], dayfirst=True, errors='coerce')
df['Competencia'] = df['Competencia'].dt.strftime('%m.%Y')
df.tail(10)

#%% substituir os NA da descrição por vazio para depois concatenar
df['descricao'] = df['descricao'].fillna('')
df.tail(10)

#%% concater as duas colunas para criar a descrição
df['desc'] = df['nome'] + (' ') + df['descricao']
df.tail(10)
#%% excluir as colunas que não serão usadas

df = df.drop(['nome','descricao'],axis=1)
df.tail(10)

#%%  reordenar as colunas no formato correto.

df = df[['Data', 'Competencia', 'Responsavel', 'desc','Valor']]
print(df.columns)

#%% retirar ponto  do valores numericos e oque tiver NA vai virar 0

df['Valor'] = df['Valor'].str.replace('.', '', regex=False)
df['Valor'] = df['Valor'].fillna(0)
#%% retirar caracteres que geram erro no excel

df['desc'] = df['desc'].str.replace('[áàãâäÁÀÃÂÄ]', 'a', regex=True)
df['desc'] = df['desc'].str.replace('[éèêëÉÈÊË]', 'e', regex=True)
df['desc'] = df['desc'].str.replace('[íìîïÍÌÎÏ]', 'i', regex=True)
df['desc'] = df['desc'].str.replace('[óòõôöÓÒÕÔÖ]', 'o', regex=True)
df['desc'] = df['desc'].str.replace('[úùûüÚÙÛÜ]', 'u', regex=True)
df['desc'] = df['desc'].str.replace('[çÇ]', 'c', regex=True)



#%%
df.tail(18)

#%%

df.to_excel('dados_financas_tratados.xlsx', index=False)
