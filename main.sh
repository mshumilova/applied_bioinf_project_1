##__________________________________________________________________________________________________________
##### add local configuration and input data links
##__________________________________________________________________________________________________________

##___local data
source config_local.sh

##___add input data links
source config_common.sh

##_________________________________________________________________________________________________________
##### 0. create initial working directories
##__________________________________________________________________________________________________________

mkdir $input_dir
mkdir $interm_dir
mkdir $output_dir

mkdir $ref_dir
mkdir $samp_dir
mkdir $cont_dir

##_________________________________________________________________________________________________________
##### 1. download reference and sample files to working directories
##__________________________________________________________________________________________________________

##___download the sample with a changed name
wget -c $raw_sample_link -O $samp_dir/$samp_ID.fastq.gz                       

##___download the reference from ncbi using entrez  
efetch -db nucleotide -id $ref_ID -format fasta > $ref_dir/$ref_ID.fasta 	 

##________________________________________________________________________________________________________
#### 2. alignment roommate's data on the reference sequence (bwa aligner)
##following code is without a cycle because we have only one sample
##_________________________________________________________________________________________________________

##___index the reference
bwa index $ref_dir/$ref_ID.fasta  

##___alignment___sam to bam format___sort___save sotred bam file 		                                
bwa mem $ref_dir/$ref_ID.fasta $samp_dir/$samp_ID.fastq.gz| samtools view -S -b -| samtools sort - -o $interm_dir/$samp_ID.bam
 
##___check the coverage
coverage_samp=$(samtools coverage $interm_dir/$samp_ID.bam| awk 'NR>1 {print $7}')  

##____________________________________________________________________________________________________________
##### 3. make vcf files for varscan (frequently 095 and rare 0001 variants)
##only one sample - I will inspect vcfs manualy) 
##____________________________________________________________________________________________________________

##___index the sample file
samtools index $interm_dir/$samp_ID.bam

##___make mpileup file___ make vcf file with frequently variants 095
samtools mpileup -d $coverage_samp -f $ref_dir/$ref_ID.fasta $interm_dir/$samp_ID.bam| java -jar $varscan mpileup2snp --min-var-freq 0.95 --variants --output-vcf 1> $output_dir/$samp_ID.095.vcf

##___make mpileup file___make vcf file with rare variants 0001
samtools mpileup -d $coverage_samp -f $ref_dir/$ref_ID.fasta $interm_dir/$samp_ID.bam| java -jar $varscan mpileup2snp --min-var-freq 0.001 --variants --output-vcf 1 > $output_dir/$samp_ID.0001.vcf

##________________________________________________________________________________________________________
##### 4. make tables with frequency of rare variants (position, reference, variant + frequency)
##going to work with the tables using R 
##_________________________________________________________________________________________________________

##___position,reference,variant
cat $output_dir/$samp_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5}'> $interm_dir/$samp_ID.rare_var.csv

##___frequency(impossible to choose only freq column)   
cat $output_dir/$samp_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5, $10}'| awk -F: '{print $7}' > $interm_dir/$samp_ID.rare_freq.csv  

##___R script (join two tables, tide data)
rscript join.R $interm_dir/$samp_ID.rare_var.csv $interm_dir/$samp_ID.rare_freq.csv $output_dir/$samp_ID.mate_rare_var_final.csv


##_________________________________________________________________________________________________________
##### 5. control data tables preparing (the same steps: download, alignment, vcf files, csv tables)
##_________________________________________________________________________________________________________


##___download
wget -c $cont1_link -O $cont_dir/$cont1_ID.fastq.gz
wget -c $cont2_link -O $cont_dir/$cont2_ID.fastq.gz
wget -c $cont3_link -O $cont_dir/$cont3_ID.fastq.gz

##___alignment
bwa mem $ref_dir/$ref_ID.fasta $cont_dir/$cont1_ID.fastq.gz| samtools view -S -b -| samtools sort - -o $interm_dir/$cont1_ID.cont1.bam
bwa mem $ref_dir/$ref_ID.fasta $cont_dir/$cont2_ID.fastq.gz| samtools view -S -b -| samtools sort - -o $interm_dir/$cont2_ID.cont2.bam
bwa mem $ref_dir/$ref_ID.fasta $cont_dir/$cont3_ID.fastq.gz| samtools view -S -b -| samtools sort - -o $interm_dir/$cont3_ID.cont3.bam

##___coverage
coverage_cont1=$(samtools coverage $interm_dir/$cont1_ID.cont1.bam| awk 'NR>1{print$7}')
coverage_cont2=$(samtools coverage $interm_dir/$cont2_ID.cont2.bam| awk 'NR>1{print$7}')
coverage_cont3=$(samtools coverage $interm_dir/$cont3_ID.cont3.bam| awk 'NR>1{print$7}')

##___make vcf files for varscan (rare variants 0001)
samtools index $interm_dir/$cont1_ID.cont1.bam
samtools index $interm_dir/$cont2_ID.cont2.bam
samtools index $interm_dir/$cont3_ID.cont3.bam

samtools mpileup -d $coverage_cont1 -f $ref_dir/$ref_ID.fasta $interm_dir/$cont1_ID.cont1.bam| java -jar $varscan mpileup2snp --min-var-freq 0.001 --variants --output-vcf 1 > $output_dir/$cont1_ID.0001.vcf
samtools mpileup -d $coverage_cont2 -f $ref_dir/$ref_ID.fasta $interm_dir/$cont2_ID.cont2.bam| java -jar $varscan mpileup2snp --min-var-freq 0.001 --variants --output-vcf 1 > $output_dir/$cont2_ID.0001.vcf
samtools mpileup -d $coverage_cont3 -f $ref_dir/$ref_ID.fasta $interm_dir/$cont3_ID.cont3.bam| java -jar $varscan mpileup2snp --min-var-freq 0.001 --variants --output-vcf 1 > $output_dir/$cont3_ID.0001.vcf

##___position,reference,variant
cat $output_dir/$cont1_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5}'> $interm_dir/$cont1_ID.cont1.rare_var.csv
cat $output_dir/$cont1_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5, $10}'| awk -F: '{print $7}' > $interm_dir/$cont1_ID.cont1.rare_freq.csv

rscript join.R $interm_dir/$cont1_ID.cont1.rare_var.csv $interm_dir/$cont1_ID.cont1.rare_freq.csv $output_dir/$cont1_ID.cont1_final.csv

cat $output_dir/$cont2_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5}'> $interm_dir/$cont2_ID.cont2.rare_var.csv
cat $output_dir/$cont2_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5, $10}'| awk -F: '{print $7}' > $interm_dir/$cont2_ID.cont2.rare_freq.csv

rscript join.R $interm_dir/$cont2_ID.cont2.rare_var.csv $interm_dir/$cont2_ID.cont2.rare_freq.csv $output_dir/$cont2_ID.cont2_final.csv

cat $output_dir/$cont3_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5}'> $interm_dir/$cont3_ID.cont3.rare_var.csv
cat $output_dir/$cont3_ID.0001.vcf| awk 'NR>24 {print $2, $4, $5, $10}'| awk -F: '{print $7}' > $interm_dir/$cont3_ID.cont3.rare_freq.csv

rscript join.R $interm_dir/$cont3_ID.cont3.rare_var.csv $interm_dir/$cont3_ID.cont3.rare_freq.csv $output_dir/$cont3_ID.cont3_final.csv

##______________________________________________________________________________________
##### 6. Final IDs (IDs of the variants with frequency more than 3 control sigma)
##_____________________________________________________________________________________

rscript sigma3.R $output_dir/$cont1_ID.cont1_final.csv $output_dir/$cont2_ID.cont2_final.csv $output_dir/$cont3_ID.cont3_final.csv $output_dir/$samp_ID.mate_rare_var_final.csv


