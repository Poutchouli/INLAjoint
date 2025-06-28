# Database connection utilities

#' Connect to database
#' @param db_type Database type (postgresql, mysql, sqlite)
#' @param host Database host
#' @param port Database port
#' @param dbname Database name
#' @param user Username
#' @param password Password
#' @return Database connection object
connect_to_database <- function(db_type, host, port, dbname, user, password) {
  
  if (db_type == "postgresql") {
    conn <- RPostgreSQL::dbConnect(
      RPostgreSQL::PostgreSQL(),
      host = host,
      port = port,
      dbname = dbname,
      user = user,
      password = password
    )
  } else if (db_type == "mysql") {
    conn <- RMySQL::dbConnect(
      RMySQL::MySQL(),
      host = host,
      port = port,
      dbname = dbname,
      username = user,
      password = password
    )
  } else if (db_type == "sqlite") {
    conn <- RSQLite::dbConnect(
      RSQLite::SQLite(),
      dbname = dbname
    )
  } else {
    stop("Unsupported database type")
  }
  
  return(conn)
}

#' Test database connection
#' @param db_type Database type
#' @param host Database host
#' @param port Database port
#' @param dbname Database name
#' @param user Username
#' @param password Password
#' @return TRUE if connection successful, FALSE otherwise
test_database_connection <- function(db_type, host, port, dbname, user, password) {
  tryCatch({
    conn <- connect_to_database(db_type, host, port, dbname, user, password)
    DBI::dbDisconnect(conn)
    return(TRUE)
  }, error = function(e) {
    return(FALSE)
  })
}

#' Get table names from database
#' @param conn Database connection
#' @return Vector of table names
get_table_names <- function(conn) {
  tryCatch({
    return(DBI::dbListTables(conn))
  }, error = function(e) {
    return(character(0))
  })
}

#' Get column names from table
#' @param conn Database connection
#' @param table_name Table name
#' @return Vector of column names
get_column_names <- function(conn, table_name) {
  tryCatch({
    return(DBI::dbListFields(conn, table_name))
  }, error = function(e) {
    return(character(0))
  })
}

#' Execute query and return data frame
#' @param conn Database connection
#' @param query SQL query
#' @return Data frame with query results
execute_query <- function(conn, query) {
  tryCatch({
    return(DBI::dbGetQuery(conn, query))
  }, error = function(e) {
    stop(paste("Query execution failed:", e$message))
  })
}
