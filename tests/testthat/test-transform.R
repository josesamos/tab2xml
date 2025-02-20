test_that("transform_template handles basic transformation correctly", {

  # Paths to source files
  source_xml <- system.file("extdata", "schema_template.xml", package = "sheet2xml")
  source_xlsx <- system.file("extdata", "schema.xlsx", package = "sheet2xml")

  # Create a sheet2xml object
  ob <- new_sheet2xml(source_xlsx, source_xml)

  # Ensure the object is valid
  expect_s3_class(ob, "sheet2xml")

  # Get the root element
  root <- get_root_template(ob)
  expect_type(root, "character")

  # Perform transformation on the root sheet
  result <- transform_template(ob, root)

  # Check output is a character vector
  expect_type(result, "character")
  expect_true(length(result) > 0)

  # Ensure some known values from the sheet are present in the result
  expect_true(any(grepl("<", result)))  # Basic check for XML-like content

})

test_that("transform_template handles row filtering", {

  # Paths to source files
  source_xml <- system.file("extdata", "schema_template.xml", package = "sheet2xml")
  source_xlsx <- system.file("extdata", "schema.xlsx", package = "sheet2xml")

  # Create a sheet2xml object
  ob <- new_sheet2xml(source_xlsx, source_xml)

  # Get the root element
  root <- get_root_template(ob)

  # Filter only the first row
  result <- transform_template(ob, root, rows = 1)
  expect_type(result, "character")

  # Ensure content from the first row exists in the output
  first_row_values <- unlist(ob$sheets[[root]][1, ])
  expect_true(any(sapply(first_row_values, function(x) any(grepl(x, result)))))
})

test_that("transform_template handles missing relationships", {

  # Paths to source files
  source_xml <- system.file("extdata", "schema_template.xml", package = "sheet2xml")
  source_xlsx <- system.file("extdata", "schema.xlsx", package = "sheet2xml")

  # Create a sheet2xml object
  ob <- new_sheet2xml(source_xlsx, source_xml)

  # Introduce a missing relationship scenario
  root <- get_root_template(ob)

  # Modify object to break a relationship
  ob$templates$cube[4] <- "        {measurexxx}"

  expect_error(
    transform_template(ob, "cube"),
    "There is no defined relationship between"
  )
})

