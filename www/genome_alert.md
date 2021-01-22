# Genome Alert! framework

Genome Alert! is an automatic monitoring and curating method of variant pathogenicity and genotype-phenotype knowledge in ClinVar database.

![Genome Alert! logo](genome_alert_title.png)

### The Framework

Genome Alert! is build in 3 parts :
- **ClinVCF** monitors submissions and extracts clinical information from a Clinvar XML monthly Full Release into an easy-to-manipulate standard VCF 4.2 file. 
In order to reclassify high confidence pathogenic variants with a conflicting interpretation of pathogenicity status, ClinVCF first removes ACMG classification outliers submissions for variants with at least 4 submissions according to the 1.5 * Interquartile Range method. Secondly, it reclassifies the variant status according to the ClinVar classification system and finally we set the reclassification confidence with a three-tier level system.  [https://github.com/SeqOne/clinvcf](https://github.com/SeqOne/clinvcf)
- **Variant Alert!** track every significant changes in variant classification and gene-disease association between two versions of ClinVCF VCFs, including their “breaking change” status defined according to the suspected clinical impact of these changes. A major  change is defined as a potential direct impact on clinical diagnosis. A minor  change is a change in confidence classification (e.g. Pathogenic to Likely Pathogenic status). [https://github.com/SeqOne/variant_alert](https://github.com/SeqOne/variant_alert)
- **ClinVarome** gathers and processes all ClinVar knowledge available through time. Through an unsupervised clustering model, it classifies clinical validity of information for each gene with a four-clusters system [https://github.com/SeqOne/clinvarome](https://github.com/SeqOne/clinvarome).

You can implement this framework with these three open source repositories.

### The webapp

If you prefer, this shiny app provides monthly updated results of Genome Alert!.  

You can download this results as a TSV file and explore the data through the app.

The code and description to process data and display the App is available here : [https://github.com/SeqOne/GenomeAlert-App](https://github.com/SeqOne/GenomeAlert-App).

### How to cite

If you use Genome Alert!, please cite : 

> Yauy et al. ClinVar follow-up for a systematic and automated genotype-phenotype associations re-assessment. Manuscript to be submitted (2021).


## Credits

Genome Alert! is a collaboration of the [Université Grenoble Alpes](https://iab.univ-grenoble-alpes.fr/?language=en), [SeqOne](https://seq.one/) and [CHU de Rouen](https://www.chu-rouen.fr/service/service-de-genetique/).


Legal notice (under French law) are available [here](./mentions_legales.html). 