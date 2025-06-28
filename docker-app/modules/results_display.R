# Results Display Module UI

# Helper function for safe default values
safe_default <- function(x, default = NULL) {
  if (is.null(x) || length(x) == 0 || (is.logical(x) && is.na(x))) {
    return(default)
  }
  return(x)
}

resultsDisplayUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(12,
        div(id = ns("results_content"),
          tabsetPanel(
            id = ns("results_tabs"),
            
            # Summary Tab
            tabPanel("Model Summary",
              fluidRow(
                column(12,
                  h4("Model Summary"),
                  verbatimTextOutput(ns("model_summary")),
                  br(),
                  h4("Fixed Effects"),
                  DT::dataTableOutput(ns("fixed_effects_table")),
                  br(),
                  h4("Random Effects"),
                  DT::dataTableOutput(ns("random_effects_table"))
                )
              )
            ),
            
            # Plots Tab
            tabPanel("Diagnostic Plots",
              fluidRow(
                column(6,
                  h4("Longitudinal Trajectories"),
                  plotlyOutput(ns("longitudinal_plot"))
                ),
                column(6,
                  h4("Survival Curves"),
                  plotlyOutput(ns("survival_plot"))
                )
              ),
              fluidRow(
                column(6,
                  h4("Residuals Plot"),
                  plotlyOutput(ns("residuals_plot"))
                ),
                column(6,
                  h4("Random Effects Plot"),
                  plotlyOutput(ns("random_effects_plot"))
                )
              )
            ),
            
            # Predictions Tab
            tabPanel("Predictions",
              fluidRow(
                column(4,
                  h4("Prediction Settings"),
                  numericInput(ns("pred_time"), "Prediction Time:", 
                              value = 5, min = 0, step = 0.5),
                  selectInput(ns("pred_type"), "Prediction Type:",
                             choices = c("Longitudinal" = "longitudinal",
                                       "Survival" = "survival",
                                       "Both" = "both")),
                  actionButton(ns("generate_predictions"), "Generate Predictions",
                              class = "btn-primary")
                ),
                column(8,
                  h4("Prediction Results"),
                  DT::dataTableOutput(ns("predictions_table"))
                )
              )
            ),
            
            # Export Tab
            tabPanel("Export Results",
              fluidRow(
                column(12,
                  h4("Export Options"),
                  br(),
                  fluidRow(
                    column(3,
                      h5("Summary Export"),
                      downloadButton(ns("download_summary"), "Download Summary",
                                   class = "btn-info btn-block")
                    ),
                    column(3,
                      h5("Coefficients Export"),
                      downloadButton(ns("download_coefficients"), "Download Coefficients",
                                   class = "btn-info btn-block")
                    ),
                    column(3,
                      h5("Predictions Export"),
                      downloadButton(ns("download_predictions"), "Download Predictions",
                                   class = "btn-info btn-block")
                    ),
                    column(3,
                      h5("Full Model Export"),
                      downloadButton(ns("download_model"), "Download Model (.RData)",
                                   class = "btn-success btn-block")
                    )
                  )
                )
              )
            )
          )
        ),
        
        # No results message (will be hidden when model is available)
        div(id = ns("no_results"),
          style = "text-align: center; padding: 50px;",
          h3("No Model Results Available"),
          p("Please configure and run a joint model to see results here."),
          icon("chart-line", class = "fa-5x text-muted")
        )
      )
    )
  )
}

# Results Display Module Server
resultsDisplayServer <- function(id, values) {
  moduleServer(id, function(input, output, session) {
    
    # Model Summary
    output$model_summary <- renderText({
      if (!is.null(values$model_result)) {
        capture.output(print(values$model_result))
      } else {
        "No model results available. Please run a model first."
      }
    })
    
    # Fixed Effects Table
    output$fixed_effects_table <- DT::renderDataTable({
      if (!is.null(values$model_result)) {
        tryCatch({
          fixed_effects <- coef(values$model_result)
          if (is.matrix(fixed_effects) || is.data.frame(fixed_effects)) {
            DT::datatable(fixed_effects, options = list(scrollX = TRUE))
          } else {
            # Handle case where coef returns a different structure
            df <- data.frame(
              Parameter = names(fixed_effects),
              Estimate = fixed_effects,
              stringsAsFactors = FALSE
            )
            DT::datatable(df, options = list(scrollX = TRUE))
          }
        }, error = function(e) {
          DT::datatable(data.frame(Message = "Fixed effects will appear here after running a model"))
        })
      } else {
        DT::datatable(data.frame(Message = "No model results available"))
      }
    })
    
    # Random Effects Table
    output$random_effects_table <- DT::renderDataTable({
      if (!is.null(values$model_result)) {
        tryCatch({
          random_effects <- ranef(values$model_result)
          if (is.list(random_effects)) {
            # Combine random effects from different groups
            re_df <- do.call(rbind, lapply(names(random_effects), function(grp) {
              re_grp <- random_effects[[grp]]
              if (is.matrix(re_grp) || is.data.frame(re_grp)) {
                re_grp$Group <- grp
                re_grp$ID <- rownames(re_grp)
                return(re_grp)
              }
              return(NULL)
            }))
            DT::datatable(re_df, options = list(scrollX = TRUE))
          } else {
            DT::datatable(random_effects, options = list(scrollX = TRUE))
          }
        }, error = function(e) {
          DT::datatable(data.frame(Message = "Random effects will appear here after running a model"))
        })
      } else {
        DT::datatable(data.frame(Message = "No model results available"))
      }
    })
    
    # Longitudinal Plot
    output$longitudinal_plot <- renderPlotly({
      if (!is.null(values$model_result) && !is.null(values$longitudinal_data)) {
        tryCatch({
          # Create a basic longitudinal trajectories plot
          time_var <- safe_default(input$time_var, "time")
          outcome_var <- safe_default(input$outcome_var, "y") 
          id_var <- safe_default(input$id_var, "id")
          
          p <- plot_ly(data = values$longitudinal_data,
                      x = ~get(time_var),
                      y = ~get(outcome_var),
                      color = ~as.factor(get(id_var)),
                      type = "scatter",
                      mode = "lines+markers",
                      showlegend = FALSE) %>%
            layout(title = "Longitudinal Trajectories",
                  xaxis = list(title = "Time"),
                  yaxis = list(title = "Outcome"))
          p
        }, error = function(e) {
          plot_ly() %>% 
            add_text(x = 0.5, y = 0.5, text = paste("Error creating plot:", e$message))
        })
      } else {
        plot_ly() %>% 
          add_text(x = 0.5, y = 0.5, text = "Run a model to see longitudinal trajectories") %>%
          layout(title = "Longitudinal Plot",
                xaxis = list(title = ""),
                yaxis = list(title = ""))
      }
    })
    
    # Survival Plot
    output$survival_plot <- renderPlotly({
      if (!is.null(values$model_result) && !is.null(values$survival_data)) {
        tryCatch({
          # Basic survival plot - this would need to be customized based on your survival data structure
          plot_ly() %>% 
            add_text(x = 0.5, y = 0.5, text = "Survival plot implementation needed")
        }, error = function(e) {
          plot_ly() %>% 
            add_text(x = 0.5, y = 0.5, text = paste("Error creating survival plot:", e$message))
        })
      } else {
        plot_ly() %>% 
          add_text(x = 0.5, y = 0.5, text = "Run a model to see survival curves") %>%
          layout(title = "Survival Plot",
                xaxis = list(title = ""),
                yaxis = list(title = ""))
      }
    })
    
    # Residuals Plot
    output$residuals_plot <- renderPlotly({
      if (!is.null(values$model_result)) {
        tryCatch({
          fitted_vals <- fitted(values$model_result)
          residuals_vals <- residuals(values$model_result)
          
          plot_ly(x = fitted_vals, y = residuals_vals,
                  type = "scatter", mode = "markers") %>%
            layout(title = "Residuals vs Fitted",
                  xaxis = list(title = "Fitted Values"),
                  yaxis = list(title = "Residuals"))
        }, error = function(e) {
          plot_ly() %>% 
            add_text(x = 0.5, y = 0.5, text = paste("Error creating residuals plot:", e$message))
        })
      } else {
        plot_ly() %>% 
          add_text(x = 0.5, y = 0.5, text = "Run a model to see residual plots") %>%
          layout(title = "Residuals Plot",
                xaxis = list(title = ""),
                yaxis = list(title = ""))
      }
    })
    
    # Random Effects Plot
    output$random_effects_plot <- renderPlotly({
      if (!is.null(values$model_result)) {
        tryCatch({
          plot_ly() %>% 
            add_text(x = 0.5, y = 0.5, text = "Random effects plot implementation needed")
        }, error = function(e) {
          plot_ly() %>% 
            add_text(x = 0.5, y = 0.5, text = paste("Error creating random effects plot:", e$message))
        })
      } else {
        plot_ly() %>% 
          add_text(x = 0.5, y = 0.5, text = "Run a model to see random effects") %>%
          layout(title = "Random Effects Plot",
                xaxis = list(title = ""),
                yaxis = list(title = ""))
      }
    })
    
    # Predictions
    predictions_data <- reactiveVal(NULL)
    
    observeEvent(input$generate_predictions, {
      if (!is.null(values$model_result)) {
        tryCatch({
          # Generate predictions - this is a placeholder implementation
          # You would customize this based on the predict method for INLAjoint objects
          pred_result <- predict(values$model_result)
          predictions_data(pred_result)
          showNotification("Predictions generated successfully!", type = "message")
        }, error = function(e) {
          showNotification(paste("Error generating predictions:", e$message), type = "error")
        })
      }
    })
    
    output$predictions_table <- DT::renderDataTable({
      if (!is.null(predictions_data())) {
        DT::datatable(predictions_data(), options = list(scrollX = TRUE))
      }
    })
    
    # Download handlers
    output$download_summary <- downloadHandler(
      filename = function() {
        paste("inlajoint_summary_", Sys.Date(), ".txt", sep = "")
      },
      content = function(file) {
        if (!is.null(values$model_result)) {
          writeLines(capture.output(summary(values$model_result)), file)
        }
      }
    )
    
    output$download_coefficients <- downloadHandler(
      filename = function() {
        paste("inlajoint_coefficients_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        if (!is.null(values$model_result)) {
          coeffs <- coef(values$model_result)
          write.csv(coeffs, file, row.names = TRUE)
        }
      }
    )
    
    output$download_predictions <- downloadHandler(
      filename = function() {
        paste("inlajoint_predictions_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        if (!is.null(predictions_data())) {
          write.csv(predictions_data(), file, row.names = FALSE)
        }
      }
    )
    
    output$download_model <- downloadHandler(
      filename = function() {
        paste("inlajoint_model_", Sys.Date(), ".RData", sep = "")
      },
      content = function(file) {
        if (!is.null(values$model_result)) {
          model_result <- values$model_result
          save(model_result, file = file)
        }
      }
    )
  })
}
