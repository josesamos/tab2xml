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
check_tab <- function(file_path, template_path = NULL) {

  if (is.null(template_path)) {
    sheets <- get_sheets_data(file_path)
    root <- NULL
  } else {
    ob <- new_sheet2xml(file_path, template_path)
    sheets <- ob$sheets
    templates <- ob$templates
    root <- ob$root
  }

  check_keys(sheets)
  if (!is.null(root)) {

  }
  TRUE
}


#'
#' @keywords internal
#' @noRd
check_columns <- function(sheets, templates) {
  template_names <- names(templates)
  for (name in template_names) {
    template <- templates[[name]]
    tokens <- get_tokens(template)
    table <- sheets[[name]]
    for (token in setdiff(tokens, template_names)) {
      if (!(token %in% names(table))) {
        warning("Token '", token, "' does not exist in sheet '", name, "'.")
      }
    }
  }
  TRUE
}


#'
#' @keywords internal
#' @noRd
check_keys <- function(sheets) {
  for (name in names(sheets)) {
    pk <- paste0(name, '_pk')
    table <- sheets[[name]]
    if (pk %in% names(table)) {
      validate_pk(table, name)
      fk <- paste0(name, '_fk')
      for (name2 in setdiff(names(sheets), name)) {
        table2 <- sheets[[name2]]
        if (fk %in% names(table2)) {
          validate_fk(table, name, table2, name2)
        }
      }
    }
  }
  TRUE
}
