test_that("sheet2xml works", {
  source_xml <- system.file("extdata", "schema_template.xml", package = "tab2xml")

  source_xlsx <- system.file("extdata", "schema.xlsx", package = "tab2xml")
  temp_file1 <- tempfile(fileext = ".xml")
  r1 <- sheet2xml(source_xlsx, source_xml, temp_file1)

  expect_equal(temp_file1, r1)

  original_xml <- system.file("extdata", "schema_original.xml", package = "tab2xml")

  doc1 <- xml2::read_xml(original_xml)
  doc2 <- xml2::read_xml(temp_file1)

  doc1 <- xml2::xml_ns_strip(doc1)
  doc2 <- xml2::xml_ns_strip(doc2)

  xml1_text <- as.character(doc1)
  xml2_text <- as.character(doc2)

  expect_equal(xml1_text, xml2_text)


  source_ods <- system.file("extdata", "schema.ods", package = "tab2xml")
  temp_file2 <- tempfile(fileext = ".xml")
  r2 <- sheet2xml(source_ods, source_xml, temp_file2)

  expect_equal(temp_file2, r2)

  doc22 <- xml2::read_xml(temp_file2)

  doc22 <- xml2::xml_ns_strip(doc22)

  xml22_text <- as.character(doc22)
  xml22_text <- gsub("TRUE", "true", xml22_text)
  xml22_text <- gsub("FALSE", "false", xml22_text)

  expect_equal(xml1_text, xml22_text)
})
