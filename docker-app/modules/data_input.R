# Data Input Module UI
dataInputUI <- function(id) {
  ns <- NS(id)
  
  if (id == "csv_input") {
    tagList(
      h4("Upload CSV Files"),
      fluidRow(
        column(6,
          fileInput(ns("longitudinal_file"), "Longitudinal Data (CSV):",
                   accept = c(".csv", ".xlsx", ".xls")),
          checkboxInput(ns("header_long"), "Header", TRUE),
          radioButtons(ns("sep_long"), "Separator:",
                      choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                      selected = ",", inline = TRUE)
        ),
        column(6,
          fileInput(ns("survival_file"), "Survival Data (CSV, Optional):",
                   accept = c(".csv", ".xlsx", ".xls")),
          checkboxInput(ns("header_surv"), "Header", TRUE),
          radioButtons(ns("sep_surv"), "Separator:",
                      choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                      selected = ",", inline = TRUE)
        )
      ),
      actionButton(ns("load_csv"), "Load Data", class = "btn-primary")
    )
  } else if (id == "db_input") {
    tagList(
      h4("Database Connection"),
      fluidRow(
        column(4,
          selectInput(ns("db_type"), "Database Type:",
                     choices = c("PostgreSQL" = "postgresql",
                               "MySQL" = "mysql",
                               "SQLite" = "sqlite"))
        ),
        column(4,
          textInput(ns("db_host"), "Host:", value = "localhost")
        ),
        column(4,
          numericInput(ns("db_port"), "Port:", value = 5432, min = 1, max = 65535)
        )
      ),
      fluidRow(
        column(3,
          textInput(ns("db_name"), "Database Name:")
        ),
        column(3,
          textInput(ns("db_user"), "Username:")
        ),
        column(3,
          passwordInput(ns("db_password"), "Password:")
        ),
        column(3,
          br(),
          actionButton(ns("test_connection"), "Test Connection", class = "btn-info")
        )
      ),
      hr(),
      fluidRow(
        column(6,
          textAreaInput(ns("long_query"), "Longitudinal Data Query:",
                       placeholder = "SELECT * FROM longitudinal_table",
                       height = "100px")
        ),
        column(6,
          textAreaInput(ns("surv_query"), "Survival Data Query (Optional):",
                       placeholder = "SELECT * FROM survival_table",
                       height = "100px")
        )
      ),
      actionButton(ns("load_db"), "Load Data from Database", class = "btn-primary"),
      br(), br(),
      verbatimTextOutput(ns("connection_status"))
    )
  } else if (id == "sample_input") {
    tagList(
      h4("Sample Datasets"),
      p("Use built-in sample datasets to explore INLAjoint functionality."),
      selectInput(ns("sample_dataset"), "Choose Sample Dataset:",
                 choices = list(
                   "Longitudinal + Survival (LongMS + SurvMS)" = "longms_survms",
                   "Longitudinal + Survival (Longsim + Survsim)" = "longsim_survsim"
                 )),
      actionButton(ns("load_sample"), "Load Sample Data", class = "btn-primary"),
      br(), br(),
      div(id = ns("sample_info"),
        h5("Dataset Information:"),
        p("Sample datasets demonstrate different types of joint models with various association structures.")
      )
    )
  }
}

# Data Input Module Server
dataInputServer <- function(id, values, type) {
  moduleServer(id, function(input, output, session) {
    
    if (type == "csv") {
      # CSV file upload logic
      observeEvent(input$load_csv, {
        req(input$longitudinal_file)
        
        # Load longitudinal data
        tryCatch({
          ext <- tools::file_ext(input$longitudinal_file$datapath)
          if (ext == "csv") {
            values$longitudinal_data <- read_csv(input$longitudinal_file$datapath,
                                               col_names = input$header_long,
                                               locale = locale(encoding = "UTF-8"))
          } else if (ext %in% c("xlsx", "xls")) {
            values$longitudinal_data <- read_excel(input$longitudinal_file$datapath,
                                                 col_names = input$header_long)
          }
          
          # Load survival data if provided
          if (!is.null(input$survival_file)) {
            ext_surv <- tools::file_ext(input$survival_file$datapath)
            if (ext_surv == "csv") {
              values$survival_data <- read_csv(input$survival_file$datapath,
                                             col_names = input$header_surv,
                                             locale = locale(encoding = "UTF-8"))
            } else if (ext_surv %in% c("xlsx", "xls")) {
              values$survival_data <- read_excel(input$survival_file$datapath,
                                               col_names = input$header_surv)
            }
          }
          
          values$data_source <- "csv"
          showNotification("Data loaded successfully!", type = "message")
          
        }, error = function(e) {
          showNotification(paste("Error loading data:", e$message), type = "error")
        })
      })
      
    } else if (type == "database") {
      # Database connection logic
      output$connection_status <- renderText({
        ""
      })
      
      observeEvent(input$test_connection, {
        tryCatch({
          conn <- connect_to_database(input$db_type, input$db_host, input$db_port,
                                    input$db_name, input$db_user, input$db_password)
          DBI::dbDisconnect(conn)
          output$connection_status <- renderText({
            "✓ Connection successful!"
          })
          showNotification("Database connection successful!", type = "message")
        }, error = function(e) {
          output$connection_status <- renderText({
            paste("✗ Connection failed:", e$message)
          })
          showNotification(paste("Connection failed:", e$message), type = "error")
        })
      })
      
      observeEvent(input$load_db, {
        req(input$long_query)
        
        tryCatch({
          conn <- connect_to_database(input$db_type, input$db_host, input$db_port,
                                    input$db_name, input$db_user, input$db_password)
          
          # Load longitudinal data
          values$longitudinal_data <- DBI::dbGetQuery(conn, input$long_query)
          
          # Load survival data if query provided
          if (nzchar(input$surv_query)) {
            values$survival_data <- DBI::dbGetQuery(conn, input$surv_query)
          }
          
          DBI::dbDisconnect(conn)
          values$data_source <- "database"
          showNotification("Data loaded from database successfully!", type = "message")
          
        }, error = function(e) {
          showNotification(paste("Error loading data from database:", e$message), type = "error")
        })
      })
      
    } else if (type == "sample") {
      # Sample data loading logic
      observeEvent(input$load_sample, {
        tryCatch({
          if (input$sample_dataset == "longms_survms") {
            # Try to load real data, otherwise create mock data
            tryCatch({
              data("LongMS", package = "INLAjoint")
              data("SurvMS", package = "INLAjoint")
              values$longitudinal_data <- LongMS
              values$survival_data <- SurvMS
            }, error = function(e) {
              # Create mock longitudinal data
              set.seed(123)
              n_subjects <- 10
              n_obs_per_subject <- 4
              
              long_data <- data.frame(
                id = rep(1:n_subjects, each = n_obs_per_subject),
                time = rep(0:(n_obs_per_subject-1), n_subjects),
                X = rep(rbinom(n_subjects, 1, 0.5), each = n_obs_per_subject),
                y = NA
              )
              
              # Generate realistic longitudinal outcomes
              for(i in 1:n_subjects) {
                rows <- long_data$id == i
                baseline <- rnorm(1, 10, 2)
                slope <- rnorm(1, 1.5, 0.5)
                treatment_effect <- long_data$X[rows][1] * (-0.5)
                
                long_data$y[rows] <- baseline + 
                                   slope * long_data$time[rows] + 
                                   treatment_effect + 
                                   rnorm(sum(rows), 0, 0.5)
              }
              
              # Create mock survival data
              surv_data <- data.frame(
                id = 1:n_subjects,
                X = sapply(1:n_subjects, function(i) long_data$X[long_data$id == i][1]),
                time = rexp(n_subjects, rate = 0.2),
                event = rbinom(n_subjects, 1, 0.7)
              )
              
              values$longitudinal_data <- long_data
              values$survival_data <- surv_data
            })
          } else if (input$sample_dataset == "longsim_survsim") {
            # Try to load real data, otherwise create different mock data
            tryCatch({
              data("Longsim", package = "INLAjoint")
              data("Survsim", package = "INLAjoint")
              values$longitudinal_data <- Longsim
              values$survival_data <- Survsim
            }, error = function(e) {
              # Create alternative mock data
              set.seed(456)
              n_subjects <- 15
              n_obs_per_subject <- 5
              
              long_data <- data.frame(
                id = rep(1:n_subjects, each = n_obs_per_subject),
                time = rep(0:(n_obs_per_subject-1), n_subjects),
                X = rep(rnorm(n_subjects, 0, 1), each = n_obs_per_subject),
                y = NA
              )
              
              # Generate multivariate longitudinal outcomes
              for(i in 1:n_subjects) {
                rows <- long_data$id == i
                baseline <- rnorm(1, 8, 1.5)
                slope <- rnorm(1, 2, 0.3)
                covariate_effect <- long_data$X[rows][1] * 0.8
                
                long_data$y[rows] <- baseline + 
                                   slope * long_data$time[rows] + 
                                   covariate_effect + 
                                   rnorm(sum(rows), 0, 0.8)
              }
              
              # Create corresponding survival data
              surv_data <- data.frame(
                id = 1:n_subjects,
                X = sapply(1:n_subjects, function(i) long_data$X[long_data$id == i][1]),
                time = rweibull(n_subjects, shape = 1.5, scale = 5),
                event = rbinom(n_subjects, 1, 0.6)
              )
              
              values$longitudinal_data <- long_data
              values$survival_data <- surv_data
            })
          }
          
          values$data_source <- "sample"
          showNotification("Sample data loaded successfully!", type = "message")
          
        }, error = function(e) {
          showNotification(paste("Error loading sample data:", e$message), type = "error")
        })
      })
    }
  })
}
