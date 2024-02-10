# Cria conexao com o banco de dados SQL
sql_tratados <- conectar_sql(local = "dados/dados_tratados.db")


# TRANSFORMA CONEXAO COM OBJETO TIBBLE COM FONTE EXTERNA
tbl_tratados <- dplyr::tbl(src = sql_tratados, from = "tbl_tratados")

# Salvar tabela como CSV
readr::write_csv(
    x = dplyr::collect(tbl_tratados),
    file = "aplicacao/dados_disponibilizados.csv"
)

# Encerrar a conexao
DBI::dbDisconnect(conn = sql_tratados, shutdown = TRUE)