# Model Configuration Module UI

# Helper function for safe default values
safe_default <- function(x, default = NULL) {
  if (is.null(x) || length(x) == 0 || (is.logical(x) && is.na(x))) {
    return(default)
  }
  return(x)
}

modelConfigUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(6,
        h4("Model Formulas"),
        div(
          h5("Longitudinal Formula"),
          textAreaInput(ns("formula_long"), 
                       label = NULL,
                       placeholder = "y ~ time + X + (1 + time | id)",
                       height = "80px"),
          helpText("Specify the longitudinal formula using lme4 syntax")
        ),
        div(
          h5("Survival Formula"),
          textAreaInput(ns("formula_surv"), 
                       label = NULL,
                       placeholder = "inla.surv(time_to_event, event) ~ X",
                       height = "80px"),
          helpText("Specify the survival formula using inla.surv()")
        )
      ),
      column(6,
        h4("Model Parameters"),
        selectInput(ns("family_long"), "Longitudinal Family:",
                   choices = c("Gaussian" = "gaussian",
                             "Poisson" = "poisson",
                             "Binomial" = "binomial",
                             "Gamma" = "gamma")),
        selectInput(ns("baseline_risk"), "Baseline Risk:",
                   choices = c("Random Walk 1" = "rw1",
                             "Random Walk 2" = "rw2",
                             "Exponential" = "exponentialsurv",
                             "Weibull" = "weibullsurv")),
        numericInput(ns("n_intervals"), "Number of Intervals:", 
                    value = 20, min = 5, max = 100)
      )
    ),
    
    fluidRow(
      column(6,
        h4("Data Configuration"),
        selectInput(ns("id_var"), "ID Variable:",
                   choices = NULL),
        selectInput(ns("time_var"), "Time Variable:",
                   choices = NULL),
        selectInput(ns("outcome_var"), "Outcome Variable:",
                   choices = NULL)
      ),
      column(6,
        h4("Association Structure"),
        selectInput(ns("association"), "Association Type:",
                   choices = c("Current Value" = "CV",
                             "Current Slope" = "CS",
                             "Current Value + Slope" = "CV_CS",
                             "Shared Random Effects" = "SRE",
                             "SRE Independent" = "SRE_ind",
                             "No Association" = "")),
        checkboxInput(ns("correlated_re"), "Correlated Random Effects", FALSE)
      )
    ),
    
    hr(),
    
    fluidRow(
      column(12,
        h4("Advanced Options"),
        checkboxInput(ns("show_advanced"), "Show Advanced Options", FALSE),
        conditionalPanel(
          condition = paste0("input['", ns("show_advanced"), "']"),
          fluidRow(
            column(4,
              h5("Prior Settings"),
              numericInput(ns("prior_fixed_mean"), "Fixed Effects Prior Mean:", 
                          value = 0),
              numericInput(ns("prior_fixed_prec"), "Fixed Effects Prior Precision:", 
                          value = 0.01, min = 0.001, step = 0.001)
            ),
            column(4,
              h5("Control Options"),
              checkboxInput(ns("silent_mode"), "Silent Mode", FALSE),
              checkboxInput(ns("data_only"), "Data Only (No Model Run)", FALSE)
            ),
            column(4,
              h5("Output Options"),
              checkboxInput(ns("include_plots"), "Include Diagnostic Plots", TRUE),
              checkboxInput(ns("detailed_output"), "Detailed Output", FALSE)
            )
          )
        )
      )
    ),
    
    hr(),
    
    fluidRow(
      column(12,
        actionButton(ns("run_model"), "Run Joint Model", 
                    class = "btn-success btn-lg",
                    style = "width: 200px;"),
        br(), br(),
        verbatimTextOutput(ns("model_status"))
      )
    )
  )
}

# Model Configuration Module Server
modelConfigServer <- function(id, values) {
  moduleServer(id, function(input, output, session) {
    
    # Update variable choices when data is loaded
    observe({
      if (!is.null(values$longitudinal_data)) {
        var_choices <- names(values$longitudinal_data)
        
        updateSelectInput(session, "id_var", choices = var_choices)
        updateSelectInput(session, "time_var", choices = var_choices)
        updateSelectInput(session, "outcome_var", choices = var_choices)
      }
    })
    
    # Model status output
    output$model_status <- renderText({
      ""
    })
    
    # Run model when button is clicked
    observeEvent(input$run_model, {
      req(values$longitudinal_data)
      
      # Validate inputs
      if (is.null(input$formula_long) || nzchar(input$formula_long) == FALSE) {
        showNotification("Please specify a longitudinal formula", type = "error")
        return()
      }
      
      if (is.null(input$id_var) || input$id_var == "") {
        showNotification("Please select an ID variable", type = "error")
        return()
      }
      
      output$model_status <- renderText({
        "Running model... This may take several minutes."
      })
      
      tryCatch({
        # Prepare model arguments
        model_args <- list(
          formLong = as.formula(input$formula_long),
          dataLong = values$longitudinal_data,
          id = input$id_var,
          family = input$family_long,
          basRisk = input$baseline_risk,
          NbasRisk = input$n_intervals,
          silentMode = safe_default(input$silent_mode, FALSE),
          dataOnly = safe_default(input$data_only, FALSE)
        )
        
        # Add survival components if available
        if (!is.null(values$survival_data) && 
            !is.null(input$formula_surv) && 
            nzchar(input$formula_surv)) {
          model_args$formSurv <- as.formula(input$formula_surv)
          model_args$dataSurv <- values$survival_data
        }
        
        # Add time variable if specified
        if (!is.null(input$time_var) && input$time_var != "") {
          model_args$timeVar <- input$time_var
        }
        
        # Add association if specified
        if (!is.null(input$association) && input$association != "") {
          model_args$assoc <- input$association
        }
        
        # Add advanced options if specified
        if (safe_default(input$show_advanced, FALSE)) {
          control_list <- list(
            priorFixed = list(
              mean = safe_default(input$prior_fixed_mean, 0),
              prec = safe_default(input$prior_fixed_prec, 0.01)
            )
          )
          model_args$control <- control_list
        }
        
        # Run the model
        output$model_status <- renderText({
          "Model running... Please wait."
        })
        
        values$model_result <- do.call(safe_joint, model_args)
        
        output$model_status <- renderText({
          "✓ Model completed successfully!"
        })
        
        showNotification("Joint model completed successfully!", type = "message")
        
      }, error = function(e) {
        output$model_status <- renderText({
          paste("✗ Model failed:", e$message)
        })
        showNotification(paste("Model failed:", e$message), type = "error")
      })
    })
  })
}
