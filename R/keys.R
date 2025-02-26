#' Validate primary key column
#'
#' Checks if a table contains a correctly formatted primary key column.
#' Primary key column must exist, no missing values and contain unique values.
#'
#' @param table A data frame that represents the table to validate.
#' @param name A string indicating the name of the table.
#'
#' @return `TRUE`. Generates warnings if primary key column is missing or has duplicates.
#'
#' @keywords internal
validate_pk <- function(table, name) {
  pk <- paste0(name, '_pk')
  if (!pk %in% names(table)) {
    warning("Column '", pk, "' does not exist in sheet '", name, "'.")
  } else {
    valores <- table[[pk]]
    if (!(all(!is_cell_empty(valores)) &&
          length(unique(valores)) == nrow(table))) {
      warning("Column '",
              pk,
              "' in sheet '",
              name,
              "' cannot have missing or duplicate values.")
    }
  }
  TRUE
}

#' Validate foreign key column
#'
#' Checks if a foreign key column exists in the reference table and ensures make all
#' values in the foreign key column match the existing values in the primary key
#' column of the referenced table.
#'
#' @param table_pk A data frame that represents the table containing the primary key.
#' @param name_pk A string indicating the name of the table to which reference.
#' @param table_fk A data frame that represents the table containing the foreign key.
#' @param name_fk A character string indicating the name of the reference table.
#'
#' @return `TRUE`. Generates warnings if the foreign key column is missing from the
#' reference table or if it contains values that are not present in the column primary
#' key of the referenced table.
#'
#' @keywords internal
validate_fk <- function(table_pk, name_pk, table_fk, name_fk) {
  pk <- paste0(name_pk, '_pk')
  fk <- paste0(name_pk, '_fk')
  if (!(fk %in% names(table_fk))) {
    warning("Column '", fk, "' does not exist in sheet '", name_fk, "'.")
  } else {
    values <- table_fk[[fk]]
    original <- table_pk[[pk]]
    if (!all(values %in% original)) {
      warning(
        "All values in the '",
        fk,
        "' column in the '",
        name_fk,
        "' sheet must be in the '",
        pk,
        "' column in the '",
        name_pk,
        "' sheet."
      )
    }
  }
  TRUE
}
