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
          title="Earthquakes of 7+ Magnitude",
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
  )
)