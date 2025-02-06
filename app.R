# app.R
library(shiny)
library(httr)
library(DBI)
library(RSQLite)
library(dplyr)

# Database connection function
connect_db <- function() {
  dbConnect(RSQLite::SQLite(), ":memory:")  # In-memory database for simplicity
}

# API fetching function
fetch_api_data <- function() {
  response <- GET("https://jsonplaceholder.typicode.com/posts")
  if (status_code(response) == 200) {
    content(response, "parsed")
  } else {
    NULL
  }
}

# UI definition
ui <- fluidPage(
  titlePanel("API Data Fetch and Store in Database"),
  DT::dataTableOutput("data_table")
)

# Server logic
server <- function(input, output, session) {

  # Step 1: Fetch data from API
  api_data <- fetch_api_data()

  # Step 2: Connect to database and create table
  con <- connect_db()
  dbExecute(con, "CREATE TABLE IF NOT EXISTS posts (id INTEGER, title TEXT, body TEXT)")

  # Step 3: Insert the API data into the database
  if (!is.null(api_data)) {
    for (post in api_data) {
      dbExecute(con, "INSERT INTO posts (id, title, body) VALUES (?, ?, ?)", 
                params = list(post$id, post$title, post$body))
    }
  }

  # Step 4: Fetch the data from the database to display
  data_from_db <- dbGetQuery(con, "SELECT * FROM posts")
  
  # Output the data in a table
  output$data_table <- DT::renderDataTable({
    data_from_db
  })

  # Cleanup: Disconnect from the database
  onStop(function() {
    dbDisconnect(con)
  })
}

# Run the Shiny app
shinyApp(ui, server)
