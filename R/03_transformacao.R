# Conexao com banco SQL de dados brutos
sql_brutos <- conectar_sql(local = "dados/dados_brutos.db")

# TRANSFORMA CONEXAO COM OBJETO TIBBLE COM FONTE EXTERNA
tbl_brutos <- dplyr::tbl(src = sql_brutos, from = "tbl_brutos")

# Trata tabela da DBNOMICS
dados_tratados <- tbl_brutos |>
  dplyr::select(
    "data" = "period",
    "pais" = "series_name",
    "variavel" = "indicator",
    "valor" = "value",
    "atualizacao" = "indexed_at"
  ) |>
  dplyr::collect() |>
  dplyr::as_tibble() |>
  dplyr::mutate(
    variavel = dplyr::recode(
      .x = variavel, # cada código abaixo é um indicador na hora de selecionar no site
      "FP.CPI.TOTL.ZG" = "Inflação (Anual, %)",
      "FR.INR.DPST" = "Juros (Depósito, %)",
      "NY.GDP.MKTP.KD.ZG" = "PIB (cresc. anual, %)",
      "PA.NUS.FCRF" = "Câmbio (Média, UMC/US$)",
      "SL.UEM.TOTL.NE.ZS" = "Desemprego (Total, %)"
    ),
    pais = stringr::str_extract(string = pais, pattern = "(?<=\\)\\s[:punct:]\\s).*"  # extrair apenas o nome do pais
  ),
  atualizacao = lubridate::as_date(atualizacao)
) |> 
tidyr::drop_na() |> 
dplyr::as_tibble()

# Criar banco de dados SQL
sql_tratados <- conectar_sql(local = "dados/dados_tratados.db")


# Armazenar dados em tabela no banco SQL
DBI::dbWriteTable(
    conn = sql_tratados,
    name = "tbl_tratados",
    value = dados_tratados,
    overwrite = TRUE
)

# Encerrar conexao
DBI::dbDisconnect(conn = sql_brutos, shutdown = TRUE)
DBI::dbDisconnect(conn = sql_tratados, shutdown = TRUE)