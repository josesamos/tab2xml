test_that("new_sheet2xml correctly processes Excel and ODS files", {

  # Paths to source files
  source_xml <- system.file("extdata", "schema_template.xml", package = "tab2xml")
  source_xlsx <- system.file("extdata", "schema.xlsx", package = "tab2xml")
  source_ods <- system.file("extdata", "schema.ods", package = "tab2xml")

  # 1. Create an object from an Excel file (.xlsx)
  obj_xlsx <- new_sheet2xml(source_xlsx, source_xml)

  # Ensure object is of the correct class
  expect_s3_class(obj_xlsx, "sheet2xml")

  # Verify structure of the created object
  expect_named(obj_xlsx$sheets)                    # Data from sheets should be present
  expect_named(obj_xlsx$templates)                 # Templates should be processed
  expect_equal(names(obj_xlsx$sheets), tolower(readxl::excel_sheets(source_xlsx))) # Check lowercase names

  # Ensure all column names are lowercase
  expect_true(all(sapply(obj_xlsx$sheets, function(df) all(tolower(colnames(df)) == colnames(df)))))

  # 2. Create an object from an ODS file (.ods)
  obj_ods <- new_sheet2xml(source_ods, source_xml)

  expect_s3_class(obj_ods, "sheet2xml")
  expect_named(obj_ods$sheets)
  expect_named(obj_ods$templates)
  expect_equal(names(obj_ods$sheets), tolower(readODS::ods_sheets(source_ods)))

  # Ensure all column names are lowercase
  expect_true(all(sapply(obj_ods$sheets, function(df) all(tolower(colnames(df)) == colnames(df)))))

  # 3. Handle a custom XML output path
  custom_xml_path <- tempfile(fileext = ".xml")
  obj_custom <- new_sheet2xml(source_xlsx, source_xml, custom_xml_path)

  expect_equal(obj_custom$xml_path, custom_xml_path)

  # 4. Error handling: invalid file path
  expect_error(new_sheet2xml("invalid_file.xlsx", source_xml), "The file does not exist")

  # 5. Error handling: unsupported format
  unsupported_file <- tempfile(fileext = ".csv")
  file.create(unsupported_file)
  expect_error(new_sheet2xml(unsupported_file, source_xml), "Unsupported format")

})
