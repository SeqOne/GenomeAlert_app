# Genome Alert! 

![Genome Alert! logo](www/genome_alert_title.png)

## Overview

This repository contains the Genome Alert! framework and shiny app.  

Genome Alert! is an automatic tracking and self-curating method of variant pathogenicity and genotype-phenotype knowledge in ClinVar database.

This app display processed ClinVar data through the Genome Alert! framework : 
- **ClinVCF** monitors submissions and extracts clinical information from a Clinvar XML monthly Full Release into an easy-to-manipulate standard VCF 4.2 file.  
In order to reclassify high confidence pathogenic variants with a conflicting interpretation of pathogenicity status, ClinVCF first removes ACMG classification outliers submissions for variants with at least 4 submissions according to the 1.5 * Interquartile Range method. Secondly, it reclassifies the variant status according to the ClinVar classification system and finally we set the reclassification confidence with a 3-stars level system.  [https://github.com/SeqOne/clinvcf](https://github.com/SeqOne/clinvcf)   
- **Variant Alert!** track every significant changes in variant classification and gene-disease association between two versions of ClinVCF VCFs, including their “breaking change” status defined according to the suspected clinical impact of these changes. A major break change is defined as a potential direct impact on clinical diagnosis. A minor break change is a change in confidence classification (e.g. Pathogenic to Likely Pathogenic status). [https://github.com/SeqOne/variant_alert](https://github.com/SeqOne/variant_alert)  
- **ClinVarome** gathers and processes all ClinVar knowledge available through time. Through an unsupervised clustering model, it classifies clinical validity of information for each gene with a 3-stars level system [https://gitlab.seq.one/labo/clinvarome](https://gitlab.seq.one/labo/clinvarome).  

## Complete pipeline to generate the overall data

### Generate all VCFs from ClinVar data with ClinVCF

First, install [ClinVCF](https://github.com/SeqOne/clinvcf) and then download all Clinvar XML file

```bash
cd OUTPUT_PATH/
wget -r ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/xml/
```

Copy all file into one folder 
```bash
mkdir OUTPUT_PATH/data
find OUTPUT_PATH/ftp.ncbi.nlm.nih.gov/ -type f -print0 | xargs -0 cp -t OUTPUT_PATH/data/
```

Get list to process clinvcf (XML to VCF) 

```bash
ls OUTPUT_PATH/data/ | grep ".xml.gz" | grep -v "md5" > OUTPUT_PATH/data/clinvar_xml_list.txt
```

Process all ClinVar XML release with ClinVCF 
```bash
while read -r line ; do 
  echo line
  echo ${line}
  echo filename
  filename=$(echo "$line" | cut -d. -f1 | cut -d_ -f2) 
  echo ${filename}
  if [ -f "OUTPUT_PATH/data/clinvar_GRCh38_${filename}.vcf.gz" ]
  then
    echo "${filename} already processed"
  else
  clinvcf --genome GRCh38 --coding-first --gff data/GRCh38_latest_genomic.gff OUTPUT_PATH/data/${line} | bgzip -c > OUTPUT_PATH/data/clinvar_GRCh38_${filename}.vcf.gz
  tabix -p vcf OUTPUT_PATH/data/clinvar_GRCh38_${filename}.vcf.gz
  fi
done < OUTPUT_PATH/data/clinvar_xml_list.txt
```

### 


## Shiny app installation

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

### Mandatory files

In addition to this repository, you will need to add 3 output files from Genome Alert!'s [ClinVarome](https://gitlab.seq.one/labo/clinvarome) in the `www/` folder :
- compare-variant_total.tsv
- compare-gene_total.tsv
- clinvar_GRCh38_clinvarome_annotation.tsv 


--------------------------------------------------------------------------------
*Genome Alert! is a collaboration of :* 

[![SeqOne](www/logo-seqone.png)](https://seq.one/) 

[![Université Grenoble Alpes](www/logo-uga.png)](https://iab.univ-grenoble-alpes.fr/) 

[![CHU de Rouen](www/logo-CHU.png)](https://www.chu-rouen.fr/service/service-de-genetique/)
