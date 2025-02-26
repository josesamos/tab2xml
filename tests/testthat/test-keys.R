
test_that("validate_pk detects missing primary key column", {
  df <- data.frame(id = 1:5, value = letters[1:5])
  expect_warning(validate_pk(df, "test_table"), "Column 'test_table_pk' does not exist in sheet 'test_table'.")
})

test_that("validate_pk detects missing values in primary key column", {
  df <- data.frame(test_table_pk = c(1, 2, NA, 4, 5), value = letters[1:5])
  expect_warning(validate_pk(df, "test_table"), "Column 'test_table_pk' in sheet 'test_table' cannot have missing or duplicate values.")
})

test_that("validate_pk detects duplicate values in primary key column", {
  df <- data.frame(test_table_pk = c(1, 2, 2, 4, 5), value = letters[1:5])
  expect_warning(validate_pk(df, "test_table"), "Column 'test_table_pk' in sheet 'test_table' cannot have missing or duplicate values.")
})

test_that("validate_pk passes when primary key column is correct", {
  df <- data.frame(test_table_pk = 1:5, value = letters[1:5])
  expect_silent(validate_pk(df, "test_table"))
})

test_that("validate_fk detects missing foreign key column", {
  df_pk <- data.frame(parent_table_pk = 1:5)
  df_fk <- data.frame(value = letters[1:5])
  expect_warning(validate_fk(df_pk, "parent_table", df_fk, "child_table"), "Column 'parent_table_fk' does not exist in sheet 'child_table'.")
})

test_that("validate_fk detects foreign key values not in primary key column", {
  df_pk <- data.frame(parent_table_pk = 1:5)
  df_fk <- data.frame(parent_table_fk = c(1, 2, 6, 4, 5))
  expect_warning(validate_fk(df_pk, "parent_table", df_fk, "child_table"), "All values in the 'parent_table_fk' column in the 'child_table' sheet must be in the 'parent_table_pk' column in the 'parent_table' sheet.")
})

test_that("validate_fk passes when foreign key column is correct", {
  df_pk <- data.frame(parent_table_pk = 1:5)
  df_fk <- data.frame(parent_table_fk = c(1, 2, 3, 4, 5))
  expect_silent(validate_fk(df_pk, "parent_table", df_fk, "child_table"))
})
