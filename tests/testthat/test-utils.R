test_that("read_template works correctly", {

  temp_file <- tempfile(fileext = ".txt")
  writeLines(c("Line 1", "Line 2", "Line 3"), temp_file)

  result <- read_template(temp_file)
  expect_type(result, "character")
  expect_equal(length(result), 3)
  expect_equal(result[1], "Line 1")

  expect_error(read_template("non_existent_file.txt"),
               "The template does not exist")

  unlink(temp_file)
})


test_that("get_tokens extracts tokens correctly", {

  expect_equal(get_tokens("Hello {name}"), "name")

  expect_equal(get_tokens("Hello {name}, your age is {age}"), c("name", "age"))

  expect_equal(get_tokens("Value: {x}, Again: {x}"), c("x", "x"))

  expect_equal(get_tokens("No tokens here"), NULL)

  expect_equal(get_tokens(""), NULL)

  expect_equal(get_tokens("Special {token_1} and {token-2}"), c("token_1", "token-2"))

})


test_that("replace_token_for_lines replaces token correctly", {

  # Replace a token in a single line
  template <- c("Hello {name}", "Goodbye {name}")
  result <- replace_token_for_lines(template, "name", c("John", "Doe"))
  expect_equal(result, c("John", "Doe", "John", "Doe"))

  # Token not present: should return the original template
  template <- c("No token here", "Still no token")
  result <- replace_token_for_lines(template, "name", c("John"))
  expect_equal(result, template)

  # Empty template: should return an empty character vector
  result <- replace_token_for_lines(character(0), "name", c("John"))
  expect_equal(result, NULL)

  # Token with special characters
  template <- c("Hello {user_id-123}", "Bye {user_id-123}")
  result <- replace_token_for_lines(template, "user_id-123", c("X", "Y"))
  expect_equal(result, c("X", "Y", "X", "Y"))

  # Template with no matching token: should remain unchanged
  template <- c("Hello World", "No token here")
  result <- replace_token_for_lines(template, "missing_token", c("Ignored"))
  expect_equal(result, template)

  # Handling NULL input
  result <- replace_token_for_lines(NULL, "name", c("John"))
  expect_equal(result, NULL)

  # Token appears multiple times in the same line
  template <- c("Hello {name}", "{name} and {name}", "Goodbye")
  result <- replace_token_for_lines(template, "name", c("X", "Y"))
  expect_equal(result, c("X", "Y", "X", "Y", "Goodbye"))

  template <- c("Hello {name}", "Bye {name}", "Again {name}")
  result <- replace_token_for_lines(template, "name", "John")
  expect_equal(result, c("John", "John", "John"))

})


test_that("replace_token replaces token correctly", {

  # 1. Replace a single token with a value
  template <- "Hello {name}"
  result <- replace_token(template, "name", "John")
  expect_equal(result, "Hello John")

  # 2. Replace multiple occurrences of the same token
  template <- "{name} is {name}"
  result <- replace_token(template, "name", "Alice")
  expect_equal(result, "Alice is Alice")

  # 3. If the token does not exist, return the original template
  template <- "No token here"
  result <- replace_token(template, "name", "John")
  expect_equal(result, "No token here")

  # 4. Handle NA value: should replace with an empty string
  template <- "Missing {value}"
  result <- replace_token(template, "value", NA)
  expect_equal(result, "Missing ")

  # 5. Handle empty template: should return an empty string
  template <- ""
  result <- replace_token(template, "name", "John")
  expect_equal(result, "")

  # 6. Handle empty token: no replacement
  template <- "Hello World"
  result <- replace_token(template, "", "John")
  expect_equal(result, "Hello World")

  # 7. Handle special characters in token
  template <- "Value: {user_id-123}"
  result <- replace_token(template, "user_id-123", "X")
  expect_equal(result, "Value: X")

  # 8. Handle empty value: should replace with an empty string
  template <- "Hello {name}"
  result <- replace_token(template, "name", "")
  expect_equal(result, "Hello ")

  # 9. Handle multiple lines with the same token
  template <- c("Hello {name}", "Goodbye {name}")
  result <- replace_token(template, "name", "John")
  expect_equal(result, c("Hello John", "Goodbye John"))

  # 10. Token matching only whole words
  template <- "{name} and {name2}"
  result <- replace_token(template, "name", "A")
  expect_equal(result, "A and {name2}")

  # 11. Case sensitivity: should not match case-insensitive tokens
  template <- "Hello {Name}"
  result <- replace_token(template, "name", "John")
  expect_equal(result, "Hello {Name}")

})

test_that("convert_tokens_lowercase converts tokens correctly", {

  # 1. Single token conversion to lowercase
  input <- "Hello {Name}"
  result <- convert_tokens_lowercase(input)
  expect_equal(result, "Hello {name}")

  # 2. Multiple tokens conversion
  input <- "User: {UserName}, Role: {UserRole}"
  result <- convert_tokens_lowercase(input)
  expect_equal(result, "User: {username}, Role: {userrole}")

  # 3. No token present: should return the same string
  input <- "No tokens here"
  result <- convert_tokens_lowercase(input)
  expect_equal(result, "No tokens here")

  # 4. Mixed case tokens
  input <- "{TOKEN}, {ToKen}, {Token123}"
  result <- convert_tokens_lowercase(input)
  expect_equal(result, "{token}, {token}, {token123}")

  # 5. Empty string: should return an empty string
  input <- ""
  result <- convert_tokens_lowercase(input)
  expect_equal(result, "")

  # 6. NA value: should return NA
  input <- NA
  result <- convert_tokens_lowercase(input)
  expect_equal(result, NA_character_)

  # 7. Multiple lines (vector of strings)
  input <- c("Line 1: {TOKEN}", "Line 2: {OTHER}")
  result <- convert_tokens_lowercase(input)
  expect_equal(result, c("Line 1: {token}", "Line 2: {other}"))

  # 8. Special characters outside the token should remain unchanged
  input <- "Start {ToKeN}. End."
  result <- convert_tokens_lowercase(input)
  expect_equal(result, "Start {token}. End.")

  # 9. Handle tokens with underscores or numbers
  input <- "Value: {USER_ID_123}"
  result <- convert_tokens_lowercase(input)
  expect_equal(result, "Value: {user_id_123}")

})
