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



shinyServer(function(input, output, session) {
  
  df <- reactiveFileReader(
    intervalMillis = 10000, 
    session = session,
    filePath = 'https://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime=1900-01-01%2000%3A00%3A00&minmagnitude=7&orderby=time',
    readFunc = read_csv)


  output$mydata <- renderDataTable({
    if (input$options == "All") {
      df <- df()
      countrySplit <- strsplit(df$place, ",")
      country <- c()
      for (i in 1:length(countrySplit)) {
        country[i] <- countrySplit[[i]][2] 
      }
      df <- cbind(df, country)
      dta <- df %>% group_by(country) %>% count() %>% na.omit() %>% arrange(desc(n))
      colnames(dta) <- c("Country/State", "# of Earthquakes")
      return(dta)
    }
    
    if (input$options == "Specific"){
      df <- df()
      countrySplit <- strsplit(df$place, ",")
      country <- c()
      for (i in 1:length(countrySplit)) {
        country[i] <- countrySplit[[i]][2] 
      }
      df <- cbind(df, country)
      dta <- df %>% filter(country == req(input$specific))
      dta <- dta %>% select(country, mag, time) %>% na.omit()
      colnames(dta) <- c("Country/State", "Magnitude", "Time")
      return(dta)
    }
    
    if (input$options == "Date"){
      df <- df()
      countrySplit <- strsplit(df$place, ",")
      country <- c()
      for (i in 1:length(countrySplit)) {
        country[i] <- countrySplit[[i]][2] 
      }
      df <- cbind(df, country)
      dta <- df %>% filter(month(as.Date(time)) == req(input$month)) %>% 
        filter(day(as.Date(time)) == input$day)
      dta <- dta %>% select(country, mag, time) %>% na.omit()
      colnames(dta) <- c("Country/State", "Magnitude", "Time")
      return(dta)
    }
   
  
  }, options = list(pageLength = 6))

  observeEvent(input$options, {
    if (input$options == "Specific") {
      df <- df()
      countrySplit <- strsplit(df$place, ",")
      country <- c()
      for (i in 1:length(countrySplit)) {
        country[i] <- countrySplit[[i]][2] 
      }
      df <- cbind(df, country)
      
      distinct_choices <- sort(unique(df$country)) %>% na.omit()
      updateSelectInput(session, "specific", choices = distinct_choices)
    }
    
  })
  
  observeEvent(input$countriesTS, {
    if (input$countriesTS == "") {
      df <- df()
      countrySplit <- strsplit(df$place, ",")
      country <- c()
      for (i in 1:length(countrySplit)) {
        country[i] <- countrySplit[[i]][2] 
      }
      df <- cbind(df, country)
      
      distinct_choices <- sort(unique(df$country)) %>% na.omit()
      updateSelectInput(session, "countriesTS", choices = distinct_choices)
    }
    
  })
  
  
  output$myplot <- renderPlot({
    
    earthquakes <- df()
    
    world <- map_data('world')
    
    
    if (input$options == "All") {
      allQuakes <- ggplot() + geom_map(data = world, map = world, aes(x = long, y=lat, group=group, map_id=region), 
                                       fill="white", colour="#7f7f7f", size=0.5) + 
        theme_minimal() + 
        geom_point(data = earthquakes, aes(x=longitude, y = latitude, color = mag)) +
        scale_colour_gradient(low = "darkgreen", high = "red") 
      return(allQuakes)
      
    }
    
    if (input$options == "Specific"){
      df <- df()
      countrySplit <- strsplit(df$place, ",")
      country <- c()
      for (i in 1:length(countrySplit)) {
        country[i] <- countrySplit[[i]][2] 
      }
      df <- cbind(df, country)
      
      eq.filtered <- df %>% filter(country == req(input$specific))
      
      p <- ggplot() + geom_map(data = world, map = world, aes(x = long, y=lat, group=group, map_id=region), 
                               fill="white", colour="#7f7f7f", size=0.5) + 
        theme_minimal() + 
        geom_point(data = eq.filtered, aes(x=longitude, y = latitude, color = mag), size = 3) + 
        scale_size(guide = 'none') +
        scale_colour_gradient(low = "darkgreen", high = "magenta") 
      return(p)
      
    }
    
    if (input$options == "Date") {
  
      dateQuakes <- earthquakes %>% filter(month(as.Date(time)) == input$month) %>% 
        filter(day(as.Date(time)) == input$day)
      
      QuakesByDate <- ggplot() + geom_map(data = world, map = world, aes(x = long, y=lat, group=group, map_id=region), 
                                          fill="white", colour="#7f7f7f", size=0.5) + 
        theme_minimal() +
        geom_point(data = dateQuakes, aes(x=longitude, y = latitude, color = mag, size = mag)) + 
        scale_size(guide = 'none') +
        scale_colour_gradient(low = "darkgreen", high = "magenta") 
      return(QuakesByDate)
    }
    
  })
  
  observeEvent(input$countriesTS,{
    updateSliderInput(session, "span", min = 0.5, max =1.8, value = 0.1)  
  })
  
  output$myTimeSeries <- renderPlotly({
    df <- df()
    countrySplit <- strsplit(df$place, ",")
    country <- c()
    for (i in 1:length(countrySplit)) {
      country[i] <- countrySplit[[i]][2] 
    }
    df <- cbind(df, country)
    
    TSEarthquakes <- df %>% select(time, country, mag) %>% filter(country == input$countriesTS) 
    
    
    #%>% filter(country == input$countriesTS) %>% 
     #               group_by(year(as.Date(time))) %>% count() %>% ungroup() %>% mutate(new = cumsum(n))
    
    colnames(TSEarthquakes) <- c("Year", "Quakes in year", "Magnitude")
    
    
    TSeries <- ggplot(TSEarthquakes, aes(x=Year, y=Magnitude)) + geom_point()   #+geom_line()
    
    if (input$linfit) TSeries <- TSeries + geom_smooth(span = input$span)
    
    return(ggplotly(TSeries))
    
    
  })
  
})
