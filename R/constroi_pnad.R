#' Constrói um Dataset Consolidado da PNADc
#'
#' Esta função combina os microdados da primeira e quinta visita da Pesquisa Nacional por
#' Amostra de Domicílios Contínua (PNADc) para um ano específico, aplicando rotulagem
#' e selecionando variáveis de interesse. A função facilita o processo de preparação
#' dos dados para análises subsequentes.
#'
#' @param diretorio O caminho do diretório onde os arquivos de microdados da PNADc estão
#' localizados. Este diretório deve conter tanto os arquivos de microdados quanto os arquivos
#' de input e dicionários necessários para a leitura e rotulagem dos dados.
#' @param ano O ano dos dados da PNADc que serão processados. Embora a função esteja preparada
#' para tratar especificidades de diferentes anos, atualmente há uma diferenciação específica
#' no processamento entre o ano de 2022 e outros anos.
#'
#' @return Um tibble que representa a tabela consolidada combinando dados das visitas 1 e 5
#' da PNADc, incluindo variáveis selecionadas e processadas conforme especificado. A forma
#' como os dados das duas visitas são combinados depende do ano especificado.
#'
#' @examples
#' # Supondo que os arquivos da PNADc para 2018 estejam no diretório 'pnadc_2018'
#' pnad_consolidado <- constroi_pnad(diretorio = 'pnadc_2018', ano = 2018)
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom PNADcIBGE read_pnadc pnadc_labeller
#' @export
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


constroi_pnad <- function(diretorio, ano){
  #faz um listfiles e procura o arquivo da visita 1
  pnadc_entrevista_1 <- PNADcIBGE::read_pnadc(
    microdata = list.files(diretorio,
                           pattern = "PNADC_...._visita1.txt",
                           full.names = TRUE),
    input_txt = list.files(diretorio,
                           pattern = "input_PNADC_...._visita1",
                           full.names = TRUE)

  ) %>%
    dplyr::select(any_of(variaveis_pnadc)) %>%
    PNADcIBGE:: pnadc_labeller(
      dictionary.file = list.files(diretorio,
                                   pattern = "microdados_...._visita1",
                                   full.names = TRUE)
    )

  # faz um listfiles e procura o arquvio da visita 5

  pnadc_entrevista_5 <- PNADcIBGE::read_pnadc(
    microdata = list.files(diretorio,
                           pattern = "PNADC_...._visita5.txt",
                           full.names = TRUE),
    input_txt = list.files(diretorio,
                           pattern = "input_PNADC_...._visita5",
                           full.names = TRUE)

  ) %>%
    dplyr::select(any_of(variaveis_pnadc)) %>%
    PNADcIBGE::pnadc_labeller(
      dictionary.file = list.files(diretorio,
                                   pattern = "microdados_...._visita5",
                                   full.names = TRUE)
    )

  if (ano != 2022) {
    # Definindo as colunas para remover baseando-se em 'pnad_1', excluindo as primeiras 5 colunas
    cols_para_remover <- pnadc_entrevista_1 %>%
      dplyr::select(-c(1:5)) %>%
      names()

    # Realizando a junção, mantendo 'pnad_1' à esquerda
    resultado <- pnadc_entrevista_1 %>%
      dplyr::left_join(pnadc_entrevista_5 %>%
                         dplyr::select(-any_of(cols_para_remover)),
                       multiple = "first")
  } else {
    # Definindo as colunas para remover baseando-se em 'pnad_5', excluindo as primeiras 5 colunas
    cols_para_remover <- pnadc_entrevista_5 %>%
      dplyr::select(-c(1:5)) %>%
      names()
    # Realizando a junção, mantendo 'pnad_5' à esquerda
    resultado <- pnadc_entrevista_5 %>%
      dplyr::left_join(pnadc_entrevista_1 %>%
                         select(-any_of(cols_para_remover)),
                       multiple = "first")
  }



  resultado
}
