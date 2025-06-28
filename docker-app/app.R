library(shiny)
library(shinydashboard)
library(DT)
library(plotly)

# Try to load INLAjoint, but continue without it if not available
tryCatch({
  library(INLAjoint)
  INLAJOINT_AVAILABLE <- TRUE
}, error = function(e) {
  message("INLAjoint not available: ", e$message)
  INLAJOINT_AVAILABLE <- FALSE
})

# Database connection libraries
library(RPostgreSQL)
library(RMySQL)
library(RSQLite)

# Data import libraries
library(readr)
library(readxl)

# Define null coalescing operator
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

source("modules/data_input.R")
source("modules/model_config.R")
source("modules/results_display.R")
source("utils/database_utils.R")
source("utils/data_utils.R")
source("utils/general_utils.R")
source("utils/mock_inla.R")

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "INLAjoint Web Interface"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Input", tabName = "data_input", icon = icon("upload")),
      menuItem("Model Configuration", tabName = "model_config", icon = icon("cog")),
      menuItem("Results", tabName = "results", icon = icon("chart-line")),
      menuItem("Help", tabName = "help", icon = icon("question"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .box {
          border-radius: 5px;
        }
        .btn-primary {
          background-color: #3c8dbc;
          border-color: #3c8dbc;
        }
      "))
    ),
    
    tabItems(
      # Data Input Tab
      tabItem(tabName = "data_input",
        fluidRow(
          box(
            title = "Data Source Selection", status = "primary", solidHeader = TRUE,
            width = 12,
            
            radioButtons("data_source", "Choose Data Source:",
              choices = list(
                "Upload CSV Files" = "csv",
                "Database Connection" = "database",
                "Sample Data" = "sample"
              ),
              selected = "csv"
            ),
            
            # CSV Upload Panel
            conditionalPanel(
              condition = "input.data_source == 'csv'",
              dataInputUI("csv_input")
            ),
            
            # Database Connection Panel
            conditionalPanel(
              condition = "input.data_source == 'database'",
              dataInputUI("db_input")
            ),
            
            # Sample Data Panel
            conditionalPanel(
              condition = "input.data_source == 'sample'",
              dataInputUI("sample_input")
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Data Preview", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("data_preview")
          )
        )
      ),
      
      # Model Configuration Tab
      tabItem(tabName = "model_config",
        fluidRow(
          box(
            title = "Model Setup", status = "primary", solidHeader = TRUE,
            width = 12,
            modelConfigUI("model_setup")
          )
        )
      ),
      
      # Results Tab
      tabItem(tabName = "results",
        fluidRow(
          box(
            title = "Model Results", status = "success", solidHeader = TRUE,
            width = 12,
            resultsDisplayUI("results_display")
          )
        )
      ),
      
      # Help Tab
      tabItem(tabName = "help",
        fluidRow(
          box(
            title = "INLAjoint Help", status = "info", solidHeader = TRUE,
            width = 12,
            includeMarkdown("help/help.md")
          )
        )
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  # Reactive values to store data
  values <- reactiveValues(
    longitudinal_data = NULL,
    survival_data = NULL,
    model_result = NULL,
    data_source = NULL
  )
  
  # Data Input Modules
  dataInputServer("csv_input", values, "csv")
  dataInputServer("db_input", values, "database")
  dataInputServer("sample_input", values, "sample")
  
  # Model Configuration Module
  modelConfigServer("model_setup", values)
  
  # Results Display Module
  resultsDisplayServer("results_display", values)
  
  # Data Preview
  output$data_preview <- DT::renderDataTable({
    if (input$data_source == "csv" && !is.null(values$longitudinal_data)) {
      DT::datatable(values$longitudinal_data, 
                    options = list(scrollX = TRUE, pageLength = 10))
    } else if (input$data_source == "database" && !is.null(values$longitudinal_data)) {
      DT::datatable(values$longitudinal_data, 
                    options = list(scrollX = TRUE, pageLength = 10))
    } else if (input$data_source == "sample" && !is.null(values$longitudinal_data)) {
      DT::datatable(values$longitudinal_data, 
                    options = list(scrollX = TRUE, pageLength = 10))
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
