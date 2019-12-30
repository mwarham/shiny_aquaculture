### ----------
### Section 1: Initialize app
### ----------
### Load packages -----

library(shiny)
library(shinyjs)
library(shinydashboard)
library(leaflet)
library(shinyBS)
library(hrbrthemes)
library(tidyverse)
library(sf)
library(png)

farm_data <- read_csv("./pre-set_scenarios_LCI.csv")


farm_choices <- unique(farm_data$farm_name)


function(input,output){
  
  
  #header bar
  header <- dashboardHeader(title = "Shiny Aquaculture")
  
  sidebar <- dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Description", tabName = "description", icon = icon("book-reader")),
      menuItem("Inputs",tabName = "inputs", icon = icon("dashboard")),
      menuItem("Results",tabName = "results", icon = icon("chart-line"))
      
      
    )) # close dashboardSidebar
  
  body <- dashboardBody(
    # useShinyalert(),
    
    tabItems(
      # input tab
      tabItem(tabName = "description",
              h1("Shiny Aquaculture"),
              "simMPA is a web application for simulating the effects of Marine Protected Areas.",
              h2("sea weed is cool")),
      
      
      
      tabItem(tabName = "inputs",
              actionButton("go","Run Simulations"),
              br(),
              br(),
              selectizeInput("FarmName",label = 'Farm Name', choices = farm_choices, selected = "Farm 1"),
              box(title = "Farm Outputs",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  status = "primary"),
              box(title = "Propagule Production",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  status = "primary",
                  br(),
                  box(title = "Vegetative Cutting",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Building Infrastructure", label = "Building Infrastructure",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Electricity for lamps", label = "Electricity for lamps",
                              0.6,0.99,.8,step = 0.01)),
                  box(title = "Harvesting",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Building Infrastructure", label = "Building Infrastructure",
                                  0.6,0.99,.8,step = 0.01)),
                  box(title = "Nursery",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Building Infrastructure", label = "Building Infrastructure",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Lab Consumables", label = "Lab Consumables",
                                  0.6,0.99,.8,step = 0.01)),
              
                      box(title = "Electricty",
                          solidHeader = TRUE,
                          collapsible = TRUE,
                          status = "primary",
                          br(),
                          sliderInput("Electricity for Lamps", label = "Lamps",
                                  0.6,0.99,.8,step = 0.01),
                          sliderInput("Electricity for Pumping", label = "Pumping",
                                      0.6,0.99,.8,step = 0.01),
                          sliderInput("Electricity for Aeration", label = "Aeration",
                                      0.6,0.99,.8,step = 0.01),
                          sliderInput("Electricity for Water Treatment", label = "Water Treatment",
                                      0.6,0.99,.8,step = 0.01)),
                      box(title = "Nutrient Medium",
                          solidHeader = TRUE,
                          collapsible = TRUE,
                          status = "primary",
                          br(),
                          sliderInput("Ammonium Nitrate", label = "Ammonium Nitrate",
                                  0.6,0.99,.8,step = 0.01),
                          sliderInput("Sodium Phosphate", label = "Ammonium Nitrate",
                                      0.6,0.99,.8,step = 0.01)),
                  box(title = "Monitoring",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Monitoring", label = "Monitoring",
                                  0.6,0.99,.8,step = 0.01)),
                  box(title = "Ocean Deployment",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Ocean Deployment", label = "Ocean Deployment",
                                  0.6,0.99,.8,step = 0.01))),
              box(title = "Ocean Cultivation and Harvest",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  status = "primary",
                  br(),
                  box(title = "Seeding",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Long-line", label = "Long-line",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Kuralon net", label = "Kuralon net",
                                  0.6,0.99,.8,step = 0.01)),
                  box(title = "Ocean Deployment",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Anchor", label = "Anchor",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Chains", label = "Chains",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Buoys", label = "Buoys",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Fuel", label = "Fuel",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Support lines", label = "Support lines",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Strip rods", label = "strip rods",
                                  0.6,0.99,.8,step = 0.01)),
                  box(title = "Monitoring",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Fuel", label = "Fuel",
                                  0.6,0.99,.8,step = 0.01),
                      sliderInput("Monitoring Vessel", label = "Monitoring Vessel",
                                  0.6,0.99,.8,step = 0.01)),
                  box(title = "Harvest",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      status = "primary",
                      br(),
                      sliderInput("Fuel", label = "Fuel",
                                  0.6,0.99,.8,step = 0.01)))
              
                  # sliderInput("min_size","MPA Patchiness",0,1,.1, value = 0),
                  # sliderInput("mpa_habfactor","MPA habitat multiplier",1,4,.1, value = 1),
                  # checkboxInput("random_mpas", "Randomly Place MPAs?"),
                  # checkboxInput("sprinkler", "Place MPA in larval source?")
                  
              
      ),# close tab item inputs
      
      
      tabItem(
        tabName = "results",
        fluidRow(
          box(title = "Farm Outputs",
              solidHeader = TRUE,
              collapsible = TRUE,
              status = "primary",
              tableOutput("FarmSummary"))
              
              
          #box(withSpinner(plotOutput("summary_plot")), title = "Percent change in metrics relative to values just before the MPA"),
          #box(withSpinner(plotOutput("static_doughnut")), title = "Spatial distribution of biomass and effort at equilibrium"),
          #box(withSpinner(plotOutput("raw_summary_plot")), title = "Absolute values of metrics over time")
        ) # close mainPanel
      ) # close plot tab
    ) # close tabItems
  ) # close dashboardBody
  
  dashboardPage(
    header,
    sidebar,
    body
  ) # close dashboard Padte  
  
   #close tab items
  #)#close dashboardBody
  #close fluidPage
} #Close shinyUI

####-----
### Server
####------

server <- function(input,output, session) {
  #browser()
  plot_theme <- hrbrthemes::theme_ipsum(base_size = 14,
                                        axis_title_size = 16,
                                        base_family = "Fira Sans")
  
  
  theme_set(plot_theme)
  
  datasetInput <- eventReactive(input$go, {
    switch(input$FarmName,
           "Farm 1" = "Farm 1",
           "Farm 2" = "Farm 2",
           "Farm 3" = "Farm 3",
           "Farm 4" = "Farm 4",
           "Farm 5" = "Farm 5",
    )}, ignoreNULL = FALSE)
  
  
  output$FarmSummary <- renderPrint(
    selected_farm_data <- farm_data %>% 
      filter(farm_name == input$go) %>% 
      summarize(total_GWP = sum(gwp_hectarefarm))
    
    
    
  ) #close render print
  
  
  
}



### ----------
### Section 4: Run application
### ----------
shinyApp(ui = ui, server = server)




