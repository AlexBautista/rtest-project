# tests/testthat/test_api_db.R
library(testthat)
library(httr)
library(DBI)
library(RSQLite)
library(dplyr)

source("R/db_helper.R")

test_that("API call and database insertion work correctly", {
  
  # Fetch data from the API
  response <- GET("https://jsonplaceholder.typicode.com/posts")
  expect_equal(status_code(response), 200)
  api_data <- content(response, "parsed")
  
  # Check that the API data has the expected structure
  expect_true(length(api_data) > 0)
  expect_true(all(c("id", "title", "body") %in% names(api_data[[1]])))
  
  # Connect to in-memory database
  con <- connect_db()
  create_posts_table(con)
  
  # Insert the API data into the database
  insert_post_data(con, api_data)
  
  # Fetch the data back from the database
  db_data <- fetch_post_data(con)
  
  # Check that the data was correctly inserted
  expect_equal(nrow(db_data), length(api_data))  # Should match the number of posts
  expect_equal(db_data$id[1], api_data[[1]]$id)  # Check if the first ID matches
  
  # Cleanup: Disconnect from the database
  dbDisconnect(con)
})
