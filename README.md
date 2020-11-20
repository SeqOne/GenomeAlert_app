# Genome Alert! App

![Genome Alert! logo](www/genome_alert_title.png)

## Overview 

This repository contains the Genome Alert! shiny app.  

Genome Alert! is an automatic tracking and self-curating method of variant pathogenicity and genotype-phenotype knowledge in ClinVar database.

This app display processed ClinVar data through the Genome Alert! framework : 
- **ClinVCF** monitors submissions and extracts clinical information from a Clinvar XML monthly Full Release into an easy-to-manipulate standard VCF 4.2 file.    
In order to reclassify high confidence pathogenic variants with a conflicting interpretation of pathogenicity status, ClinVCF first removes ACMG classification outliers submissions for variants with at least 4 submissions according to the 1.5 * Interquartile Range method. Secondly, it reclassifies the variant status according to the ClinVar classification system and finally we set the reclassification confidence with a 3-stars level system.  [https://github.com/SeqOne/clinvcf](https://github.com/SeqOne/clinvcf)   
- **Variant Alert!** track every significant changes in variant classification and gene-disease association between two versions of ClinVCF VCFs, including their “breaking change” status defined according to the suspected clinical impact of these changes. A major break change is defined as a potential direct impact on clinical diagnosis. A minor break change is a change in confidence classification (e.g. Pathogenic to Likely Pathogenic status). [https://github.com/SeqOne/variant_alert](https://github.com/SeqOne/variant_alert)  
- **ClinVarome** gathers and processes all ClinVar knowledge available through time. Through an unsupervised clustering model, it classifies clinical validity of information for each gene with a 3-stars level system [https://gitlab.seq.one/labo/clinvarome](https://gitlab.seq.one/labo/clinvarome).  

## Installation

**Requirements** 

```bash
ubuntu-server
r-base
shiny-server
```

```r
library(tidyverse)
library(lubridate)
library(shiny)
library(shinythemes)
library(htmlwidgets)
library(markdown)
``` 

NB: Installation guide is available in RStudio [website](https://rstudio.com/products/shiny/download-server/ubuntu/).

## Mandatory files

In addition to this repository, you will need to add 3 output files from Genome Alert!'s [ClinVarome](https://gitlab.seq.one/labo/clinvarome) in the `www/` folder :
- compare-variant_total.tsv
- compare-gene_total.tsv
- clinvar_GRCh38_clinvarome_annotation.tsv 


--------------------------------------------------------------------------------
*Genome Alert! is a collaboration of :* 

[![SeqOne](img/logo-seqone.png)](https://seq.one/) 

[![Université Grenoble Alpes](img/logo-uga.png)](https://iab.univ-grenoble-alpes.fr/) 

[![CHU de Rouen](img/logo-CHU.png)](https://www.chu-rouen.fr/service/service-de-genetique/)
