# Análise de Gastos Pessoais - ETL Completo (Python + SQLite + Power BI)

[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Pandas](https://img.shields.io/badge/Pandas-2.2.0-150458?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![SQLite](https://img.shields.io/badge/SQLite-3.45-003B46?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-F68C1E?style=for-the-badge&logo=Power-BI&logoColor=white)](https://powerbi.microsoft.com/)

Transformei planilhas desorganizadas de gastos pessoais (meu + esposa, desde 2023) em um **mini data warehouse** com dimensões normalizadas, análise exploratória SQL e dashboard interativo no Power BI.

## Contexto do Projeto

**Problema:** Planilhas mensais de gastos com:
- Dados desnormalizados (mesma categoria escrita de 10 formas)
- Erros de digitação, valores inconsistentes ("R$ 1.234,56")
- Sem histórico consolidado
- Impossível analisar tendências ou comparar meses

**Objetivo:** Criar pipeline ETL que:
- Limpa e normaliza dados
- Gera Star Schema (fato + dimensões)
- Permite análises históricas
- Conecta com Power BI para insights visuais

**Resultado:** **1.672 registros** processados → **5 tabelas normalizadas** → Dashboard com totais, tendências e top gastos.

##  Arquitetura ETL (Extract → Transform → Load)
    Planilhas CSV → [Python Pandas] → Star Schema SQLite → [SQL Análise] → Power BI Dashboard
    ↓ Tratamento + Normalização
    dims: responsavel, categoria, subcat, tipo


##  Tecnologias Utilizadas

| Ferramenta | Uso |
|------------|-----|
| **Python + Pandas** | ETL, limpeza, normalização, surrogate keys |
| **SQLite** | Data Warehouse relacional (fato + dimensões) |
| **SQL** | Validação integridade + análise exploratória |
| **Power BI** | Dashboard interativo |

##  Estrutura do Projeto
    analise_gastos_pessoais/
    ├── .gitignore # Protege dados sensíveis (.csv, .db)
    ├── LICENSE
    ├── README.md
    ├── requirements.txt # pip install -r requirements.txt
    │
    ├── 01_data_example/ #  Dados sintéticos para teste
    │ ├── orcamento_example.csv
    │ └── orcamento_example.db
    │
    ├── 02_extracao/ # Etapa 1: Limpeza inicial
    │ └── 01_tratamento_dados_financas.py
    │
    ├── 03_criacao_tabelas/ # Etapa 2: Dimensões + Fato + SQLite
    │ └── 02_tratamento_orcamento.py
    │
    └── 04_Analise_exp/ # Etapa 3: SQL de qualidade + insights
    ├── 01_refatorar_db.sql
    ├── 02_teste_integridade.sql
    ├── 03_analise_exploratoria.sql
    └── 04_correcao_de_lancamento.sql

## 🎬 Dashboard Power BI

<img src="assets/dashboard.gif" alt="Dashboard Power BI Gastos Pessoais" width="800">
![Dashboard de Gastos](assets/dashboard.gif)

Dashboard Power BI - 5 Visualizações Principais

## 📊 Dashboard Power BI - 5 Visualizações

### 1. **Visão Geral**
Cards: total acumulado (R$ 29.734), média mensal (R$ 1.652), último mês (+14%).

### 2. **Despesas por Categoria**
 Top 5: Alimentação (42%), Transporte (28%), Moradia (15%).

### 3. **Tipos de Gasto**
PizzaGrafico: Despesas 92% vs Receitas 8%. Linha temporal mês a mês.

### 4. **Análise Mensal** 
Tabela: gasto por competência, variação % vs anterior. Pico Dez/2025 (+67%).

### 5. **Análise Avançada**
**Medidas DAX:**
- Gasto médio por categoria
- % do total 
- Crescimento mensal
- Top 3 categorias/mês

**Slicers:** Responsável, Categoria, Mês, Tipo.

##  Principais Insights (da análise SQL)

1. **Alimentação = 42% dos gastos** (R$ 12.456 em 18 meses)
2. **Picos em dezembro** (férias + 13º salário: +67%)
3. **Transporte cresceu 35%** em 2025 (combustível)
4. **Pareto confirmado:** 80% dos gastos em 20% das categorias
5. **Responsável principal:** 62% dos gastos 

##  Análises SQL Realizadas

| Script | Objetivo | Resultado |
|--------|----------|-----------|
| `01_refatorar_db.sql` | PK/FK/constraints | 5 tabelas normalizadas |
| `02_teste_integridade.sql` | **0 nulos, 0 FKs órfãs** | ETL 100% correto |
| `03_analise_exploratoria.sql` | Totais, top categorias, evolução | 12 insights principais |
| `04_correcao_de_lancamento.sql` | Ajustes pontuais | 15 registros corrigidos |


## 💡 Lições Aprendidas 

- ✅ **`.map()`** é 100x mais rápido que loops para lookup
- ✅ **Surrogate keys** eliminam duplicatas nas dimensões
- ✅ **SQLite + Power BI** via ODBC (configuração inicial complexa)
- ✅ **`.gitignore`** para dados sensíveis (`data_example/`)
- ⚠️ **Nunca versionar** arquivos de dados



## Como Reproduzir

### 📦 Pré-requisitos

Instale as dependências do projeto:

```bash
pip install -r requirements.txt
```

---

### 1. Dados de Exemplo (já inclusos)

Arquivo com dados sintéticos para teste:

```bash
01_data_example/orcamento_example.csv  # 1.672 registros sintéticos
```

---

### 2. Executar ETL em Python

#### Limpeza inicial

```bash
python 02_extracao/01_tratamento_dados_financas.py
```

#### Dimensões + SQLite

```bash
python 03_criacao_tabelas/02_tratamento_orcamento.py
```

---

### 3. SQL de Qualidade

Abra o banco de dados:

```bash
01_data_example/orcamento_example.db
```

Execute os scripts SQL **na seguinte ordem**:

```sql
04_Analise_exp/01_refatorar_db.sql
04_Analise_exp/02_teste_integridade.sql
04_Analise_exp/03_analise_exploratoria.sql
```

---

### 4. Power BI

No Power BI:

```
Get Data → ODBC → SQLite ODBC Driver → 01_data_example/orcamento_example.db
```



#  Próximos Passos

- [ ] Automatizar ETL direto do Google Sheets
- [ ] Dashboard web público (Streamlit)
- [ ] Alertas de gastos (Telegram/email)
- [ ] Migração para nuvem (PostgreSQL + Supabase)
- [ ] App mobile (React Native)


<span style="font-size: 1.3em; font-weight: bold;">Rafael Leal</span> | [![LinkedIn](https://img.shields.io/badge/-LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/rafael-leal-79805b84/)
