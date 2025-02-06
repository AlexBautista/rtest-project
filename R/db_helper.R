# R/db_helper.R

connect_db <- function() {
  dbConnect(RSQLite::SQLite(), ":memory:")
}

create_posts_table <- function(con) {
  dbExecute(con, "CREATE TABLE IF NOT EXISTS posts (id INTEGER, title TEXT, body TEXT)")
}

insert_post_data <- function(con, data) {
  for (post in data) {
    dbExecute(con, "INSERT INTO posts (id, title, body) VALUES (?, ?, ?)", 
              params = list(post$id, post$title, post$body))
  }
}

fetch_post_data <- function(con) {
  dbGetQuery(con, "SELECT * FROM posts")
}
