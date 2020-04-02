library(shiny)
library(shinydashboard)
library(ggplot2)
library(readr)

shinyServer(function(input, output, session) {
    
    df <- reactiveFileReader(
        intervalMillis = 10000, 
        session = session,
        filePath = 'covid.csv',
        readFunc = read_csv)
    
    output$mydata <-renderTable({df()})
    
    output$myplot <- renderPlot({
        df <- df()
        p <- ggplot(coronaMap, aes(x = long, y = lat, group = group)) + 
            geom_polygon(aes(fill = count)) + theme_minimal() + labs(x = "Longitude", y = "Latitude", fill = "Count")
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
