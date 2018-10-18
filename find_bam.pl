
#Edit: October 18th, 2018
#Reyka Jayasinghe (reyka@wustl.edu)
#A very unelegant script to extract tumor and normal bams for mutations of interest for use in running bamreadcount analysis on google cloud.
#currently does not work for indels and is written with the input in misplice "annotation like format"

#Input ANNOTATION file:
#3_120321053_A_G	TCGA-AB-3472
#17_40714372_A_G	TCGA-EA-A292
#20_3785604_A_G	TCGA-ET-AAE3_T,TCGA-DP-ATJC_T,TCGA-DD-AAAN_T,TCGA-AA-ADDD_T

#Input BAM file
#UUID_1	TCGA_Barcode	UUID_2	GS_Path	File_Size
#191c5e31-2f32-4737-a59e-c9b1bfaafd67	TCGA-A6-6782-10A-01D-1835-10	2df2e3c3-ea94-4953-919f-bc556bdf0808	gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/COAD/DNA/WXS/BCM/ILLUMINA/TCGA-A6-6782-10A-01D-1835-10_hg19_Illumina.bam	12394088167

#Output file
#1       gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/BRCA/DNA/WXS/BI/ILLUMINA/TCGA_MC3.Sample3.bam       19:45854542-45854542    bamsite_1.yaml
#2       gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/BRCA/DNA/WXS/BI/ILLUMINA/TCGA_MC3.Sample2.bam       19:45854542-45854542    bamsite_2.yaml
#3       gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/BRCA/DNA/WXS/BI/ILLUMINA/TCGA_MC3.Sample1.bam       19:45854542-45854542    bamsite_3.yaml


open(my $bamlist,'<',"../GCS_listing.02jun2016.noRNAVALIDATION.tsv") or die "Can't open BAMFILE!\n";

my %bamhash;
my %bamhashnormal;
my %samplelookup;
my @tumormc3list;
my @normalmc3list;


#Store bams in hash
while(my $bamline=<$bamlist>){
	chomp $bamline;
	my @baminfo=split(/\t/,$bamline);
	my $bsample=$baminfo[1];
	my $sn=substr($bsample,0,12);
	my $bam = $baminfo[3];
#Normal Tissue Samples
	if ($bsample=~/TCGA-\w{2}-\w{4}-1.*/){
		$samplelookup{$bam}=$bsample;
		if ($bam=~/TCGA_MC3/){
			push @normalmc3list,$sn;
		}
		if (exists $bamhashnormal{$sn}){
			push @{$bamhashnormal{$sn}},$bam;
		}
		else{
			$bamhashnormal{$sn}[0]=$bam;
		}
	}
#Tumor Tissue Samples
	if ($bsample=~/TCGA-\w{2}-\w{4}-0.*/){
		$samplelookup{$bam}=$bsample;
		if ($bam=~/TCGA_MC3/){
			push @tumormc3list,$sn;
		}
		
		if (exists $bamhash{$sn}){
			push @{$bamhash{$sn}},$bam;	
		}
		else{
			$bamhash{$sn}[0]=$bam;
		}
	}
}
close $bamlist;

#Example Anno file
#3_56655621_-_AGAG	TCGA-22-2222
#3_56655621_-_AGAG	TCGA-E2-2222_T,TCGA-22-A222_T

open(my $anno,'<',$ARGV[0]) or die "Can't open Annotation File!\n";

my $entry=0;

while (my $line=<$anno>){
	chomp $line;
	my @array=split(/\t/,$line);
	my $sample=$array[1];
	my @newsite=split(/_/,$array[0]);
	my $site="$newsite[0]:$newsite[1]-$newsite[1]";
	my @samples=split(/,/,$sample);
	foreach my $s (@samples){
		my $snshort=substr($s,0,12);
		my @bams=@{$bamhash{$snshort}};
		my @bamsnormal=@{$bamhashnormal{$snshort}};
		if (scalar @bams > 1){
			foreach my $b (@bams){
				if ( $snshort ~~ @tumormc3list ){ 
					if ($b=~/TCGA_MC3/){
						$entry++;
						print "$entry\t$b\t$site\tbamsite_$entry.yaml\n";
						next;
					}
				}
				else{
					$entry++;
					print "$entry\t$b\t$site\tbamsite_$entry.yaml\n";
					next;
				}
			}
		}
		else{
			$entry++;
			my $bamstring = join '\t',@bams;
			print "$entry\t$bamstring\t$site\tbamsite_$entry.yaml\n";
		}
		if (scalar @bamsnormal >1){
			foreach my $c (@bamsnormal){
				if ( $snshort ~~ @normalmc3list ){
					if ($c=~/TCGA_MC3/){
						$entry++;
						print "$entry\t$c\t$site\tbamsite_$entry.yaml\n";
						next;
					}
				}
				else{
					$entry++;
					print "$entry\t$c\t$site\tbamsite_$entry.yaml\n";
					next;
				}
			}
		}
		else{
			$entry++;
			my $bamstringn = join '\t',@bamsnormal;
			print "$entry\t$bamstringn\t$site\tbamsite_$entry.yaml\n";
		}
	}
}

