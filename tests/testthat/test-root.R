test_that("get_root_template extracts the correct root token", {

  # Paths to source files
  source_xml <- system.file("extdata", "schema_template.xml", package = "tab2xml")
  source_xlsx <- system.file("extdata", "schema.xlsx", package = "tab2xml")

  # Create a "sheet2xml" object
  obj <- new_sheet2xml(source_xlsx, source_xml)

  # 1. Valid case: extract root when only one token is present
  root <- get_root_template(obj)
  expect_type(root, "character")       # Root must be a character string
  expect_length(root, 1)               # Ensure there is exactly one root token

  # Ensure the root exists in the object
  expect_true(root %in% get_tokens(obj$root))

  # 2. Error case: multiple root tokens
  obj_multiple <- obj
  obj_multiple$root <- c("{root1}", "{root2}")

  expect_error(get_root_template(obj_multiple),
               "The template must have one root and only one.")

  # 3. Error case: no root tokens
  obj_empty <- obj
  obj_empty$root <- character(0)   # Empty root

  expect_error(get_root_template(obj_empty),
               "The template must have one root and only one.")

  # 4. Test with ODS files
  source_ods <- system.file("extdata", "schema.ods", package = "tab2xml")
  obj_ods <- new_sheet2xml(source_ods, source_xml)

  root_ods <- get_root_template(obj_ods)
  expect_type(root_ods, "character")
  expect_length(root_ods, 1)

})


test_that("save_root_template saves the transformed XML correctly", {

  # Paths to source files
  source_xml <- system.file("extdata", "schema_template.xml", package = "tab2xml")
  source_xlsx <- system.file("extdata", "schema.xlsx", package = "tab2xml")

  # Create a "sheet2xml" object
  obj <- new_sheet2xml(source_xlsx, source_xml)

  # Create a temporary file to store the XML output
  obj$xml_path <- tempfile(fileext = ".xml")

  # Root token to replace
  root <- "cube"

  # Replacement content
  result <- c("<data>", "<item>1</item>", "<item>2</item>", "</data>")

  # 1. Validate output file path
  output_file <- save_root_template(obj, root, result)
  expect_type(output_file, "character")
  expect_true(file.exists(output_file))

  # 2. Check contents of the saved XML
  saved_content <- readLines(output_file)

  # Ensure the replacement was done correctly
  expect_true(any(grepl("<data>", saved_content)))
  expect_true(any(grepl("<item>1</item>", saved_content)))
  expect_true(any(grepl("</data>", saved_content)))

  # Ensure root token is replaced
  expect_false(any(grepl(root, saved_content)))

  # 3. Handle empty content replacement
  output_file_empty <- save_root_template(obj, root, character(0))
  saved_empty <- readLines(output_file_empty)
  expect_true(length(saved_empty) > 0) # Template should still exist

  # 4. Verify the return value is the output file path
  expect_equal(output_file, obj$xml_path)

})
