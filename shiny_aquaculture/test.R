# ui <- shinyUI(
#   
#   dashboardPage(
#     
#     dashboardHeader(title = "Shiny Aquaculture"),
#     
#     # Sidebar menu
#     dashboardSidebar(width = "250px",
#                      collapsed = TRUE,
#                      sidebarMenu(id = "tabs",
#                                  
#                                  # description
#                                  menuItem("description",
#                                           tabName = "description",
#                                           icon = NULL,
#                                           selected = TRUE)#,
#                                  
#                                  # # Inputs
#                                  # menuItem("Inputs", 
#                                  #          tabName = "inputs", 
#                                  #          icon = NULL,
#                                  #          selected = NULL),
#                                  # 
#                                  # # Results
#                                  # menuItem("Results", 
#                                  #          tabName = "results", 
#                                  #          icon = NULL,
#                                  #          selected = NULL),
#                                  
#                                  
#                                  
#                      ) # close sidebarMenu
#                      
#     ), # close dashboardSidebar
#     
#     #main panel
#     dashboardBody(
#       
#       tabItems(
#         
#         #description
#         tabItem(tabName =  "description",
#                 description()
#         ),
#       )#close tab items
#     )#close dashboard body
#   )#close dashboard page
# )# close shiny UI
