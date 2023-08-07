# Function to filter annotated VCF with VEP to retain variants with AF < 0.10 in gnomAD, for
# a gene symbol being present and against a given list of transcripts

input_vcf="$1"
output_vcf="$2"
transcripts="$3"
transcripts_list=`cat $transcripts`

echo "transcripts: $transcripts_list"
filter_vep -i "$input_vcf" \
	-o "$output_vcf" --filter \
	$transcripts_list
	
	
annotated_vcf=$(find ./ -name "*_Haplotyper_annotated.vcf")
gzip "$annotated_vcf"
