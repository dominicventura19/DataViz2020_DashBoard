library(shiny)
library(shinydashboard)
library(ggplot2)
library(readr)
library(maps)
library(mapproj)
library(DT)
library(tidyverse)
library(lubridate)
library(plotly)

earthquakes <- read_csv("earthquakes.csv")

shinyServer(function(input, output, session) {
  
  df <- reactiveFileReader(
    intervalMillis = 10000, 
    session = session,
    filePath = 'earthquakes.csv',
    readFunc = read_csv)
  
  output$mydata <- renderDataTable({
    df <- df()
    dta <- df %>% group_by(country) %>% count() %>% na.omit() %>% arrange(desc(n))
    colnames(dta) <- c("Country/State", "# of Earthquakes")
    dta
  
  })
  
  output$myplot <- renderPlot({
    world <- map_data('world')
    
    if (input$options == "All") {
      allQuakes <- ggplot() + geom_map(data = world, map = world, aes(x = long, y=lat, group=group, map_id=region), 
                                       fill="gray", colour="#7f7f7f", size=0.5) + 
        theme_minimal() + 
        geom_point(data = earthquakes, aes(x=longitude, y = latitude, color = mag)) +
        scale_colour_gradient(low = "darkgreen", high = "red") 
      return(allQuakes)
      
    }
    
    if (input$options == "Specific"){
      
      c <- sort(unique(earthquakes$country)) %>% na.omit
      
      eq.filtered <- earthquakes %>% filter(country == req(input$specific))
      
      p <- ggplot() + geom_map(data = world, map = world, aes(x = long, y=lat, group=group, map_id=region), 
                               fill="gray", colour="#7f7f7f", size=0.5) + 
        theme_minimal() + 
        geom_point(data = eq.filtered, aes(x=longitude, y = latitude, color = mag, size = mag)) + 
        scale_size(guide = 'none') +
        scale_colour_gradient(low = "darkgreen", high = "magenta") 
      return(p)
      
    }
    
    if (input$options == "Date") {
  
      dateQuakes <- earthquakes %>% filter(month(as.Date(time)) == input$month) %>% 
        filter(day(as.Date(time)) == input$day)
      
      QuakesByDate <- ggplot() + geom_map(data = world, map = world, aes(x = long, y=lat, group=group, map_id=region), 
                                          fill="gray", colour="#7f7f7f", size=0.5) + 
        theme_minimal() +
        geom_point(data = dateQuakes, aes(x=longitude, y = latitude, color = mag, size = mag)) + 
        scale_size(guide = 'none') +
        scale_colour_gradient(low = "darkgreen", high = "magenta") 
      return(QuakesByDate)
    }
    
  })
  
  output$myTimeSeries <- renderPlotly({
    
    TSEarthquakes <- earthquakes %>% select(time, country) %>% filter(country == input$countriesTS) %>% 
                    group_by(year(as.Date(time))) %>% count() %>% ungroup() %>% mutate(new = cumsum(n))
    
    colnames(TSEarthquakes) <- c("Year", "Quakes in year", "Overall")
    
    
    TSeries <- ggplot(TSEarthquakes, aes(x=Year, y=Overall)) + geom_point(colour = "red", size = 2) + geom_line()
    return(ggplotly(TSeries))
    
  })
  
})
