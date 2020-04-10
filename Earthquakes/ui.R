library(shiny)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)

dashboardPage(
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Map and Table", tabName = "MnT", icon = icon("globe-americas")),
      menuItem("Time Series", tabName = "series", icon = icon("clock"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "MnT",
              fluidRow(
                box(
                  selectInput("options", "Plot every earthquake, ones from specific countries/states, or by date?", 
                              choices = list(All = "All", Specific = "Specific", Date = "Date")),
                  conditionalPanel(
                    condition = "input.options == 'Specific' ",
                    selectInput("specific", label = "Countries", choices = sort(c), multiple = T, selected = "")
                  ),
                  conditionalPanel(
                    condition = "input.options == 'Date' ",
                    selectInput("month", label = "Enter a month and day", choices = list(January = 1, February = 2, March = 3,
                                                                                        April = 4, May = 5, June = 6, July = 7,
                                                                                        August = 8, Sepetember = 9, October = 10,
                                                                                        November = 11, December = 12)),
                    #sliderInput("year", label = "Choose a year", min = 1900, max = 2020)
                    sliderInput("day", label = "Choose a day", min = 1, max = 31, value = 1)
                  )
                  
                ),
                  
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
               
                box(width=6, 
                    status="info", 
                    title="Earthquakes of 7+ Magnitude from 1900 to 2020",
                    solidHeader = TRUE,
                    plotOutput("myplot")
                ),
                box(width=6, 
                    status="warning", 
                    title = "Data Frame",
                    solidHeader = TRUE, 
                    collapsible = TRUE, 
                    footer="Read Remotely from File",
                    dataTableOutput("mydata")
                )
              ),
              ## Add some more info boxes
              fluidRow(
                valueBoxOutput(width=6, "nrows"),
                infoBoxOutput(width=6, "ncol")
              )
      ),
      
      tabItem(tabName = "series",
              fluidRow(
                box(
                  selectInput("countriesTS", label = "Choose a country/state", choices = sort(c))
                ),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                br(),
                
                box(
                  width=6,
                  status="warning",
                  title = "Earthquakes of 7+ Magnitude from 1900 to 2020",
                  solidHeader = T,
                  plotlyOutput("myTimeSeries")
                )
              )
              
      )
    )
  )
)