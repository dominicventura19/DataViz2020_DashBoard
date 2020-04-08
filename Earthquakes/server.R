library(shiny)
library(shinydashboard)
library(ggplot2)
library(readr)
library(maps)
library(mapproj)
library(DT)
library(tidyverse)

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
    colnames(dta) <- c("Country", "# of Earthquakes")
    dta
  
  })
  
  output$myplot <- renderPlot({
    world <- map_data('world')
    
    p <- ggplot() + geom_map(data = world, map = world, aes(x = long, y=lat, group=group, map_id=region), fill="white", colour="#7f7f7f", size=0.5) + 
      geom_point(data = earthquakes, aes(x=longitude, y = latitude, colour = mag)) + 
      scale_colour_gradient(low = "green",high = "magenta") 
    return(p)
  })
  
})
