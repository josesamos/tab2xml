test_that("check_tab() works with valid input", {
  file_path <- system.file("extdata", "schema.xlsx", package = "tab2xml")
  template_path <- system.file("extdata", "schema_template.xml", package = "tab2xml")

  expect_true(check_tab(file_path))
  expect_true(check_tab(file_path, template_path))
})

test_that("check_tab() fails with non-existing file", {
  expect_error(check_tab("non_existing_file.xlsx"), "The file does not exist")
})

test_that("check_columns() warns on mismatched columns", {
  sheets <- list(
    sheet1 = data.frame(a = 1:3, b = 4:6),
    sheet2 = data.frame(x = 7:9, y = 10:12)
  )

  templates <- list(
    sheet1 = c("{a}", "{b}", "{c}"),  # Missing "c"
    sheet2 = c("{x}", "{y}")
  )

  expect_warning(check_columns(sheets, templates), "Token 'c' does not exist")
})

test_that("check_columns() warns on extra columns", {
  sheets <- list(
    sheet1 = data.frame(a = 1:3, b = 4:6, c = 7:9),
    sheet2 = data.frame(x = 7:9, y = 10:12, z = 13:15)  # Extra column "z"
  )

  templates <- list(
    sheet1 = c("{a}", "{b}", "{c}"),
    sheet2 = c("{x}", "{y}")  # Missing "z"
  )

  expect_warning(check_columns(sheets, templates), "Field 'z' does not exist")
})

test_that("check_keys() validates primary and foreign keys", {
  sheets <- list(
    sheet1 = data.frame(sheet1_pk = 1:3, value = c("a", "b", "c")),
    sheet2 = data.frame(sheet2_pk = 4:6, sheet1_fk = 1:3, value = c("x", "y", "z"))
  )

  expect_true(check_keys(sheets))
})

test_that("check_keys() warns on missing PK", {
  sheets <- list(
    sheet1 = data.frame(value = c("a", "b", "c"))  # Missing PK
  )

  expect_true(check_keys(sheets))
})

test_that("check_keys() warns on FK mismatch", {
  sheets <- list(
    sheet1 = data.frame(sheet1_pk = 1:3, value = c("a", "b", "c")),
    sheet2 = data.frame(sheet2_pk = 4:6, sheet1_fk = c(10, 11, 12), value = c("x", "y", "z")) # FK mismatch
  )

  expect_warning(check_keys(sheets), "All values in the 'sheet1_fk' column in the 'sheet2' sheet must be in the 'sheet1_pk' column in the 'sheet1' sheet.")
})
