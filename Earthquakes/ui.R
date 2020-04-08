library(shiny)

library(shiny)
library(shinydashboard)
library(DT)

dashboardPage(
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(disable = T),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      box(width=6, 
          status="info", 
          title="Corona Cases by County",
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
      valueBoxOutput(width=4, "nrows"),
      infoBoxOutput(width=4, "ncol")
    )
  )
)