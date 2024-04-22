#' Esta função envia os dados baixados na pasta data/ para o banco de dados
#'
#' @importFrom utils download.file
#' @importFrom archive archive_extract
#' @export

library(DBI)
library(odbc)

# Check the operating system
if (Sys.info()["sysname"] == "Windows") 
{
  Sys.setlocale("LC_CTYPE", "Portuguese_Brazil.UTF-8")  # Change to the appropriate locale
  
} else if (Sys.info()["sysname"] == "Darwin" || Sys.info()["sysname"] == "Linux") 
{  
  Sys.setlocale(category="LC_CTYPE", locale="pt_BR.UTF-8")
} else 
{
  print("Unsupported operating system.")
}

# Função para conectar ao SQL Server com parâmetros dinâmicos
conectar_sql_server <- function(servidor, database) {
  con <- DBI::dbConnect(odbc::odbc(),
                        Driver = "SQL Server",
                        Server = servidor,
                        Port = 1433)
  return(con)
}

# Função para carregar o dataframe no SQL Server com parâmetros de conexão dinâmicos
carregar_para_sql <- function(dataframe, nome_tabela, servidor, database) {
  con <- conectar_sql_server(servidor, database)
  
  utils::read.csv(dataframe)
  
  # Inserir os dados
  dbWriteTable(con, nome_tabela, dataframe, append = TRUE, row.names = FALSE)
  
  # Fechar a conexão
  dbDisconnect(con)
}

#name_server <- "DESKTOP-66MU3PS\\SQLEXPRESS"
#db_name <- "my_db"
#user <- "sa"
#key <- "eDTh291022;"

#my_con <- conectar_sql_server(name_server, db_name)

#df <- utils::read.csv(file="./data-aux/imdb.csv")

#carregar_para_sql(dataframe="./data-aux/imgb.csv", nome_tabela="teste_table", 
                  #servidor=name_server, database="my_db")