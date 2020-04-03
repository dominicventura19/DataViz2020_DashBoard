library(shiny)
library(shinydashboard)
library(ggplot2)
library(readr)
library(maps)
library(mapproj)
library(DT)
library(tidyverse)



shinyServer(function(input, output, session) {
    
    df <- reactiveFileReader(
        intervalMillis = 10000, 
        session = session,
        filePath = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv',
        readFunc = read_csv)
    
    output$mydata <- renderDataTable({
        df <- df()
        dta <- df %>% filter(state == "Florida")
        corona <- dta %>% select(c(county, cases))
        
        count <- aggregate(corona$cases, by=list(Category=corona$county), FUN=sum)
        colnames(count) <- c("County", "Count")
        count
    })
    
    output$myplot <- renderPlot({
        df <- df()
        dta <- df
        corona <- dta %>% filter(state == "Florida")
        
        corona <- aggregate(corona$cases, by=list(Category=corona$county), FUN=sum)
        colnames(corona) <- c("County", "Count")
        
        
        countydata <- map_data("county")
        countydata1 <- countydata %>% filter(region == "florida")
        countydata1$subregion <- tolower(countydata1$subregion)
        corona$County <- tolower(corona$County)

        countydata <- countydata %>% mutate(subregion = fct_recode(subregion, `st. johns` = "st johns", 
                                                                      `st. lucie` = "st lucie", `desoto` = "de soto"))
       
        coronaMap <- left_join(countydata1, corona, by = c(subregion = "County"))
        
        p <- ggplot(coronaMap, aes(x = long, y = lat, group = group, fill = Count)) + 
            geom_polygon(color = "black", size = 0.1) + theme_minimal() +
            labs(x = "Longitude", y = "Latitude", fill = "Count") + 
            coord_map(projection = "albers", lat0 = 25, lat1 = 31)
        return(p)
    })
    
})
