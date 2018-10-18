# Bamreadcount analysis on Gcloud

This pipeline will help you to generate necessary files to run bamreadcount on the google cloud api.

Many scripts below were developed by wen-wei liang (wenwiliang@gmail.com)

## Generate input data based on mutations and sample names

Make sure you have a bamlist and annotation file

### Input ANNOTATION file

 * 3_120321053_A_G        TCGA-AB-3472
 * 17_40714372_A_G        TCGA-EA-A292
 * 20_3785604_A_G TCGA-ET-AAE3_T,TCGA-DP-ATJC_T,TCGA-DD-AAAN_T,TCGA-AA-ADDD_T

### Input BAM file

bamlist is indicated in (find_bam.pl script)

 * UUID_1 TCGA_Barcode    UUID_2  GS_Path File_Size
 * 191c5e31-2f32-4737-a59e-c9b1bfaafd67   TCGA-A6-6782-10A-01D-1835-10    2df2e3c3-ea94-4953-919f-bc556bdf0808    gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/COAD/DNA/WXS/BCM/ILLUMINA/TCGA-A6-6782-10A-01D-1835-10_hg19_Illumina.bam 12394088167

### Output file

 * 1       gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/BRCA/DNA/WXS/BI/ILLUMINA/TCGA_MC3.Sample3.bam       19:45854542-45854542    bamsite_1.yaml
 * 2       gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/BRCA/DNA/WXS/BI/ILLUMINA/TCGA_MC3.Sample2.bam       19:45854542-45854542    bamsite_2.yaml
 * 3       gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/BRCA/DNA/WXS/BI/ILLUMINA/TCGA_MC3.Sample1.bam       19:45854542-45854542    bamsite_3.yaml

``
perl find_bam.pl anno > bamsite_index.txt
``

## Make output folder

``
mkdir run
``

## Generate gcloud command for each entry in bamsite_index.txt

Within this script you will need to update to your gcloud output folders, reference file location etc.

``
bash generate_gcloud_command.sh
``

## Generate yaml file for each mutation

May need to update docker repository

``
bash generate_yaml.sh
``

## Test

Before running gcloud command make sure all google cloud sdk's are up to date.

Test run one entry in run/gcloudcommand.sh

``
head -n2 run/gcloudcommand.sh |bash
``

## Check jobs on gcloud:

After job is submitted you will be returned with an operations code that can be used to extract information on the job.

``
gcloud alpha genomics operations describe operations/EJrOsaroLBio8pTLzYSV_VYggsbm6-geKg9wcm9kdWN0aW9uUXVldWU|grep -E '(done:|bamfile:)'
``
