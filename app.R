#
# Shiny App for Genome Alert! exploration
#
library(tidyverse)
library(lubridate)
library(shiny)
library(shinythemes)
library(htmlwidgets)
library(markdown)

# Parse data
clinvarome <- read_delim("www/clinvar_GRCh38_2020-11_clinvarome_annotation.tsv",delim="\t",col_names = TRUE)
clinvar_gene <- read_delim("www/compare-gene_total.tsv", delim="\t", col_names = TRUE)
clinvar_variant <- read_delim("www/compare-variant_total.tsv", delim="\t", col_types = cols(clinvar_id = col_character()), col_names = TRUE)

# Clean inputs 
clinvar_variant$date  <- ymd(clinvar_variant$name_clinvar_new )
clinvar_variant <- clinvar_variant %>%
    select(gene_info, variant_id, clinvar_id, old_classification, new_classification, confidence, breaking_change, reclassification_status, date) %>%
    rename(gene_symbol = gene_info, change_type = breaking_change) %>%
    filter(!(change_type == ".." | change_type == "unknown")) %>%
    arrange(desc(date))

clinvar_gene$date <- ymd(clinvar_gene$name_clinvar_new )
clinvar_gene <- clinvar_gene %>%
    select(-name_clinvar_new, -name_clinvar_old, -gene_info_id) %>%
    rename(gene_symbol = gene_info) %>%
    arrange(desc(date))

clinvarome <- clinvarome %>%
    select(gene_info, cluster_name, clinical_disease, clinical_finding, gene_name_check, first_path_var_date, last_pathogenic_variant, variant_number, stop_fs_splice, missense_inframe, other, highest_review_confidence, highest_pathogenic_class, clinvarome_date)  %>%
    rename(gene_symbol = gene_info)
        
clinvarome$clinical_disease[is.na(clinvarome$clinical_disease)] <- "."
clinvarome$clinical_finding[is.na(clinvarome$clinical_finding)] <- "."

# Define UI for application
ui <- 
       navbarPage(
           
           title = tags$a(div(img(src='genome_alert_title_white.png',style="margin-top: -14px; padding-right:10px;padding-bottom:10px", height = 55)), href="https://GenomeAlert.univ-grenoble-alpes.fr/"),
           windowTitle="Genome Alert!",
           
           theme = shinytheme("flatly"),
           
           tabPanel("Home",
                    
                    # Application title
                    #titlePanel("Genome Alert! framework"),
                    tags$head(includeHTML(("google-analytics.html"))),             
                    fluidPage(position = "center",
                        
                    includeMarkdown("www/genome_alert.md")
                        
                    ),
                    
                    # add logos
                    tags$div(
                        p(tags$a(img(src='logo-seqone.png', align = "right",width="200"), href="https://seq.one/")),
                        p(tags$a(img(src='logo-CHU.png', align = "right", width="100"), href="https://www.chu-rouen.fr/service/service-de-genetique/")),
                        p(tags$a(img(src='logo-uga.png', align = "right", width="90"), href="https://iab.univ-grenoble-alpes.fr/?language=en"))              
                    )    
           ),
           
           tabPanel("ClinVar-ome",
                    
                    # Application title
                    titlePanel("ClinVar mendelian genome"),
                    
                    fluidRow(
                        column(6,
                               plotOutput("plot_star_clinvarome")),
                        column(6,
                               plotOutput("plot_date_clinvarome")
                        )
                        
                    ),
                    
                    # print data table
                    DT::dataTableOutput('table_clinvarome'),
                    # add download button
                    downloadButton('downloadData_clinvarome', 'Download ClinVarome list'),
                    # add logos
                    tags$div(
                        p(tags$a(img(src='logo-seqone.png', align = "right",width="200"), href="https://seq.one/")),
                        p(tags$a(img(src='logo-CHU.png', align = "right", width="100"), href="https://www.chu-rouen.fr/service/service-de-genetique/")),
                        p(tags$a(img(src='logo-uga.png', align = "right", width="90"), href="https://iab.univ-grenoble-alpes.fr/?language=en"))              
                    )
           ),
            
            tabPanel("Compare genes",
                     
                # Application title
                titlePanel("Compare genes"),
                
                fluidRow(
                    
                    column(4,
                           dateRangeInput("dates_cg", h3("Date range"),start=(Sys.Date()-730),min="2017-05-16")),
                    column(8,
                           plotOutput("plot_compare_genes")
                           ),
                ),
                
                # print data table
                DT::dataTableOutput('table_compare_genes'),
                # add download button
                downloadButton('downloadData_compare_genes', 'Download Gene Alert list'),
                # add logos
                tags$div(
                    p(tags$a(img(src='logo-seqone.png', align = "right",width="200"), href="https://seq.one/")),
                    p(tags$a(img(src='logo-CHU.png', align = "right", width="100"), href="https://www.chu-rouen.fr/service/service-de-genetique/")),
                    p(tags$a(img(src='logo-uga.png', align = "right", width="90"), href="https://iab.univ-grenoble-alpes.fr/?language=en"))
                )
                ),
            
           tabPanel("Compare variants",
                    
                    # Application title
                    titlePanel("Compare variants"),
                    fluidRow(
                        
                        column(4,
                               dateRangeInput("dates_cv", h3("Date range"),start=(Sys.Date()-730),min="2017-05-16")),
                        column(8,
                               plotOutput("plot_compare_variants")
                        )
                    ),
                    
                    # print data table
                    DT::dataTableOutput('table_compare_variants'),
                    # add download button
                    downloadButton('downloadData_compare_variants', 'Download Variant Alert list'),
                    
                    # add logos
                    tags$div(
                        p(tags$a(img(src='logo-seqone.png', align = "right",width="200"), href="https://seq.one/")),
                        p(tags$a(img(src='logo-CHU.png', align = "right", width="100"), href="https://www.chu-rouen.fr/service/service-de-genetique/")),
                        p(tags$a(img(src='logo-uga.png', align = "right", width="90"), href="https://iab.univ-grenoble-alpes.fr/?language=en"))              
                    )    
           )               

    
        )

# Define server logic required
server <- function(input, output) {
    # process Clinvarome
    
    clinvarome_plot <- reactive({
        clinvarome %>%
            group_by(cluster_name) %>%
            count()
    })
    
    output$plot_date_clinvarome <- renderPlot({
        ggplot(clinvarome) + aes(x = first_path_var_date) + 
            ggtitle("Gene's first (likely) pathogenic entry date distribution in ClinVarome") +
            geom_bar()   
    }
    )
    
    output$plot_star_clinvarome <- renderPlot({
        ggplot(clinvarome_plot(), aes(x="" , y=n, fill=cluster_name)) + 
            ggtitle("Clinical validity of genes distribution in ClinVarome") +
            geom_bar(stat='identity') +
            coord_polar("y", start=0) +
            theme_void()
    }
    )    
    
    output$table_clinvarome <- DT::renderDataTable(clinvarome, filter = "top", options = list(pageLength = 15,  scrollX = T, columnDefs = list(list(
        targets = c(3,4,11,12),
        render = JS(
            "function(data, type, row, meta) {",
            "return type === 'display' && data.length > 40 ?",
            "'<span title=\"' + data + '\">' + data.substr(0, 40) + '...</span>' : data;",
            "}")
    ))), callback = JS('table.page(3).draw(false);' )
    )
    
    output$downloadData_clinvarome <- downloadHandler(
        filename = function() { 
            #paste("ClinVarome_", Sys.Date(), ".tsv", sep="")
            paste("ClinVarome_", clinvarome$clinvarome_date[1], ".tsv", sep="")
        },
        content = function(file) {
            write_delim(clinvarome, file,delim = "\t", col_names = TRUE)
        }, contentType = "text/tsv")
    
        
    # process compare gene
    
    compare_gene_new <- reactive({
        filter(clinvar_gene, between(date, as.Date(input$dates_cg[1]),as.Date(input$dates_cg[2])))
    })
    
    compare_gene_new_plot <- reactive({
        compare_gene_new() %>%
        filter(pathogenic_class_status != "UNCHANGED") %>%
        filter(pathogenic_class_status != "DOWNGRADED_PATHOGENICITY_STATUS") %>%
        filter(pathogenic_class_status != "UPGRADED_PATHOGENICITY_STATUS") %>%
        group_by(month=floor_date(date, "2 month"),pathogenic_class_status) %>%
        count() %>%
        mutate(year= year(month))
    })
    
    output$plot_compare_genes <- renderPlot({
        ggplot(data = compare_gene_new_plot(), aes(x = month, y= n,  fill=pathogenic_class_status )) + 
            ggtitle("Monitoring entries and loss of gene-disease associations in ClinVar") +
            geom_bar(stat='identity') +
            theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position = c(.98, .98),
                  legend.justification = c("right", "top"),
                  legend.box.just = "left",
                  legend.margin = margin(6, 6, 6, 6),
                  legend.background=element_blank()) +
            scale_x_date(date_labels = "%m-%Y",date_breaks = "2 month") + 
            geom_text(aes(label=ifelse(pathogenic_class_status=="NEW_PATHOGENICITY",n,"")),color="black", position = position_stack(vjust = 0.5), size= 5)
    })
    

    output$downloadData_compare_genes <- downloadHandler(
        filename = function() { 
            paste("gene-alert_", input$dates[1],"_",input$dates[2], ".tsv", sep="")
        },
        content = function(file) {
            write_delim(compare_gene_new(), file ,delim = "\t", col_names = TRUE)
        }, contentType = "text/tsv")
    
    output$table_compare_genes <- DT::renderDataTable(compare_gene_new(), filter = "top", options = list(pageLength = 15, scrollX = T))
    
    # process compare variant
    
    compare_variant_new <- reactive({
        filter(clinvar_variant, between(date, as.Date(input$dates_cv[1]),as.Date(input$dates_cv[2])))
    })
    
    compare_variant_new_plot <- reactive({
        compare_variant_new() %>%
            filter(change_type != "..") %>%
            group_by(month=floor_date(date, "2 month"), change_type) %>%
            count() %>%
            mutate(year= year(month))
    })
    
    output$plot_compare_variants <- renderPlot({
        ggplot(data = compare_variant_new_plot(), aes(x = month, y= n,  fill=change_type )) + 
            ggtitle("Monitoring of change types in variant classification in ClinVar") +
            geom_bar(stat='identity') +
            theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
            scale_x_date(date_labels = "%m-%Y",date_breaks = "2 month") + 
            geom_text(aes(label=ifelse(change_type=="major",n,"")),color="black", position = position_stack(vjust = 0.5), size= 5)
    })
    
    output$downloadData_compare_variants <- downloadHandler(
        filename = function() { 
            paste("variant-alert_", input$dates[1],"_",input$dates[2], ".tsv", sep="")
        },
        content = function(file) {
            write_delim(compare_variant_new(), file ,delim = "\t", col_names = TRUE)
        }, contentType = "text/tsv")
    
    output$table_compare_variants <- DT::renderDataTable(compare_variant_new(), filter = "top", options = list(pageLength = 15, scrollX = T, columnDefs = list(list(
        targets = c(2,4,5,6),
        render = JS(
            "function(data, type, row, meta) {",
            "return type === 'display' && data.length > 30 ?",
            "'<span title=\"' + data + '\">' + data.substr(0, 30) + '...</span>' : data;",
            "}")
    ))), callback = JS('table.page(3).draw(false);' )
    )
    
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
