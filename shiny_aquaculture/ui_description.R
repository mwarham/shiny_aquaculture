## Ui Description

library(shiny)
library(shinyjs)
library(shinydashboard)
library(leaflet)
library(shinyBS)
library(hrbrthemes)
library(tidyverse)
library(sf)
library(png)

# ui <- fluidPage(
#   
#   
#   #header bar
#   header <- dashboardHeader(title = "Shiny Aquaculture"),
#   
#   sidebar <- dashboardSidebar(
#     sidebarMenu(
#       id = "tabs",
#       menuItem("Description", tabName = "description", icon = icon("book-reader")),
#       menuItem("Inputs",tabName = "inputs", icon = icon("dashboard")),
#       menuItem("Results",tabName = "results", icon = icon("chart-line"))
#       
#       
#     )), # close dashboardSidebar
#   
#   body <- dashboardBody(
#     # useShinyalert(),
#     
#     tabItems(
#       # input tab
#       tabItem(tabName = "description",
#               h1("Shiny Aquaculture"),
#               "simMPA is a web application for simulating the effects of Marine Protected Areas.",
#               h2("sea weed is cool")),
#       
#       
#       
#       tabItem(tabName = "inputs",
#               actionButton("go","Run Simulations"),
#               br(),
#               br(),
#               box(title = "Harvesting of Fertile Material",
#                   solidHeader = TRUE,
#                   collapsible = TRUE,
#                   status = "primary",
#                   "Select blah blah",
#                   br(),
#                   #selectizeInput("sciname",label = 'Common Name', choices = viable_fishlife_list, selected = "brownsnout spookfish"),
#                   sliderInput("blah blah", label = "blah blah blah",
#                               0.6,0.99,.8,step = 0.01),
#                   # sliderInput("sigma_r", label = "Recruitment Variation (CV)",
#                   #             0,0.3,0,step = 0.01),
#                   # sliderInput("rec_ac", label = "Recruitment Autocorrelation",
#                   #             0,1,0,step = 0.01),
#                   # selectizeInput("dd_form","Timing of Density Dependence",
#                   #                choices = list(
#                   #                  "Local density dependence: Density dependence occurs independently in each patch, and recruits then disperse to nearby patches" = 1,
#                   #                  "Global density dependence: Density dependence is a function of the sum of spawning biomass across all patches, and recruits are then distributed according to habitat quality" = 2,
#                   #                  "Post-dispersal density dependence: Larvae are distributed throughout the system, and then density dependence occurs based on the density of adult biomass at the destination patch" = 3
#                   #                ),
#                   #                selected = 1),
#                   # sliderInput("adult_movement", label = "Upper % patches moved by adults",
#                   #             0,40,0, post = "%"),
#                   # sliderInput("dd_adult_movement", label = "Sensitivity of adult movement to density",
#                   #             0,1,0,step = 0.01),
#                   sliderInput("Ilan plays the cello", label = "Salty Strings",
#                               0,100,0, post = "%")),
#               box(title = "Vegetative Cuttings",
#                   solidHeader = TRUE,
#                   collapsible = TRUE,
#                   status = "warning",
#                   "Select fishery options",
#                   numericInput("Electricity", label = "Electricity",
#                                value = 1, min = 0, max = 10, step = 0.001),
#                   sliderInput("Building Infrastructure", label = "big buildings",
#                               min = 0, max = 4, value = 0.25, step = 0.01),
#                   # selectizeInput("fleet_model","Fleet Model:", 
#                   #                list("Constant Effort" = "constant-effort",
#                   #                     "Constant Catch" = "constant-catch",
#                   #                     "Open Access" = "open-access")),
#                   # conditionalPanel(
#                   #   condition = "input.fleet_model == 'open-access'",
#                   #   sliderInput("max_cr_ratio",
#                   #               "Max. Cost to Revenue Ratio. Higher = Less Fishing",
#                   #               min = 0,
#                   #               max = 1,
#                   #               value = 0.8,
#                   #               step = 0.01),
#                   #   sliderInput("price_slope",
#                   #               "Annual percent change in price",
#                   #               min = 0,
#                   #               max = 100,
#                   #               value = 0,
#                   #               step = 0.01,
#                   #               post = '%')),
#                   # selectizeInput("spatial_allocation","Spatial effort allocation strategy", 
#                   #                list("Spread evenly in open areas" = "simple",
#                   #                     "Concentrated around fishable biomass" = "gravity",
#                   #                     "Concentrated around profit per unit effort" = "profit-gravity")),
#                   # selectizeInput("mpa_reaction","Initial fleet reaction to MPA:", list("Leave the fishery" = "leave",
#                   #                                                                      "Concentrate outside MPA" = "concentrate"))
#               ), # close fishing fleet box,
#               box(title = "Nursery: Spore Formation",
#                   solidHeader = TRUE,
#                   collapsible = TRUE,
#                   status = "info",
#                   "Design your MPA",
#                   sliderInput("Nutrient Medium", label = "Nutrient Medium",
#                               0,100,25, post = "%"),
#                   sliderInput("Lab Infrastructure", label = "Lab infrastructure",
#                               0,49,25),
#                   # sliderInput("min_size","MPA Patchiness",0,1,.1, value = 0),
#                   # sliderInput("mpa_habfactor","MPA habitat multiplier",1,4,.1, value = 1),
#                   # checkboxInput("random_mpas", "Randomly Place MPAs?"),
#                   # checkboxInput("sprinkler", "Place MPA in larval source?")
#                   
#               )
#       )# close mpa design box
#       ,# close inputs,
#       
#       tabItem(
#         tabName = "results",
#         fluidRow(
#           #box(withSpinner(plotOutput("summary_plot")), title = "Percent change in metrics relative to values just before the MPA"),
#           #box(withSpinner(plotOutput("static_doughnut")), title = "Spatial distribution of biomass and effort at equilibrium"),
#           #box(withSpinner(plotOutput("raw_summary_plot")), title = "Absolute values of metrics over time")
#         ) # close mainPanel
#       ) # close plot tab
#     ) # close tabItems
#   ), # close dashboardBody
#   
#   dashboardPage(
#     header,
#     sidebar,
#     body
#   ) # close dashboard Padte  
#   
#   #) #close tab items
#   #)#close dashboardBody
#   #)#close dashboardPage
# ) #Close shinyUI