#'
#' Comprueba que todos los tokens estén definidos en las tablas.
#' Comprueba la relación entre claves primarias y foráneas.
#' Avisa de todos los errores encontrados.
#'
#' @param file_path Character. Path to the spreadsheet file to be converted.
#' @param template_path Character. Path to the XML template file to guide the
#' transformation process.
#'
#' @export
check_tab <- function(file_path, template_path) {


  template_path <- system.file("extdata", "schema_template.xml", package = "tab2xml")

  file_path <- system.file("extdata", "schema.xlsx", package = "tab2xml")


  ob <- new_sheet2xml(file_path, template_path)

  root <- get_root_template(ob)

}


# Simplificar el archivo XML (eliminar nodos vacíos)
