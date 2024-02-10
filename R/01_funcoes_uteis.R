# Função útil para conexão com banco de dados SQL
conectar_sql <- function(conexao = duckdb::duckdb(), local) {
    DBI::dbConnect(
        drv = conexao,
        dbdir = local
    )
}
