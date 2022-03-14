# Project 2 "Why did I get the flu?"

Based on the course "Applied Bioinformatics" by Mike Rayko, 2020
________________________________________________________________________

### Purpose of the project:

To find out a reason of the flu vaccine inefficiency
________________________________________________________________________

### Initial data (added in "config_common", no need to download separately):

1. "Sample": Single-end sequence data of the influenza hemagglutinin gene (SRR1705851)
2. "Reference": The reference sequence for the influenza hemagglutinin gene (NCBI ID number: KF848938.1) 
3. "Controls": 3 controls -  isogenic viral sample of the reference H3N2 influenza virus, PCR amplified, subcloned into a plasmid and sequenced three times on an Illumina machine (SRR1705858, SRR1705859, SRR1705860)
________________________________________________________________________

### Logical steps of the project:

1. Inspect sample data
2. Align sample to the reference sequence
3. Look for common variants with VarScan (vcf files will be stored in "output_dir" folder)
4. Look for rare variants with VarScan
5. Inspect and align the control sequencing data
6. Use VarScan to look for rare variants in the reference files
7. Compare the control results to the sample results
8. Epitope mapping

* for technical details you may open "main.sh" file to find the comments 
________________________________________________________________________

### How to use the script:

1. Open the file "config_local_template.sh"
2. Add your local paths
3. Save the file as "config_local.sh" 
4. Run "main.sh" file 
5. As a result you will get IDs of the viral variants with frequency greater than 3 standard deviations from reference errore rate

Use the article (Munoz et al) to determine if any of the high confidence mutations are located in an epitope region of hemagglutinin 
_________________________________________________________________________
