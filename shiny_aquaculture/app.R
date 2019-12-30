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
library(reactable)
library(Hmisc)
library(shinyalert)
library(ggplot2)
library(plotly)
library(shinycssloaders)

# plot_theme <- hrbrthemes::theme_ipsum(base_size = 14,
#                                       axis_title_size = 16,
#                                       base_family = "Fira Sans")




#theme_set(plot_theme)

farm_data <- read_csv("./pre-set_scenarios_LCI_matt.csv")

emissions_values <- read_csv("./Emission-Factors_lifetime.csv")


farm_choices <- unique(farm_data$farm_name)


ui <- function(input,output){
  
  
  #header bar
  header <- dashboardHeader(title = "Seaweed Aquaculture Life Cycle Assessment Tool",
                            # SFG logo
                            tags$li(class = "dropdown",
                                    a(href = 'http://sfg.msi.ucsb.edu/',
                                      img(
                                        src = 'sfg-logo-white.png',
                                        title = "The Sustainable Fisheries Group",
                                        height = "40px"
                                      ), style = "padding-top:10px; padding-bottom:10px;"
                                    )
                            ),
                            # emLab logo
                            tags$li(class = "dropdown",
                                    a(href = 'http://emlab.msi.ucsb.edu/',
                                      img(
                                        src = 'emLab-logo-white.png',
                                        title = "The Environmental Market Solutions Lab",
                                        height = "40px"
                                      ), style = "padding-top:10px; padding-bottom:10px;"
                                    )
                            ))
  
  sidebar <- dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Description", tabName = "description", icon = icon("book-reader")),
      menuItem("Inputs",tabName = "inputs", icon = icon("dashboard")),
      menuItem("Results",tabName = "results", icon = icon("chart-line"))
      
      
    )) # close dashboardSidebar
  
  body <- dashboardBody(
    
    shinyjs::useShinyjs(),
    id = "body",
    
    tabItems(
      # input tab
      tabItem(tabName = "description",
              h1("Seaweed Aquaculture Life Cycle Assessment Tool"),
              br(),
              h4("This tool is designed to help a user determine the amount of greenhouse gases emitted from seaweed aquaculture production. Specifically, a user can input materials and quantities used for the production of propagules, aka seed, and the construction, deployment, and operation of a long-line seaweed farm. A collection of input values is then used to populate a life cycle contribution model (Fig. 1) to determine the total equivalent amount of kilograms of carbon dioxide (CO2-eq) emitted per hectare of farm per year, otherwise known as the annual global warming potential (GWP). "),
              br(),
              h3("How to use the app:"),
              h4("Use the “Input” tab to populate the model with your data. All inputs should be recorded per hectare of farm per year. Inputs are reported in two stages: “Propagule Production” (on the left) and “Ocean Cultivation and Harvesting” (on the right). Inputs are selected from drop down menus, and quantities are specified using a slider bar (constrained by published values, and set to the average reported value for a given category) or manually. Note that some materials are assumed to last longer than one year. The GWP from producing these materials is then divided by the total life-time to estimate the annual GWP of each material, for example:", strong("10 kg CO2/kg steel/20yr life time = 0.5 kg CO2/kg steel/yr")),
              br(),
              h4("Examples of material life-times are as follows: culture string = 1yr; long-lines = 5yrs; anchor = 20yrs; chains = 20yrs; support-line = 5yrs; buoys = 10yrs; buoy weights = 20yrs; buoy rope = 5yrs."),
              br(),
              h4("After inputting all data, click the “Run Simulation” button at the top of the “Input” tab and go to the “Results” tab. Here, you will see the GWP (kg CO2-eq/ha/yr) for each input organized by stage, the percent contribution of each input’s GWP to the total GWP (propagule production + ocean cultivation and harvesting), and the total annual GWP. At the bottom of this page are two interactive figures to visually display results."),
              br(),
              h4("At any point a user can return to the “Input” tab and either manually change input values or click the “Reset Input” button at the top of the “Input” page to reset all of the input values to 0."),
              br(),
              h4("Please contact", a(href="mailto:ilan_macadamsomer@ucsb.edu?subject=ShinyAquaculture", "Ilan Macadam-Somer") , "with questions, comments, or suggestions for improvements."),
              br(),
              br(),
              
             
              
              # Conceptual Model
              
              HTML('<center><img src="conceptual_model.png" width="650"></center>')

      ),
      
      tabItem(tabName = "inputs",
              #id = "inputs",
              fluidPage(
              actionButton("go","Run Model"),
              actionButton("reset_inputs", "Reset inputs"),
              br(),
              # br(),
              # box(title = "Farm Outputs",
              #     solidHeader = TRUE,
              #     collapsible = TRUE,
              #     status = "primary",
              #     #selectInput(inputId = "farm_select",label = 'Farm Name', choices = farm_data$farm_name, selected = "Farm 1"),
              #     #actionButton("update", "Change"),
              #     reactableOutput("FarmSummary")),
              # h4("*Please select an option from the dropdown menu and then use the slider bar OR enter a numerical value below for each input"),
              br(),
              box(title = "Propagule Production",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  #color = "olive",
                  status = "primary",
  
                  h3("Vegetative Cutting"),
                  h4("Infrastructure and Equipment Electricity"),
                      
                      selectInput(inputId = "veg_grid_type",label = 'Grid Mix Type',
                                     c("none",
                                       "US Grid Mix",
                                       "EU-28 Grid Mix",
                                       "UK Grid Mix",
                                       "Japan Grid Mix",
                                       "China Grid Mix"),

                                     ),
                      # numericInput(inputId = "veg_grid_manual", label = "Grid Mix Manual Input",
                      #             value = 0),
                      
                      uiOutput("veg_grid_slide"),
                  uiOutput("veg_grid_num"),
                  #uiOutput("veg_grid_final"),
                  h4("Fuel to Harvest Fertile Material"),
                      selectInput(inputId = "veg_fuel_type",label = 'Fuel Type', 
                                      c("none",
                                        "US Diesel",
                                        "US Gasoline"),
                              
                                    ),
                      uiOutput("veg_fuel_slide"),
                  uiOutput("veg_fuel_num"),
                  h3("Nursery"),
                  h4("Fuel to Harvest Fertile Material"),
                      selectInput(inputId = "nursery_fuel_type",label = 'Fuel Type', 
                                  c("none",
                                    "US Diesel",
                                    "US Gasoline"),
                                  
                                    ),
                      uiOutput("nursery_fuel_slide"),
                  uiOutput("nursery_fuel_num"),
                  h4("Nursery and Equipment Electricity Use"),
                      selectInput(inputId = "nursery_grid_type",label = 'Grid Mix', 
                                  c("none",
                                    "US Grid Mix",
                                    "EU-28 Grid Mix",
                                    "UK Grid Mix",
                                    "Japan Grid Mix",
                                    "China Grid Mix"),
                                  
                      ),
                      uiOutput("nursery_grid_slide"),
                  uiOutput("nursery_grid_num"),
                  h4("Nutrient Medium"),
                      selectInput(inputId = "nursery_nutrient_type",label = 'Nutrient Medium', 
                                  c("none",
                                    "Ammonium Nitrate",
                                    "Sodium Phosphate"),
                                  
                      ),
                      uiOutput("nursery_nutrient_slide"),
                  uiOutput("nursery_nutrient_num"),
                  h4("Culture String"),
                      selectInput(inputId = "culture_string",label = 'Culture String', 
                                  c("none",
                                    "Polyamide Fibers",
                                    "PP Fibers",
                                    "PET Fibers",
                                    "RPET Fibers",
                                    "Nylon 66"),
                                  
                      ),
                      uiOutput("culture_string_slide"),
                  uiOutput("culture_string_num"),
                      
                  
                 
                  ), # close propagule box,
              box(title = "Ocean Cultivation and Harvest",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  #color = "light-blue",
                  status = "success",
                  
                  h3("Seeding"),
                  h4("Long Line"),
                      selectInput(inputId = "long_line",label = 'Long Line', 
                                  c("none",
                                    "Polyamide Fibers",
                                    "PP Fibers",
                                    "PET Fibers",
                                    "RPET Fibers",
                                    "Nylon 66"),
                                  
                      ),
                      uiOutput("long_line_slide"),
                  uiOutput("long_line_num"),
                  h4("Electricity for Equipment"),
                      selectInput(inputId = "seeding_grid_type",label = 'Grid Mix', 
                                  c("none",
                                    "US Grid Mix",
                                    "EU-28 Grid Mix",
                                    "UK Grid Mix",
                                    "Japan Grid Mix",
                                    "China Grid Mix"),
                                  
                      ),
                      uiOutput("seeding_grid_slide"),
                  uiOutput("seeding_grid_num"),
                  h4("Fuel for Equipment"),
                      selectInput(inputId = "seeding_fuel_type",label = 'Fuel Type', 
                                  c("none",
                                    "US Diesel",
                                    "US Gasoline",
                                    "US Natural Gas Mix",
                                    "EU-28 Natural Gas Mix",
                                    "US Propane",
                                    "EU-28 Propane"),
                                  
                      ),
                      uiOutput("seeding_fuel_slide"),
                  uiOutput("seeding_fuel_num"),
                  h3("Ocean Deployment"),
                  h4("Fuel for Transport"),
                      selectInput(inputId = "deployment_fuel_type",label = 'Fuel Type', 
                                  c("none",
                                    "US Diesel",
                                    "US Gasoline"),
                                  
                      ),
                      uiOutput("deployment_fuel_slide"),
                  uiOutput("deployment_fuel_num"),
                  h4("Support Lines"),
                      selectInput(inputId = "support_line",label = 'Support Line', 
                                  c("none",
                                    "Polyamide Fibers",
                                    "PP Fibers",
                                    "PET Fibers",
                                    "RPET Fibers",
                                    "Nylon 66"),
                                  
                      ),
                      uiOutput("support_line_slide"),
                  uiOutput("support_line_num"),
                  h4("Anchors"),
                      selectInput(inputId = "anchor",label = 'Anchors', 
                                  c("none",
                                    "Concrete",
                                    "Steel",
                                    "Chromium Steel"),
                                  
                      ),
                      uiOutput("anchor_slide"),
                  uiOutput("anchor_num"),
                  h4("Buoys"),
                      selectInput(inputId = "buoy",label = 'Buoys', 
                                  c("none",
                                    "Polyamide Fibers",
                                    "PP Fibers",
                                    "PET Fibers",
                                    "RPET Fibers",
                                    "PVC"),
                                  
                      ),
                      uiOutput("buoy_slide"),
                  uiOutput("buoy_num"),
                  h4("Chains"),
                      selectInput(inputId = "chain",label = 'Chains', 
                                  c("none",
                                    "Steel",
                                    "Chromium Steel"),
                                  
                      ),
                      uiOutput("chain_slide"),
                  uiOutput("chain_num"),
                  h4("Buoy Ropes"),
                      selectInput(inputId = "buoy_rope",label = 'Buoy Ropes', 
                                  c("none",
                                    "Polyamide Fibers",
                                    "PP Fibers",
                                    "PET Fibers",
                                    "RPET Fibers",
                                    "Nylon 66"),
                                  
                      ),
                      uiOutput("buoy_rope_slide"),
                  uiOutput("buoy_rope_num"),
                  h4("Buoy Weights"),
                  selectInput(inputId = "buoy_weight",label = 'Buoy Weights', 
                              c("none",
                                "Steel",
                                "Chromium Steel"),
                              
                  ),
                  uiOutput("buoy_weight_slide"),
                  uiOutput("buoy_weight_num"),
                  h3("Monitoring"),
                  h4("Fuel for Monitoring"),
                      selectInput(inputId = "monitoring_fuel_type",label = 'Fuel Type', 
                                  c("none",
                                    "US Diesel",
                                    "US Gasoline"),
                                  
                      ),
                      uiOutput("monitoring_fuel_slide"),
                  uiOutput("monitoring_fuel_num"),
                  h3("Harvest"),
                  h4("Fuel for Harvest Vessel"),
                      selectInput(inputId = "harvest_vessel_fuel_type",label = 'Fuel Type', 
                                  c("none",
                                    "US Diesel",
                                    "US Gasoline"),
                                  
                      ),
                      uiOutput("harvest_vessel_fuel_slide"),
                  uiOutput("harvest_vessel_fuel_num"),
                  h4("Fuel for Harvest Equipment"),
                      selectInput(inputId = "harvest_equip_fuel_type",label = 'Fuel Type', 
                                  c("none",
                                    "US Diesel",
                                    "US Gasoline"),
                                  
                      ),
                      uiOutput("harvest_equip_fuel_slide"),
                  uiOutput("harvest_equip_fuel_num")
                  
    
                  
                  
                  )#close ocean cultivation box)

              
              ) # Close fluid page   
              
      ),# close tab item inputs
      
      
      tabItem(
        tabName = "results",
        fluidRow(
          box(title = "Total Farm GWP",
              solidHeader = TRUE,
              collapsible = FALSE,
              #color = "light-blue",
              status = "danger",
              align = "center",
              withSpinner(uiOutput("farm_total")))),
              #column(4, align = "center", renderText(gwp_total)))),
        fluidRow(
          box(title = "Input Contributions Chart",
              solidHeader = TRUE,
              collapsible = TRUE,
              #color = "light-blue",
              status = "primary",
            withSpinner(reactableOutput("values")), width = 12)),
        fluidRow(
          box(title = "GWP of Proposed Farm by Input",
              solidHeader = TRUE,
              collapsible = TRUE,
              #color = "light-blue",
              status = "success",
            withSpinner(plotlyOutput("donut")), width = 12)) #,
        # fluidRow(
        #   box(title = "Sunburst Chart",
        #       solidHeader = TRUE,
        #       collapsible = TRUE,
        #       #color = "light-blue",
        #       status = "warning",
        #     withSpinner(plotOutput("propeller")), width = 12))
        )
        
          
        # tableOutput("values"),
        # uiOutput("focal"),
        # plotOutput("pie")
        # br(),
        # fluidRow(
        #   plotOutput("pie"), title = "Pie Chart")
          
          
          
         # close mainPanel
       ) # close tab items
    
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
  
  
  
  #shiny_aquaculture_text <- includeHTML("./text/shiny_aquaculture_description.html")
  
  ###Render UI###
  
  output$veg_grid_slide <- renderUI({
    
    #if(input$veg_grid_type)
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    # https://stackoverflow.com/questions/47822736/in-sync-sliderinput-and-textinput
      #https://mastering-shiny.org/action-dynamic.html
      
      if(is.null(input$veg_grid_type))
        return()
    
   switch(input$veg_grid_type, 
           "none" = NULL,
           "US Grid Mix" = sliderInput("veg_us_grid", label = NULL,
                                       0,960,0,step = 1),
           #"US Grid Mix Numeric" = numericInput("veg_us_grid_man", label = NULL, value = 0),
                            #numericInput("us_grid_manual", label = NULL, value = 0)),
           "EU-28 Grid Mix" = sliderInput("veg_eu_grid", label = NULL,
                                          0,960,0,step = 1),
           "UK Grid Mix" = sliderInput("veg_uk_grid", label = NULL,
                                          0,960,0,step = 1),
           "Japan Grid Mix" = sliderInput("veg_japan_grid", label = NULL,
                                          0,960,0,step = 1),
           "China Grid Mix" = sliderInput("veg_china_grid", label = NULL,
                                          0,960,0,step = 1)

          
    )#close switch
    
    # switch(input$veg_grid_type, 
    #        "none" = NULL,
    #        "US Grid Mix" = numericInput("veg_us_grid_man", label = NULL, value = 0),
    #        #"US Grid Mix Numeric" = numericInput("veg_us_grid_man", label = NULL, value = 0),
    #        #numericInput("us_grid_manual", label = NULL, value = 0)),
    #        "EU-28 Grid Mix" = numericInput("veg_us_grid_man", label = NULL, value = 0),
    #        "UK Grid Mix" = numericInput("veg_us_grid_man", label = NULL, value = 0),
    #        "Japan Grid Mix" = numericInput("veg_us_grid_man", label = NULL, value = 0),
    #        "China Grid Mix" = numericInput("veg_us_grid_man", label = NULL, value = 0)
    #        
    #        
    #        
    #        
    #        
    # )#close switch
    
  })
  
  output$veg_grid_num <- renderUI({

    if(is.null(input$veg_grid_type))
      return()
    
   switch(input$veg_grid_type, 
           "none" = NULL,
           "US Grid Mix"  = numericInput("veg_us_grid_num", label = NULL, value = 0),
           #"US Grid Mix Numeric" = numericInput("veg_us_grid_man", label = NULL, value = 0),
           #numericInput("us_grid_manual", label = NULL, value = 0)),
           "EU-28 Grid Mix" = numericInput("veg_eu_grid_num", label = NULL, value = 0),
           "UK Grid Mix" = numericInput("veg_uk_grid_num", label = NULL, value = 0),
           "Japan Grid Mix" = numericInput("veg_japan_grid_num", label = NULL, value = 0),
           "China Grid Mix" = numericInput("veg_china_grid_num", label = NULL, value = 0)

    )#close switch
    
   
    
  })
  
  # observeEvent(input$veg_us_grid_man, {
  #   updateSliderInput(session, "veg_us_grid", value = input$veg_eu_grid_man)
  # })
  # observeEvent(input$veg_eu_grid_man, {
  #   updateSliderInput(session, "veg_eu_grid", value = input$veg_eu_grid_man)
  # })
  
  
  
  
  # output$veg_grid_final <- renderUI({
  # 
  #   #veg_grid <- input$veg_grid_slide
  #   #veg_grid_man <- input$veg_grid_num
  # 
  #   if(is.null(input$veg_us_grid_man)){
  # 
  #     return(input$veg_us_grid)}
  # 
  #     # else{
  #     #
  #     #   return(input$veg_us_grid)
  #     # }
  # 
  # 
  # })
  
  
  #as.numeric(input$textValue) != input$sliderValue
  
  output$veg_fuel_slide <- renderUI({
    if(is.null(input$veg_fuel_type))
      return()
    
    ##Depending on input$fuel, we will display a different slider bar
    
    switch(input$veg_fuel_type, 
           "none" = NULL,
           "US Diesel" = sliderInput("veg_us_diesel", "US Diesel (Liter)",
                                       0,10,0,step = 0.1),
           "US Gasoline" = sliderInput("veg_us_gasoline", "US Gasoline (Liter)",
                                          0,10,0,step = 0.1),
           
           # "EU-28 Grid Mix" = 3,
           # "UK Grid Mix" = 4,
           # "Japan Grid Mix" = 5,
           # "China Grid Mix" = 6
           
    )
  })
  
  output$veg_fuel_num <- renderUI({
    
    if(is.null(input$veg_fuel_type))
      return()
    
    switch(input$veg_fuel_type, 
           "none" = NULL,
           "US Diesel"  = numericInput("veg_us_diesel_num", label = NULL, value = 0),
           "US Gasoline" = numericInput("veg_us_gasoline_num", label = NULL, value = 0)
           
           
    )#close switch
    
    
    
  })
  
  output$nursery_fuel_slide <- renderUI({
    if(is.null(input$nursery_fuel_type))
      return()
    
    ##Depending on input$fuel, we will display a different slider bar
    
    switch(input$nursery_fuel_type, 
           "none" = NULL,
           "US Diesel" = sliderInput("nursery_us_diesel", "US Diesel (Liter)",
                                     0,10,0,step = 0.1),
           "US Gasoline" = sliderInput("nursery_us_gasoline", "US Gasoline (Liter)",
                                       0,10,0,step = 0.1),
           
           # "EU-28 Grid Mix" = 3,
           # "UK Grid Mix" = 4,
           # "Japan Grid Mix" = 5,
           # "China Grid Mix" = 6
           
    )
  })
  
  output$nursery_fuel_num <- renderUI({
    
    if(is.null(input$nursery_fuel_type))
      return()
    
    switch(input$nursery_fuel_type, 
           "none" = NULL,
           "US Diesel"  = numericInput("nursery_us_diesel_num", label = NULL, value = 0),
           "US Gasoline" = numericInput("nursery_us_gasoline_num", label = NULL, value = 0)
           
           
    )#close switch
    
    
    
  })
  
  output$nursery_grid_slide <- renderUI({
    if(is.null(input$nursery_grid_type))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$nursery_grid_type, 
           "none" = NULL,
           "US Grid Mix" = sliderInput("nursery_us_grid", "US Grid Mix (kWh)",
                                       0,960,0,step = 1),
           "EU-28 Grid Mix" = sliderInput("nursery_eu_grid", "EU-28 Grid Mix (kWh)",
                                          0,960,0,step = 1),
           "UK Grid Mix" = sliderInput("nursery_uk_grid", "UK Grid Mix (kWh)",
                                       0,960,0,step = 1),
           "Japan Grid Mix" = sliderInput("nursery_japan_grid", "Japan Grid Mix (kWh)",
                                          0,960,0,step = 1),
           "China Grid Mix" = sliderInput("nursery_china_grid", "China Grid Mix (kWh)",
                                          0,960,0,step = 1)
           # "EU-28 Grid Mix" = 3,
           # "UK Grid Mix" = 4,
           # "Japan Grid Mix" = 5,
           # "China Grid Mix" = 6
           
    )
  })
  
  output$nursery_grid_num <- renderUI({
    
    if(is.null(input$nursery_grid_type))
      return()
    
    switch(input$nursery_grid_type, 
           "none" = NULL,
           "US Grid Mix"  = numericInput("nursery_us_grid_num", label = NULL, value = 0),
           "EU-28 Grid Mix" = numericInput("nursery_eu_grid_num", label = NULL, value = 0),
           "UK Grid Mix" = numericInput("nursery_uk_grid_num", label = NULL, value = 0),
           "Japan Grid Mix" = numericInput("nursery_japan_grid_num", label = NULL, value = 0),
           "China Grid Mix" = numericInput("nursery_china_grid_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  output$nursery_nutrient_slide <- renderUI({
    if(is.null(input$nursery_nutrient_type))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$nursery_nutrient_type, 
           "none" = NULL,
           "Ammonium Nitrate" = sliderInput("ammonium_nitrate", "Ammonium Nitrate (kg)",
                                       0,1000,0,step = 1),
           "Sodium Phosphate" = sliderInput("sodium_phosphate", "Sodium Phosphate (kg)",
                                          0,1000,0,step = 1)
           
           
    )
  })
  
  output$nursery_nutrient_num <- renderUI({
    
    if(is.null(input$nursery_nutrient_type))
      return()
    
    switch(input$nursery_nutrient_type, 
           "none" = NULL,
           "Ammonium Nitrate"  = numericInput("ammonium_nitrate_num", label = NULL, value = 0),
           "Sodium Phosphate" = numericInput("sodium_phosphate_num", label = NULL, value = 0),
           
           
    )#close switch
    
    
    
  })
  
  output$culture_string_slide <- renderUI({
    if(is.null(input$culture_string))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$culture_string, 
           "none" = NULL,
           "Polyamide Fibers" = sliderInput("nursery_polyamide_fibers", "Polyamide Fibers (kg)",
                                      0,50,0,step = 1),
           "PP Fibers" = sliderInput("nursery_pp_fibers", "PP Fibers (kg)",
                                     0,50,0,step = 1),
           "PET Fibers" = sliderInput("nursery_pet_fibers", "PET Fibers (kg)",
                                      0,50,0,step = 1),
           "RPET Fibers" = sliderInput("nursery_rpet_fibers", "RPET Fibers (kg)",
                                       0,50,0,step = 1),
           "Nylon 66" = sliderInput("nursery_nylon_66", "Nylon Fibers (kg)",
                                    0,50,0,step = 1)
           
           
    )
  })
  
  output$culture_string_num <- renderUI({
    
    if(is.null(input$culture_string))
      return()
    
    switch(input$culture_string, 
           "none" = NULL,
           "Polyamide Fibers"  = numericInput("nursery_polyamide_fibers_num", label = NULL, value = 0),
           "PP Fibers" = numericInput("nursery_pp_fibers_num", label = NULL, value = 0),
           "PET Fibers" = numericInput("nursery_pet_fibers_num", label = NULL, value = 0),
           "RPET Fibers" = numericInput("nursery_rpet_fibers_num", label = NULL, value = 0),
           "Nylon 66" = numericInput("nursery_nylon_66_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  output$long_line_slide <- renderUI({
    if(is.null(input$long_line))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$long_line, 
           "none" = NULL,
           "Polyamide Fibers" = sliderInput("seeding_polyamide_fibers", "Polyamide Fibers (kg)",
                                            0,720,0,step = 1),
           "PP Fibers" = sliderInput("seeding_pp_fibers", "PP Fibers (kg)",
                                     0,720,0,step = 1),
           "PET Fibers" = sliderInput("seeding_pet_fibers", "PET Fibers (kg)",
                                      0,720,0,step = 1),
           "RPET Fibers" = sliderInput("seeding_rpet_fibers", "RPET Fibers (kg)",
                                       0,720,0,step = 1),
           "Nylon 66" = sliderInput("seeding_nylon_66", "Nylon Fibers (kg)",
                                    0,720,0,step = 1)
           
           
    )
  })
  
  output$long_line_num <- renderUI({
    
    if(is.null(input$long_line))
      return()
    
    switch(input$long_line, 
           "none" = NULL,
           "Polyamide Fibers"  = numericInput("seeding_polyamide_fibers_num", label = NULL, value = 0),
           "PP Fibers" = numericInput("seeding_pp_fibers_num", label = NULL, value = 0),
           "PET Fibers" = numericInput("seeding_pet_fibers_num", label = NULL, value = 0),
           "RPET Fibers" = numericInput("seeding_rpet_fibers_num", label = NULL, value = 0),
           "Nylon 66" = numericInput("seeding_nylon_66_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  
  output$seeding_grid_slide <- renderUI({
    if(is.null(input$seeding_grid_type))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$seeding_grid_type, 
           "none" = NULL,
           "US Grid Mix" = sliderInput("seeding_us_grid", "US Grid Mix (kWh)",
                                       0,960,0,step = 1),
           "EU-28 Grid Mix" = sliderInput("seeding_eu_grid", "EU-28 Grid Mix (kWh)",
                                          0,960,0,step = 1),
           "UK Grid Mix" = sliderInput("seeding_uk_grid", "UK Grid Mix (kWh)",
                                       0,960,0,step = 1),
           "Japan Grid Mix" = sliderInput("seeding_japan_grid", "Japan Grid Mix (kWh)",
                                          0,960,0,step = 1),
           "China Grid Mix" = sliderInput("seeding_china_grid", "China Grid Mix (kWh)",
                                          0,960,0,step = 1)
           # "EU-28 Grid Mix" = 3,
           # "UK Grid Mix" = 4,
           # "Japan Grid Mix" = 5,
           # "China Grid Mix" = 6
           
    )
  })
  
  output$seeding_grid_num <- renderUI({
    
    if(is.null(input$seeding_grid_type))
      return()
    
    switch(input$seeding_grid_type, 
           "none" = NULL,
           "US Grid Mix"  = numericInput("seeding_us_grid_num", label = NULL, value = 0),
           "EU-28 Grid Mix" = numericInput("seeding_eu_grid_num", label = NULL, value = 0),
           "UK Grid Mix" = numericInput("seeding_uk_grid_num", label = NULL, value = 0),
           "Japan Grid Mix" = numericInput("seeding_japan_grid_num", label = NULL, value = 0),
           "China Grid Mix" = numericInput("seeding_china_grid_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  
  output$seeding_fuel_slide <- renderUI({
    if(is.null(input$seeding_fuel_type))
      return()
    
    ##Depending on input$fuel, we will display a different slider bar
    
    switch(input$seeding_fuel_type, 
           "none" = NULL,
           "US Diesel" = sliderInput("seeding_us_diesel", "US Diesel (Liter)",
                                     0,10,0,step = 0.1),
           "US Gasoline" = sliderInput("seeding_us_gasoline", "US Gasoline (Liter)",
                                       0,10,0,step = 0.1),
           "US Natural Gas Mix" = sliderInput("seeding_us_natgas", "US Natural Gas Mix (Liter)",
                                              0,10,0,step = 0.1),
           "EU-28 Natural Gas Mix" = sliderInput("seeding_eu_natgas", "EU-28 Natural Gas Mix (Liter)",
                                                 0,10,0,step = 0.1),
           "US Propane" = sliderInput("seeding_us_propane", "US Propane (Liter)",
                                      0,10,0,step = 0.1),
           "EU-28 Propane" = sliderInput("seeding_eu_propane", "EU-28 Propane (Liter)",
                                         0,10,0,step = 0.1),
           
           # "EU-28 Grid Mix" = 3,
           # "UK Grid Mix" = 4,
           # "Japan Grid Mix" = 5,
           # "China Grid Mix" = 6
           
    )
  })
  
  output$seeding_fuel_num <- renderUI({
    
    if(is.null(input$seeding_fuel_type))
      return()
    
    switch(input$seeding_fuel_type, 
           "none" = NULL,
           "US Diesel"  = numericInput("seeding_us_diesel_num", label = NULL, value = 0),
           "US Gasoline" = numericInput("seeding_us_gasoline_num", label = NULL, value = 0),
           "US Natural Gas Mix" = numericInput("seeding_us_natgas_num", label = NULL, value = 0),
           "EU-28 Natural Gas Mix" = numericInput("seeding_eu_natgas_num", label = NULL, value = 0),
           "US Propane" = numericInput("seeding_us_propane_num", label = NULL, value = 0),
           "EU-28 Propane" = numericInput("seeding_eu_propane_num", label = NULL, value = 0)
    )#close switch
    
    
    
  })
  
  output$deployment_fuel_slide <- renderUI({
    if(is.null(input$deployment_fuel_type))
      return()
    
    ##Depending on input$fuel, we will display a different slider bar
    
    switch(input$deployment_fuel_type, 
           "none" = NULL,
           "US Diesel" = sliderInput("deployment_us_diesel", "US Diesel (Liter)",
                                     0,0.08,0,step = 0.001),
           "US Gasoline" = sliderInput("deployment_us_gasoline", "US Gasoline (Liter)",
                                       0,0.08,0,step = 0.001),
           
           # "EU-28 Grid Mix" = 3,
           # "UK Grid Mix" = 4,
           # "Japan Grid Mix" = 5,
           # "China Grid Mix" = 6
           
    )
  })
  
  output$deployment_fuel_num <- renderUI({
    
    if(is.null(input$deployment_fuel_type))
      return()
    
    switch(input$deployment_fuel_type, 
           "none" = NULL,
           "US Diesel"  = numericInput("nursery_us_diesel_num", label = NULL, value = 0),
           "US Gasoline" = numericInput("nursery_us_gasoline_num", label = NULL, value = 0)
           
           
    )#close switch
    
    
    
  })
  
  
  output$support_line_slide <- renderUI({
    if(is.null(input$support_line))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$support_line, 
           "none" = NULL,
           "Polyamide Fibers" = sliderInput("supportline_polyamide_fibers", "Polyamide Fibers (kg)",
                                            0,50,0,step = 1),
           "PP Fibers" = sliderInput("supportline_pp_fibers", "PP Fibers (kg)",
                                     0,50,0,step = 1),
           "PET Fibers" = sliderInput("supportline_pet_fibers", "PET Fibers (kg)",
                                      0,50,0,step = 1),
           "RPET Fibers" = sliderInput("supportline_rpet_fibers", "RPET Fibers (kg)",
                                       0,50,0,step = 1),
           "Nylon 66" = sliderInput("supportline_nylon_66", "Nylon Fibers (kg)",
                                    0,50,0,step = 1)
           
           
    )
  })
  
  output$support_line_num <- renderUI({
    
    if(is.null(input$support_line))
      return()
    
    switch(input$support_line, 
           "none" = NULL,
           "Polyamide Fibers"  = numericInput("seeding_polyamide_fibers_num", label = NULL, value = 0),
           "PP Fibers" = numericInput("seeding_pp_fibers_num", label = NULL, value = 0),
           "PET Fibers" = numericInput("seeding_pet_fibers_num", label = NULL, value = 0),
           "RPET Fibers" = numericInput("seeding_rpet_fibers_num", label = NULL, value = 0),
           "Nylon 66" = numericInput("seeding_nylon_66_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  
  output$anchor_slide <- renderUI({
    if(is.null(input$anchor))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$anchor, 
           "none" = NULL,
           "Concrete" = sliderInput("anchor_concrete", "Concrete (kg)",
                                          0,6099,0,step = 1),
           "Steel" = sliderInput("anchor_steel", "Steel (kg)",
                                          0,6099,0,step = 1),
           "Chromium Steel" = sliderInput("anchor_chromium_steel", "Chromium Steel (kg)",
                                          0,6099,0,step = 1)
           
           
           
    )
  })
  
  output$anchor_num <- renderUI({
    
    if(is.null(input$anchor))
      return()
    
    switch(input$anchor, 
           "none" = NULL,
           "Concrete"  = numericInput("anchor_concrete_num", label = NULL, value = 0),
           "Steel" = numericInput("anchor_steel_num", label = NULL, value = 0),
           "Chromium Steel" = numericInput("anchor_chromium_steel_num", label = NULL, value = 0)

    )#close switch
    
    
    
  })
  
  output$buoy_slide <- renderUI({
    if(is.null(input$buoy))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$buoy, 
           "none" = NULL,
           "Polyamide Fibers" = sliderInput("buoy_polyamide_fibers", "Polyamide Fibers (kg)",
                                            0,53,0,step = 1),
           "PP Fibers" = sliderInput("buoy_pp_fibers", "PP Fibers (kg)",
                                     0,53,0,step = 1),
           "PET Fibers" = sliderInput("buoy_pet_fibers", "PET Fibers (kg)",
                                      0,53,0,step = 1),
           "RPET Fibers" = sliderInput("buoy_rpet_fibers", "RPET Fibers (kg)",
                                       0,53,0,step = 1),
           "PVC" = sliderInput("buoy_pvc", "PVC",
                               0,53,0,step = 1)
           
           
    )
  })
  
  output$buoy_num <- renderUI({
    
    if(is.null(input$buoy))
      return()
    
    switch(input$buoy, 
           "none" = NULL,
           "Polyamide Fibers"  = numericInput("buoy_polyamide_fibers_num", label = NULL, value = 0),
           "PP Fibers" = numericInput("buoy_pp_fibers_num", label = NULL, value = 0),
           "PET Fibers" = numericInput("buoy_pet_fibers_num", label = NULL, value = 0),
           "RPET Fibers" = numericInput("buoy_rpet_fibers_num", label = NULL, value = 0),
           "Nylon 66" = numericInput("buoy_nylon_66_num", label = NULL, value = 0),
           "PVC" = numericInput("buoy_pvc_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  
  output$chain_slide <- renderUI({
    if(is.null(input$chain))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$chain, 
           "none" = NULL,
           "Steel" = sliderInput("chain_steel", "Steel (kg)",
                                 0,144,0,step = 1),
           "Chromium Steel" = sliderInput("chain_chromium_steel", "Chromium Steel (kg)",
                                          0,144,0,step = 1)
           
           
           
    )
  })
  
  output$chain_num <- renderUI({
    
    if(is.null(input$chain))
      return()
    
    switch(input$chain, 
           "none" = NULL,
           "Steel" = numericInput("chain_steel_num", label = NULL, value = 0),
           "Chromium Steel" = numericInput("chain_chromium_steel_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  output$buoy_rope_slide <- renderUI({
    if(is.null(input$buoy_rope))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$buoy_rope, 
           "none" = NULL,
           "Polyamide Fibers" = sliderInput("buoyrope_polyamide_fibers", "Polyamide Fibers (kg)",
                                            0,50,0,step = 1),
           "PP Fibers" = sliderInput("buoyrope_pp_fibers", "PP Fibers (kg)",
                                     0,50,0,step = 1),
           "PET Fibers" = sliderInput("buoyrope_pet_fibers", "PET Fibers (kg)",
                                      0,50,0,step = 1),
           "RPET Fibers" = sliderInput("buoyrope_rpet_fibers", "RPET Fibers (kg)",
                                       0,50,0,step = 1),
           "Nylon 66" = sliderInput("buoyrope_nylon_66", "Nylon 66 (kg)",
                                    0,50,0,step = 1)
           
           
    )
  })
  
  output$buoy_rope_num <- renderUI({
    
    if(is.null(input$buoy_rope))
      return()
    
    switch(input$buoy_rope, 
           "none" = NULL,
           "Polyamide Fibers"  = numericInput("buoyrope_polyamide_fibers_num", label = NULL, value = 0),
           "PP Fibers" = numericInput("buoyrope_pp_fibers_num", label = NULL, value = 0),
           "PET Fibers" = numericInput("buoyrope_pet_fibers_num", label = NULL, value = 0),
           "RPET Fibers" = numericInput("buoyrope_rpet_fibers_num", label = NULL, value = 0),
           "Nylon 66" = numericInput("buoyrope_nylon_66_num", label = NULL, value = 0)

    )#close switch
    
    
    
  })
  
  output$buoy_weight_slide <- renderUI({
    if(is.null(input$buoy_weight))
      return()
    
    ##Depending on input$infrastructure, we will display a different slider bar
    
    switch(input$buoy_weight, 
           "none" = NULL,
           "Steel" = sliderInput("buoyweight_steel", "Steel (kg)",
                                 0,144,0,step = 1),
           "Chromium Steel" = sliderInput("buoyweight_chromium_steel", "Chromium Steel (kg)",
                                          0,144,0,step = 1)
           
           
           
    )
  })
  
  output$buoy_weight_num <- renderUI({
    
    if(is.null(input$buoy_weight))
      return()
    
    switch(input$buoy_weight, 
           "none" = NULL,
           "Steel" = numericInput("buoyweight_steel_num", label = NULL, value = 0),
           "Chromium Steel" = numericInput("buoyweight_chromium_steel_num", label = NULL, value = 0)
           
    )#close switch
    
    
    
  })
  
  
  output$monitoring_fuel_slide <- renderUI({
    if(is.null(input$monitoring_fuel_type))
      return()
    
    ##Depending on input$fuel, we will display a different slider bar
    
    switch(input$monitoring_fuel_type, 
           "none" = NULL,
           "US Diesel" = sliderInput("monitoring_us_diesel", "US Diesel (Liter)",
                                     0,1.2,0,step = 0.1),
           "US Gasoline" = sliderInput("monitoring_us_gasoline", "US Gasoline (Liter)",
                                       0,1.2,0,step = 0.1),

    )
  })
  
  output$monitoring_fuel_num <- renderUI({
    
    if(is.null(input$monitoring_fuel_type))
      return()
    
    switch(input$monitoring_fuel_type, 
           "none" = NULL,
           "US Diesel"  = numericInput("monitoring_us_diesel_num", label = NULL, value = 0),
           "US Gasoline" = numericInput("monitoring_us_gasoline_num", label = NULL, value = 0)
           
           
    )#close switch
    
    
    
  })
  
  
  output$harvest_vessel_fuel_slide <- renderUI({
    if(is.null(input$harvest_vessel_fuel_type))
      return()
    
    ##Depending on input$fuel, we will display a different slider bar
    
    switch(input$harvest_vessel_fuel_type, 
           "none" = NULL,
           "US Diesel" = sliderInput("harvest_vessel_us_diesel", "US Diesel (Liter)",
                                     0,10,0,step = 0.1),
           "US Gasoline" = sliderInput("harvest_vessel_us_gasoline", "US Gasoline (Liter)",
                                       0,10,0,step = 0.1),
           
    )
  })
  
  output$harvest_vessel_fuel_num <- renderUI({
    
    if(is.null(input$harvest_vessel_fuel_type))
      return()
    
    switch(input$harvest_vessel_fuel_type, 
           "none" = NULL,
           "US Diesel"  = numericInput("harvest_vessel_us_diesel_num", label = NULL, value = 0),
           "US Gasoline" = numericInput("harvest_vessel_us_gasoline_num", label = NULL, value = 0)
           
           
    )#close switch
    
    
    
  })
  
  output$harvest_equip_fuel_slide <- renderUI({
    if(is.null(input$harvest_equip_fuel_type))
      return()
    
    ##Depending on input$fuel, we will display a different slider bar
    
    switch(input$harvest_equip_fuel_type, 
           "none" = NULL,
           "US Diesel" = sliderInput("harvest_equip_us_diesel", "US Diesel (Liter)",
                                     0,10,0,step = 0.1),
           "US Gasoline" = sliderInput("harvest_equip_us_gasoline", "US Gasoline (Liter)",
                                       0,10,0,step = 0.1),
           
    )
  })
  
  output$harvest_equip_fuel_num <- renderUI({
    
    if(is.null(input$harvest_equip_fuel_type))
      return()
    
    switch(input$harvest_equip_fuel_type, 
           "none" = NULL,
           "US Diesel"  = numericInput("harvest_equip_us_diesel_num", label = NULL, value = 0),
           "US Gasoline" = numericInput("harvest_equip_us_gasoline_num", label = NULL, value = 0)
           
           
    )#close switch
    
    
    
  })
  
  
  ### Model Run Output ###
  
  reset <- observeEvent(input$reset_inputs, {
    
    shinyjs::reset("body")
    
  })
  
  sim <- observeEvent(input$go,
                {
              
                  emission_factor <- emissions_values %>% 
                    select (c("stage", "process", "input_label", "drop_down", "unit", "emission_factor" )) %>% 
                    rename("selected_input_name" = drop_down) #%>% 
                    #distinct()
                  #browser()
                  ##Create data frame, name individual values
                  raw_data <- data.frame( 
                    
                    input_label = c("Infrastructure and Equipment Electricity",
                             "Fuel to Harvest Fertile Material - Vegetative Cuttings",
                             "Fuel to Harvest Fertile Material - Nursery",
                             "Nursery and Equipment Electricity Use",
                             "Nutrient Medium",
                             "Culture String",
                             "Long Line",
                             "Electricity for Equipment",
                             "Fuel for Equipment",
                             "Fuel for Transport",
                             "Support Lines",
                             "Anchors",
                             "Buoys",
                             "Chains",
                             "Buoy Rope",
                             "Buoy Weights",
                             "Fuel for Monitoring Vessel",
                             "Fuel for Harvest Vessel",
                             "Fuel for Harvest Equipment"),
                    
                    selected_input_name = c(input$veg_grid_type,
                              input$veg_fuel_type,
                              input$nursery_fuel_type,
                              input$nursery_grid_type,
                              input$nursery_nutrient_type,
                              input$culture_string,
                              input$long_line,
                              input$seeding_grid_type,
                              input$seeding_fuel_type,
                              input$deployment_fuel_type,
                              input$support_line,
                              input$anchor,
                              input$buoy,
                              input$chain,
                              input$buoy_rope,
                              input$buoy_weight,
                              input$monitoring_fuel_type,
                              input$harvest_vessel_fuel_type,
                              input$harvest_equip_fuel_type),
                    
                    
                    
                    
                    
                    #Percent = c((sum(input$building_infrastructure, input$electricity_lamps))),
                    
                    stringsAsFactors = FALSE)
                  
                  raw_data <- raw_data %>%
                    filter(selected_input_name != "none") #%>% 
                    #add_column(input_value = 0)
                    #mutate(input_value)
                  
                  

                  #browser()
                  raw_values <- data.frame(
                    

                    input_value = c(input$veg_us_grid,
                                    input$veg_eu_grid,
                                    input$veg_uk_grid,
                                    input$veg_japan_grid,
                                    input$veg_china_grid,
                                    input$veg_us_grid_num,
                                    input$veg_eu_grid_num,
                                    input$veg_uk_grid_num,
                                    input$veg_japan_grid_num,
                                    input$veg_china_grid_num,
                                    input$veg_us_diesel,
                                    input$veg_us_gasoline,
                                    input$veg_us_diesel_num,
                                    input$veg_us_gasoline_num,
                                    input$nursery_us_diesel,
                                    input$nursery_us_gasoline,
                                    input$nursery_us_diesel_num,
                                    input$nursery_us_gasoline_num,
                                    input$nursery_us_grid,
                                    input$nursery_eu_grid,
                                    input$nursery_uk_grid,
                                    input$nursery_japan_grid,
                                    input$nursery_china_grid,
                                    input$nursery_us_grid_num,
                                    input$nursery_eu_grid_num,
                                    input$nursery_uk_grid_num,
                                    input$nursery_japan_grid_num,
                                    input$nursery_china_grid_num,
                                    input$ammonium_nitrate,
                                    input$sodium_phosphate,
                                    input$ammonium_nitrate_num,
                                    input$sodium_phosphate_num,
                                    input$nursery_polyamide_fibers,
                                    input$nursery_pp_fibers,
                                    input$nursery_pet_fibers,
                                    input$nursery_rpet_fibers,
                                    input$nursery_nylon_66,
                                    input$nursery_polyamide_fibers_num,
                                    input$nursery_pp_fibers_num,
                                    input$nursery_pet_fibers_num,
                                    input$nursery_rpet_fibers_num,
                                    input$nursery_nylon_66_num,
                                    input$seeding_polyamide_fibers,
                                    input$seeding_pp_fibers,
                                    input$seeding_pet_fibers,
                                    input$seeding_rpet_fibers,
                                    input$seeding_nylon_66,
                                    input$seeding_polyamide_fibers_num,
                                    input$seeding_pp_fibers_num,
                                    input$seeding_pet_fibers_num,
                                    input$seeding_rpet_fibers_num,
                                    input$seeding_nylon_66_num,
                                    input$seeding_us_grid,
                                    input$seeding_eu_grid,
                                    input$seeding_uk_grid,
                                    input$seeding_japan_grid,
                                    input$seeding_china_grid,
                                    input$seeding_us_grid_num,
                                    input$seeding_eu_grid_num,
                                    input$seeding_uk_grid_num,
                                    input$seeding_japan_grid_num,
                                    input$seeding_china_grid_num,
                                    input$seeding_us_diesel,
                                    input$seeding_us_gasoline,
                                    input$seeding_us_natgas,
                                    input$seeding_eu_natgas,
                                    input$seeding_us_propane,
                                    input$seeding_eu_propane,
                                    input$seeding_us_diesel_num,
                                    input$seeding_us_gasoline_num,
                                    input$seeding_us_natgas_num,
                                    input$seeding_eu_natgas_num,
                                    input$seeding_us_propane_num,
                                    input$seeding_us_propane_num,
                                    input$deployment_us_diesel,
                                    input$deployment_us_gasoline,
                                    input$deployment_us_diesel_num,
                                    input$deployment_us_gasoline_num,
                                    input$supportline_polyamide_fibers,
                                    input$supportline_pp_fibers,
                                    input$supportline_pet_fibers,
                                    input$supportline_rpet_fibers,
                                    input$supportline_nylon_66,
                                    input$supportline_polyamide_fibers_num,
                                    input$supportline_pp_fibers_num,
                                    input$supportline_pet_fibers_num,
                                    input$supportline_rpet_fibers_num,
                                    input$supportline_nylon_66_num,
                                    input$anchor_concrete,
                                    input$anchor_steel,
                                    input$anchor_chromium_steel,
                                    input$anchor_concrete_num,
                                    input$anchor_steel_num,
                                    input$anchor_chromium_steel_num,
                                    input$buoy_polyamide_fibers,
                                    input$buoy_pp_fibers,
                                    input$buoy_pet_fibers,
                                    input$buoy_rpet_fibers,
                                    input$buoy_pvc,
                                    input$buoy_polyamide_fibers_num,
                                    input$buoy_pp_fibers_num,
                                    input$buoy_pet_fibers_num,
                                    input$buoy_rpet_fibers_num,
                                    input$buoy_pvc_num,
                                    input$chain_steel,
                                    input$chain_chromium_steel,
                                    input$chain_steel_num,
                                    input$chain_chromium_steel_num,
                                    input$buoyrope_polyamide_fibers,
                                    input$buoyrope_pp_fibers,
                                    input$buoyrope_pet_fibers,
                                    input$buoyrope_rpet_fibers,
                                    input$buoyrope_nylon_66,
                                    input$buoyrope_polyamide_fibers_num,
                                    input$buoyrope_pp_fibers_num,
                                    input$buoyrope_pet_fibers_num,
                                    input$buoyrope_rpet_fibers_num,
                                    input$buoyrope_nylon_66_num,
                                    input$buoyweight_steel,
                                    input$buoyweight_chromium_steel,
                                    input$buoyweight_steel_num,
                                    input$buoyweight_chromium_steel_num,
                                    input$monitoring_us_diesel,
                                    input$monitoring_us_gasoline,
                                    input$monitoring_us_diesel_num,
                                    input$monitoring_us_gasoline_num,
                                    input$harvest_vessel_us_diesel,
                                    input$harvest_vessel_us_gasoline,
                                    input$harvest_vessel_us_diesel_num,
                                    input$harvest_vessel_us_gasoline_num,
                                    input$harvest_equip_us_diesel,
                                    input$harvest_equip_us_gasoline,
                                    input$harvest_equip_us_diesel_num,
                                    input$harvest_equip_us_gasoline_num),
                    

                    stringsAsFactors = FALSE)
                  
                  #browser()
                  
                  raw_values <- raw_values %>% 
                    filter(input_value != "0") %>% 
                    mutate(selected_input_name = raw_data$selected_input_name) %>% 
                    mutate(input_label = raw_data$input_label) %>% 
                    select(input_label, selected_input_name, input_value)
                  
                  #browser()

                  emission_raw <- raw_values %>% 
                    left_join(emission_factor, raw_values, by = c("input_label", "selected_input_name")) %>% 
                    mutate(gwp = input_value * emission_factor) %>% 
                    mutate(gwp = round(gwp,2)) %>% 
                    mutate(gwp_total = sum(gwp)) %>% 
                    mutate(gwp_total = round(gwp_total,1)) %>% 
                    mutate(perc_gwp = ((gwp/gwp_total) * 100))  %>% 
                    mutate(perc_gwp = round(perc_gwp,2)) %>% 
                    select(stage, process, input_label, selected_input_name , input_value, unit, gwp, gwp_total, perc_gwp) %>% 
                    as.data.frame()
                    #mutate(sum_gwp = sum(gwp))
                  
                  ## Total farm GWP Value
                  farm_total_value <- emission_raw %>% 
                    select(gwp_total) %>% 
                    mutate(gwp_total = round(gwp_total,1)) %>% 
                    distinct_all() 

                    #left_join(emission_factor, by = "input_name", "selected_input")
                  
                 # browser()
                  
                  sliderValues <- reactive({
                    
                    emission_raw
                   
                    
                      
                    
                    
                  
                    #filter data and manipulate columns etc
                    # raw_data %>%
                    #   mutate(Percent = (Value/sum(Value)) * 100) %>%
                    #   arrange(desc(Percent)) %>%
                      # as.data.frame()
                      
                        
                      
                    
                  })
                  
                  
                  
                  
                
                
                  # f <- function(building_infrastructure, electricity_lamps){
                  #   building_infrastructure + electricity_lamps
                  # }
                  
                  ## Total GWP text
                  output$farm_total <- renderUI(
                    {
                      farm_total <- paste0("<h3 style = 'margin-top: 0px;'>","Total Farm GWP: ", "</h3", 
                                           "<br>",
                                           "<b>", farm_total_value$gwp_total, "kg CO2/ha/yr", "</b>") %>% 
                        lapply(htmltools::HTML)
                       
                      #HTML(paste0(farm_total))
                      farm_total
                      

                    #return farm total
                    farm_total
                    
                  })
                  
                  #show values using HTML table
                  output$values <- renderReactable(
                  {
                    final_table <- emission_raw %>% 
                      select(-gwp_total) %>% 
                      arrange(desc(perc_gwp)) %>% 
                      rename("Life Cycle Stage" = stage,
                             "Process" = process,
                             "Input Category" = input_label,
                             "Input Name" = selected_input_name,
                             "Input Value" = input_value,
                             "Unit" = unit,
                             "GWP Value" = gwp,
                             "Percent of Total GWP" = perc_gwp
                             ) 
                      
                    
                    reactable(final_table)
                      
                    
                    #sliderValues()

                  })
                  #browser()
                  ### Pie chart
                  output$donut <- renderPlotly({
                   # browser()
                    
                    
                    
                    ## Plotly donut
                    
                    donut <- emission_raw %>%
                      group_by(stage) %>%
                      #summarize(perc_gwp = n()) %>%
                      plot_ly(labels = ~input_label, values = ~perc_gwp) %>%
                      add_pie(hole = 0.6) %>%
                      layout(showlegend = T,
                             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
                    
                    # donut plots (one for each of the two parts of the model)
                    
                    # output_1 %>%  
                    #   ggplot(aes(x=2, y=perc_gwp, fill=selected_input_name)) +
                    #   geom_bar(stat = "identity", color= "white") +
                    #   ggplot2::coord_polar(theta = "y", start=0) +
                    #   #geom_text(aes(y=lab.ypos, label = input_name), color= "white") +
                    #   #scale_fill_manual(values=mycols) +
                    #   theme_void() +
                    #   xlim(0.5,2.5)
                    # 
                   # #output_1 %>%
                   #    output_1 %>%  
                   #      ggplot(aes(x=2, y=perc_gwp, fill=selected_input_name)) +
                   #    #ggplot(sliderValues, aes(x=2, y=perc_gwp, fill=selected_input_name)) +
                   #    geom_bar(stat= 'identity', color= 'white') +
                   #    #coord_polar(theta= 'y', start=0) +
                   #    #geom_text(aes(y=lab.ypos, label = selected_input_name), color= "white") +
                   #    #scale_fill_manual(values=mycols) +
                   #    theme_void() +
                   #    xlim(0.5,2.5)
                    
                  })
                  
                  
                  ## Potential propeller chart
                  # https://plot.ly/r/sunburst-charts/
                  
                  # output$propeller <- renderPlot({
                  #   # browser()
                  #   
                  #   
                  #   ggplot(emission_raw, aes(x=selected_input_name, y=perc_gwp, fill= selected_input_name)) +
                  #     geom_bar(stat='identity') + # probably want to add fill/color
                  #     #  ylim() + # if necessary
                  #     theme_minimal() +
                  #     theme(axis.text = element_blank(),
                  #           axis.title = element_blank(),
                  #           panel.grid = element_blank(),
                  #           plot.margin = unit(rep(-2,4), "cm")) + #removes weird spacing; may not be necessary
                  #     ggplot2::coord_polar(start=0)
                    
                    # propeller <- plot_ly(
                    #   ids = emission_raw$selected_input_name,
                    #   labels = emission_raw$selected_input_name,
                    #   parents = emission_raw$stage,
                    #   values = emission_raw$perc_gwp,
                    #   type = 'sunburst'
                    # )
                    
                    # propeller <- emission_raw %>% 
                    #   group_by(stage) %>% 
                    #   plot_ly(
                    #     labels = emission_raw$selected_input_name, 
                    #     parents = emission_raw$stage,
                    #     values = emission_raw$perc_gwp,
                    #     type = 'sunburst',
                    #     branchvalues = emission_raw$gwp_total
                    #   )
                    
                    
                    
                 # }) # Close sunburst plot output
                  
                  
                  updateTabItems(session, inputId="tabs", selected = "results")
                  
                  
                  
              
                        
            }         
                      
                      )
  
  ### Case Study Table Output ###
  
  # farm_data_select <- farm_data %>% 
  #   select(c("farm_name", "total_gwp_farm", "stage", "process", "input", "gwp_mt_seaweed", "stage_total", "process_total")) %>% 
  #   rename("Farm Name" = farm_name,
  #          "Total GWP" = total_gwp_farm,
  #          "Life Cycle Stage" = stage,
  #          "Process" = process,
  #          "Input" = input) %>% 
  #   mutate(Process = capitalize (Process)) %>% 
  #   mutate(Input = capitalize (Input))
  # 
  # output$FarmSummary <- renderReactable(
  #   reactable(
  #     farm_data_select,
  #     groupBy = c("Farm Name", "Total GWP", "Life Cycle Stage", "Process")
  # )
  # 
  # )
  
  ### End Case Study Output ###
  
  
  
  #browser()
  
  
    # selected_farm_summary <- selected_farm %>% 
    #   summarize(total_GWP = sum(gwp_mt_seaweed))
    
    
    
  
  
  
  
}



### ----------
### Section 4: Run application
### ----------
shinyApp(ui = ui, server = server)
