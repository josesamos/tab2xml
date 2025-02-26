
#' Validate and Check Spreadsheet Data
#'
#' This function validates the structure of a spreadsheet file by checking its
#' sheets, primary keys (PKs), and foreign keys (FKs). If a template file is provided,
#' it also checks the column definitions.
#'
#' @param file_path Character. Path to the spreadsheet file to be validated.
#' @param template_path Character (optional). Path to the template file for validation.
#' If `NULL`, only the sheet structure is checked.
#'
#' @return Logical. Returns "TRUE" but warns of possible errors.
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
    check_columns(sheets, templates)
  }
  TRUE
}


#' Validate Column Names Against Template
#'
#' This function checks whether the column names in the spreadsheet match the
#' expected tokens defined in a template. It ensures that all required columns
#' exist and issues warnings for any missing or extra columns.
#'
#' @param sheets A named list of data frames representing the spreadsheet sheets.
#' @param templates A named list of template definitions for validation.
#'
#' @return Logical. Returns `TRUE` after performing the checks.
#'
#' @keywords internal
#' @noRd
check_columns <- function(sheets, templates) {
  template_names <- names(templates)
  sheet_names <- names(sheets)
  if (!setequal(template_names, sheet_names)) {
    warning("The spreadsheet sheets and templates do not match.")
  }
  pks_fks <- c(paste0(sheet_names, "_pk"), paste0(sheet_names, "_fk"))
  for (name in template_names) {
    template <- templates[[name]]
    tokens <- get_tokens(template)
    table <- sheets[[name]]
    fields <- names(table)
    for (token in setdiff(tokens, template_names)) {
      if (!(token %in% names(table))) {
        warning("Token '", token, "' does not exist in sheet '", name, "'.")
      }
    }
    for (field in setdiff(fields, pks_fks)) {
      if (!(field %in% tokens)) {
        warning("Field '", field, "' does not exist in template '", name, "'.")
      }
    }
  }
  TRUE
}


#' Validate Primary and Foreign Keys in a Spreadsheet
#'
#' This function checks if each sheet in a spreadsheet contains a valid primary key (PK)
#' and validates foreign key (FK) relationships between tables.
#'
#' @param sheets A named list of data frames representing the spreadsheet sheets.
#'
#' @return Logical. Returns `TRUE` after performing the key validations.
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
