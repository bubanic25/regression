
library(shiny)
library(tidyquant)
library(forecast)
library(ggthemes)
library(tseries)
library(lubridate)
library(timetk)
library(readxl)
library(scales)
library(forecast)  
library(rlang) #  forecasting pkg
library(sweep)   # Broom tidiers for forecast pkg
library(broom)
library(tibble)
library(stringr)
library(highcharter)
library(knitr)
library(quantmod)
library(shinythemes)
library(ggforce)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  observeEvent(input$run, {
    
    
    
    output$topPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      withProgress(message = 'Making Chart 1', value = 0, {  
        incProgress(.1)
        
        
        
        df <- data.frame()
        
        df <- na.omit(tq_get(isolate(input$ticker),
                             from = isolate(input$dateStart),
                             to = isolate(input$dateEnd), get="stock.prices") )
        
        df = subset(df, select = -c(symbol,open,high,low,volume,adjusted) )
        
        incProgress(.3)
        
        names(df)[names(df) == "close"] <- "Actual"
        dat_ts = ts(df["Actual"])
        (fit <- nnetar(dat_ts, lambda=0.5, na.rm = TRUE))
        
        sim <- ts(matrix(0, nrow=isolate(input$sliderForecast), ncol=5), start=end(dat_ts)[1]+1)
        for(i in seq(5))
          sim[,i] <- simulate(fit, nsim=isolate(input$sliderForecast))
        
        incProgress(.3)
        autoplot(dat_ts, legend=TRUE, ylab="", xlab="Days", height=1000) + forecast::autolayer(sim)
        
        
        
      })
      
    })
    
    output$bottomPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      withProgress(message = 'Making Chart 2', value = 0, {  
        incProgress(.1,detail = paste("Takes a Little While"))
        
        df <- data.frame()
        
        df <- na.omit(tq_get(isolate(input$ticker),
                             from = isolate(input$dateStart),
                             to = isolate(input$dateEnd), get="stock.prices") )
        
        df = subset(df, select = -c(symbol,open,high,low,volume,adjusted) )
        incProgress(.2, detail = paste("Takes a Little While"))
        names(df)[names(df) == "close"] <- "Actual"
        dat_ts = ts(df["Actual"])
        (fit <- nnetar(dat_ts, lambda=0.5, na.rm = TRUE))
        incProgress(.1,detail = paste("Takes a Little While"))
        sim <- ts(matrix(0, nrow=isolate(input$sliderForecast), ncol=5), start=end(dat_ts)[1]+1)
        for(i in seq(5))
          sim[,i] <- simulate(fit, nsim=isolate(input$sliderForecast))
        incProgress(.2,  detail = paste("Takes a Little While"))
        
        
        fcast <- forecast(fit, PI=TRUE, h=isolate(input$sliderForecast),  nnetar=isolate(input$sliderSims)  )
        incProgress(.1)
        autoplot(fcast, legend=TRUE, ylab="", xlab="Days", height=1000) 
        
        
      })  
      
    })
    
    
    
    
    
  })
  
  observeEvent(input$topPolot_dblclick, {
    brush <- input$topPlot_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges$x <- NULL
      ranges$y <- NULL
    }
  })
  
  
  
  
  
}





# Run the application 
shinyApp(ui = ui, server = server)
