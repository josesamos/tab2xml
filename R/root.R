
#' Extract the Root Template Name
#'
#' It retrieves the root template from a `sheet2xml` object. If multiple or no tokens
#' are found, an error is raised.
#'
#' @param ob A `sheet2xml` object.
#'
#' @return A character string representing the root template name.
#'
#' @details
#' - If there is not exactly one root token, the function raises an error.
#' - The extracted token is returned as the root template.
#'
#' @keywords internal
#' @noRd
get_root_template <- function(ob) {

  root <- get_tokens(ob$root)

  if (length(root) != 1) {
    stop("The template must have one root and only one.")
  }
  root[[1]]
}


#' Save the Root Template to a File
#'
#' It replaces a root token in the template with the provided result and writes
#' the modified template to the specified XML file path.
#'
#' @param ob A `sheet2xml` object.
#' @param root A character string representing the root token to be replaced.
#' @param result A character vector with the content that replaces the root token.
#'
#' @return The file path where the modified template has been saved.
#'
#' @keywords internal
#' @noRd
save_root_template <- function(ob, root, result) {

  template <- replace_token_for_lines(ob$root, root, result)

  file <- ob$xml_path

  writeLines(template, file)
  file
}
