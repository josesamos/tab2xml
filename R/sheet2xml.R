
#' Convert a Spreadsheet to XML
#'
#' It reads a spreadsheet file (Excel or ODS), processes it using a provided XML
#' template, and generates an XML output file.
#'
#' @param file_path Character. Path to the spreadsheet file to be converted.
#' Supports Excel (.xlsx) and ODS formats.
#' @param template_path Character. Path to the XML template file to guide the
#' transformation process.
#' @param xml_path Character (optional). Output path for the generated XML file.
#' If NULL, it is considered an XML file with the same name and location as the
#' spreadsheet file.
#' @param optimize Boolean. Remove empty nodes from the xml file.
#'
#' @return Character. The file path of the generated XML document.
#'
#' @examples
#' source_xml <- system.file("extdata", "schema_template.xml", package = "tab2xml")
#'
#' source_xlsx <- system.file("extdata", "schema.xlsx", package = "tab2xml")
#' temp_file1 <- tempfile(fileext = ".xml")
#' sheet2xml(source_xlsx, source_xml, temp_file1)
#'
#' source_ods <- system.file("extdata", "schema.ods", package = "tab2xml")
#' temp_file2 <- tempfile(fileext = ".xml")
#' sheet2xml(source_ods, source_xml, temp_file2)
#'
#' @export
sheet2xml <- function(file_path, template_path, xml_path = NULL, optimize = FALSE) {

  ob <- new_sheet2xml(file_path, template_path, xml_path)

  root <- get_root_template(ob)

  result <- transform_template(ob, root)

  file_name <- save_root_template(ob, root, result)

  if (optimize) {
    content <- xml2::read_xml(file_name)
    remove_empty_nodes(content)
    xml2::write_xml(content, file_name)
  }

  file_name
}

