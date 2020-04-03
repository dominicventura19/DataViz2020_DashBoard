library(shiny)
library(shinydashboard)
library(ggplot2)
library(readr)
library(evaluate)
library(maps)
library(plotly)
library(DT)
library(tidyverse)



shinyServer(function(input, output, session) {
    
    df <- reactiveFileReader(
        intervalMillis = 10000, 
        session = session,
        filePath = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv',
        readFunc = read_csv)
    
    output$mydata <- renderDT({
        df <- df()
        corona <- df %>% filter(county != "Unknown")
        corona <- df %>% filter(state == "Florida") %>% select(county, cases)
        count <- aggregate(corona$cases, by=list(Category=corona$county), FUN=sum)
        colnames(count) <- c("County", "Count")
        count
    })
    
    output$myplot <- renderPlot({
        df <- df()
        corona <- df %>% filter(county != "Unknown")
        corona <- df %>% filter(state == "Florida") %>% select(county,cases)
        corona <- aggregate(corona$cases, by=list(Category=corona$county), FUN=sum)
        colnames(corona) <- c("County", "Count")
        
        county_data <- map_data("county") %>% filter(region == "florida") 
        corona$county <- tolower(corona$county)

        county_data1 <- county_data %>% mutate(subregion = fct_recode(subregion, `st. johns` = "st johns", 
                                                                      `st. lucie` = "st lucie", `desoto` = "de soto"))
       
        coronaMap <- left_join(county_data1, corona, by = c(subregion = "county"))
        
        p <- ggplot(coronaMap, aes(x = long, y = lat, group = group, fill = Count)) + 
            geom_polygon(color = "black", size = 0.1) + theme_minimal() +
            labs(x = "Longitude", y = "Latitude", fill = "Count")
        return(p)
    })
    
    output$nrows <- renderValueBox({
        nr <- nrow(df())
        valueBox(
            value = nr,
            subtitle = "Number of Rows",
            icon = icon("table"),
            color = if (nr <=6) "yellow" else "aqua"
        )
    })
})
