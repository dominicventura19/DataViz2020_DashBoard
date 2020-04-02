library(shiny)
library(shinydashboard)
library(ggplot2)
library(readr)
library(tidyverse)
library(maps)



shinyServer(function(input, output, session) {
    
    df <- reactiveFileReader(
        intervalMillis = 10000, 
        session = session,
        filePath = 'covid.csv',
        readFunc = read_csv)
    
    output$mydata <- renderTable({df()})
    
    output$myplot <- renderPlot({
        df <- df()
        gitpath <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"
        corona <- read_csv(gitpath)
        corona <- corona %>% filter(county != "Unknown")
        corona <- corona %>% filter(state == "Florida")
        #write.csv(corona, file = "covid.csv")
        county_data <- map_data("county") %>% filter(region =="florida") 
        corona$county <- tolower(corona$county)
       # setdiff(corona$county, unique(county_data$subregion))
        #unique(corona$county)
        county_data1 <- county_data %>% mutate(subregion = fct_recode(subregion, `st. johns` = "st johns", `st. lucie` = "st lucie", `desoto` = "de soto"))
        #setdiff(corona$county, unique(county_data1$subregion))
        corona <- corona %>% group_by(county) %>% mutate(count = n())
        coronaMap <- left_join(county_data1, corona, by = c("subregion" = "county"))
        p <- ggplot(coronaMap, aes(x = long, y = lat, group = group)) + 
            geom_polygon(aes(fill = count)) + theme_minimal() +
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
    
    output$ncol <- renderInfoBox({
        nc <- ncol(df())
        infoBox(
            value = nc,
            title = "Columns",
            icon = icon("list"),
            color = "purple",
            fill=TRUE)
    })
    
})
