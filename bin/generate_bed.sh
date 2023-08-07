#!/bin/bash

sample_file_name="$1" 
manifest_name="$2"
gene_panels_name="$3"
exons_nirvana_name="$4"
nirvana_genes2transcripts_name="$5"
flank="$6"

set -exo pipefail

sample=$(grep -oP "^[a-zA-Z0-9]*" <<< "$sample_file_name")
echo $sample
# Check if the sample is present in the manifest
if ! grep -q $sample "$manifest_name"; then
    echo "Sample ${sample} was not found in the manifest ~/${manifest_name}"
    exit 1
fi

panel=$(grep -w $sample "$manifest_name" | cut -d , -f2)
prefix_rcode=$(grep -w $sample "$manifest_name" | cut -d , -f3)

echo "Sample ID used: $sample"
echo "Using panel(s): $panel"
    
panel_prefix=${panel%%_*}
prefix=$(echo ${sample}-${prefix_rcode})
echo "prefix=$prefix"
    
# build optional args string for output prefix and flank
optional_args=""

if [[ ! -z ${flank} ]]; then optional_args+=" -f $flank"; fi

if [[ ! -z ${flank} ]]; then prefix=$(echo ${prefix}_"bp_"${flank}); fi
    
# generate bed file
if [[ ! -z ${optional_args} ]]; then
    python3 nextflow-bin/generate_bed.py -p "$panel" -e "$exons_nirvana_name" -g "$gene_panels_name" -t "$nirvana_genes2transcripts_name" $optional_args -o "${sample}"
    echo "python 1"
else
    python3 nextflow-bin/generate_bed.py -p "$panel" -e "$exons_nirvana_name" -g "$gene_panels_name" -t "$nirvana_genes2transcripts_name" -o "${sample}"
    echo "python 2"
fi

bed_file=$(find . -name "*37*.bed" -o -name "*38*.bed")

# check if bed file is empty, exit if so
if [[ ! -s $bed_file ]];then
    echo "Error: empty bed file generated"
        
else
    sort -k1,1V -k2,2n $bed_file | tee "${prefix}.bed" > /dev/null
    echo "done"
fi

    

