
# Pacotes ----------------------------------------------------------------------------------------------------

# Carregar pacotes
library(rdbnomics)
library(dplyr)
library(magrittr)
library(stringr)
library(countrycode)

# Coleta de dados --------------------------------------------------------------------------------------------

# Importa dados da DBNOMICS (fonte Banco Mundial - WDI)

dados_brutos <- rdbnomics::rdb(
  api_link = paste0(
    "https://api.db.nomics.world/v22/series/WB/WDI?dimensions=%7B%22country%22%3A%5B%22BRA%22%2C%22ARG%22%2C%22BEL%22%2C%22CMR%22%2C%22CAN%22%2C%22CRI%22%2C%22DNK%22%2C%22FRA%22%2C%22GHA%22%2C%22IRN%22%2C%22JPN%22%2C%22KOR%22%2C%22MEX%22%2C%22QAT%22%2C%22SEN%22%2C%22SRB%22%2C%22TUN%22%2C%22UKR%22%2C%22RUS%22%2C%22USA%22%2C%22URY%22%2C%22EMU%22%2C%22CHN%22%5D%2C%22frequency%22%3A%5B%22A%22%5D%2C%22indicator%22%3A%5B%22NY.GDP.MKTP.KD.ZG%22%2C%22FP.CPI.TOTL.ZG%22%2C%22PA.NUS.FCRF%22%2C%22SL.UEM.TOTL.NE.ZS%22%2C%22FR.INR.DPST%22%5D%7D&observations=1"
  )
)


# Tratamento de dados ----------------------------------------------------------------------------------------

# Trata tabela da DBNOMICS
dados_tratados <- dados_brutos |>
  dplyr::select(
    "data" = "period",
    "pais" = "series_name",
    "variavel" = "indicator",
    "valor" = "value",
    "atualizacao" = "indexed_at"
  ) |>
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
  )
) |>
  dplyr::as_tibble() |> tidyr::drop_na()

# OU ---------------------------------------------------------------------------------------------------------


dados_wdi <- dados_brutos |>
  dplyr::select(
    "data" = "period",
    "pais" = "country",
    "variavel" = "indicator",
    "valor" = "value",
    "atualizacao" = "indexed_at"
  ) |>
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
    pais = countrycode::countrycode(
      sourcevar = pais,
      origin = "iso3c",
      destination = "country.name"
    )  # extrair apenas o nome do pais
  ) |>
  dplyr::as_tibble() |> tidyr::drop_na()


---------------------------------------------------------------------------------------




# Salvar dados -----------------------------------------------------------------------------------------------

# Salvar tabelas como arquivo CSV
if(!dir.exists("dados")) {dir.create("dados")}
readr::write_csv(x = dados_tratados, file = "dados/dados.csv")
