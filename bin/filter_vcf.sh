# Filter by panel if provided (before annotation of vcf by vep)

panel_bed="$1"
vcf_path="$2"
prefix="$(basename -- $vcf_path .vcf.gz)"
chmod -R 777 nextflow-bin/bcftools-1.18
	
if [ "$panel_bed" ];
then
	# Create a new header to add the bedtools intersect command with the panel name
	nextflow-bin/bcftools-1.18/bcftools view -h "${vcf_path}" | head -n -3 > header.txt
	echo '##bedtools_command=nextflow-bin/bedtools intersect' "$vcf_path" "$panel_bed" >> header.txt
	nextflow-bin/bcftools-1.18/bcftools view -h "${vcf_path}" | tail -n 1 >> header.txt

	# Intersect with panel, normalise and reheader
	nextflow-bin/bedtools intersect -header -u -a "$vcf_path" -b "$panel_bed" \
		| nextflow-bin/bcftools-1.18/bcftools reheader -h header.txt -o "${prefix}_filtered.vcf"

else
	echo "No filtering was applied"
	mv "${vcf_path}" "${prefix}_filtered.vcf"
fi

		
		

