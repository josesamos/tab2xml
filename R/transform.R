

#' Transform a Template
#'
#' It replaces tokens in a template with corresponding values from a data source.
#' It handles both direct replacements from a data frame and foreign key relationships.
#'
#' @param ob A `sheet2xml` object.
#' @param root A string specifying the root sheet/template to process.
#' @param rows Optional. A vector of row indices to process in the root sheet.
#' If NULL, all rows are processed.
#'
#' @return A character vector with the template populated using the provided data.
#'
#' @details
#' - Tokens in the template (enclosed in `{}`) are replaced with corresponding values from the root sheet.
#' - If a token does not exist in the root sheet, the function checks for foreign key (`_fk`) and primary key (`_pk`) relationships.
#' - If a relationship is found, it recursively transforms the related template and injects the result into the current template.
#' - If no valid relationship is found, an error is raised.
#'
#' @keywords internal
#' @noRd
transform_template <- function(ob, root, rows = NULL) {
  sheet <- ob$sheets[[root]]
  if (!is.null(rows)) {
    sheet <- sheet[rows, ]
  }
  template <- ob$templates[[root]]

  tokens <- get_tokens(template)

  if (nrow(sheet) > 0) {
    common_res <- NULL
    for (i in 1:nrow(sheet)) {
      res <- template
      for (token in tokens) {
        if (token %in% names(sheet)) {
          res <- replace_token(res, token, sheet[i, token])
        } else {
          fk <- paste0(token, "_fk")
          if (fk %in% names(sheet)) {
            pk <- paste0(token, "_pk")
            r <- which(ob$sheets[[token]][, pk] == sheet[i, fk][[1]])
          } else {
            fk <- paste0(root, "_fk")
            if (fk %in% names(ob$sheets[[token]])) {
              pk <- paste0(root, "_pk")
              r <- which(ob$sheets[[token]][, fk] == sheet[i, pk][[1]])
            } else {
              stop("There is no defined relationship between ", paste0(root ," and ", token, "."))
            }
          }
          result <- transform_template(ob, token, r)
          res <- replace_token_for_lines(res, token, result)
        }
      }
      common_res <- c(common_res, res)
    }
  }
  common_res
}





