
#' Read a Template File if it Exists
#'
#' It checks if a given file exists before attempting to read it.
#' If the file exists, it returns its content as a character vector.
#' If the file does not exist, an error is thrown.
#'
#' @param file A character string specifying the path to the template file.
#'
#' @return A character vector with the file's content if it exists; otherwise,
#' the function stops with an error.
#'
#' @keywords internal
#' @noRd
read_template <- function(file) {
  if (file.exists(file)) {
    return(readLines(file, warn = FALSE))
  } else {
    stop("The template does not exist: ", file)
    return(NULL)
  }
}


#' Extract Tokens from a Template
#'
#' It extracts tokens enclosed in `{}` from a given template.
#' It returns a character vector containing the token names without the `{}` delimiters.
#'
#' @param template A character vector representing the template with placeholders.
#'
#' @return A character vector of extracted token names. If no tokens are found,
#' it returns an empty vector.
#'
#' @keywords internal
#' @noRd
get_tokens <- function(template) {
  tokens <- regmatches(template, gregexpr("\\{([^}]+)\\}", template))
  tokens <- lapply(tokens, function(x) gsub("[{}]", "", x))
  tokens <- Filter(length, tokens)
  unlist(tokens)
}


#' Replace Lines Containing a Specific Token
#'
#' It replaces entire lines in a template if they contain a specific token.
#' If a line includes the token, it is replaced entirely by the given `value`.
#' If a line does not contain the token, it remains unchanged.
#'
#' @param template A character vector representing the template, where each element is a line.
#' @param token A string specifying the token (without `{}`) to be detected.
#' @param value A character vector specifying the replacement value. If `value`
#' is a vector, each matching line is replaced by the full vector.
#'
#' @return A character vector with the modified template, where lines containing
#' the token are replaced by `value`.
#'
#' @keywords internal
#' @noRd
replace_token_for_lines <- function(template, token, value) {
  token_pattern <- sprintf("\\{%s\\}", token)

  token_lines <- grepl(token_pattern, template)

  unlist(lapply(seq_along(template), function(i) {
    if (token_lines[i]) value else template[i]
  }))
}

#' Replace a Token in a Template
#'
#' It replaces all occurrences of a specified token in a template with a given value.
#' Tokens are identified using curly braces `{token}`. If `value` is `NA`, it is
#' replaced with an empty string.
#'
#' @param template A character vector representing the template, where tokens will be replaced.
#' @param token A string specifying the token (without `{}`) to be replaced.
#' @param value A string or character vector with the replacement value. If `NA`,
#' it is replaced with an empty string.
#'
#' @return A character vector with the modified template where the token has been
#' replaced by `value`.
#'
#' @keywords internal
#' @noRd
replace_token <- function(template, token, value) {
  token_pattern <- sprintf("\\{%s\\}", token)
  if (is.na(value)) {
    value <- ''
  }
  gsub(token_pattern, value, template)
}


#' Convert Tokens in Curly Braces to Lowercase
#'
#' It converts all tokens enclosed in `{}` within a character vector to lowercase.
#'
#' @param vector A character vector containing tokens enclosed in `{}`.
#'
#' @return A character vector with the tokens converted to lowercase while keeping the curly braces.
#'
#' @keywords internal
#' @noRd
convert_tokens_lowercase <- function(vector) {
  stringr::str_replace_all(vector, "\\{([^}]+)\\}", function(x) {
    paste0("{", tolower(stringr::str_match(x, "\\{([^}]+)\\}")[, 2]), "}")
  })
}


#' Remove Empty XML Nodes Recursively
#'
#' This function traverses an XML node and removes any empty child nodes.
#' A node is considered empty if it has no children, no text content, and no attributes.
#'
#' @param node An XML node of class `xml_node` from the `xml2` package.
#'
#' @return The function modifies the XML structure in place and does not return a value.
#'
#' @keywords internal
remove_empty_nodes <- function(node) {
  children <- xml2::xml_children(node)

  for (child in children) {
    remove_empty_nodes(child)

    if (xml2::xml_length(child) == 0 &&
        xml2::xml_text(child) == "" &&
        length(xml2::xml_attrs(child)) == 0) {
      xml2::xml_remove(child)
    }
  }
}

