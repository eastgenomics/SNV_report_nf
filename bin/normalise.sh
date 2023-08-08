# Normalise variants, if applicable
# Normalisation is a default option for this app, should only be changed
# when running for non-SNV vcfs.

normalise="$1"
filtered_vcf="$2"
ref_bcftools="$3"
prefix="$(basename -- $filtered_vcf .vcf)"	
tar zxvf $ref_bcftools
chmod -R 777 nextflow-bin/bcftools-1.18
if [[ "$normalise" == true ]]; 
	then
		nextflow-bin/bcftools-1.18/bcftools norm -f genome.fa -m -any --keep-sum AD  "$filtered_vcf" -o "${prefix}_post_filtering.vcf"

	else
		echo "No normalisation was applied"
		mv "$filtered_vcf" "${prefix}_post_filtering.vcf"
	fi


