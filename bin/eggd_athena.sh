#!/bin/bash
# eggd_athena
name="$1"
panel_bed_name="$2"
exons_file_name="$3"
pb_bed="$4"
build="$5"
thresholds="$6"
cutoff_threshold="$7"
panel="$8"
limit="$9"
summary="${10}"
set -exo pipefail
   
tar -xf nextflow-bin/athena-1.5.0.tar.gz

# if sample naming given replace spaces with "_" and "/" with "-"
if [ "$name" ]; then name=${name// /_}; fi
if [ "$name" ]; then name=${name//\//-}; fi

echo $name
# build string of args and annotate bed file
annotate_args="--chunk_size 20000000 --panel_bed $panel_bed_name --transcript_file $exons_file_name --coverage_file $pb_bed"
if [ "$name" ]; then annotate_args+=" --output_name $name"; fi
echo "Performing bed file annotation with following arguments: " $annotate_args

athena_dir=$(find -type d -name "athena*")
echo $athena_dir
time python3 $athena_dir/bin/annotate_bed.py $annotate_args

annotated_bed=$(find ${athena_dir}/output/ -name "*_annotated.bed")

# build string of inputs to pass to stats script
stats_args=""

if [ "$thresholds" ]; then stats_args+=" --thresholds $thresholds"; fi
if [ "$build_name" ]; then stats_args+=" --build $build"; fi
if [ "$name" ]; then stats_args+=" --outfile ${name}"; fi

stats_cmd="--file $annotated_bed"
stats_cmd+=$stats_args
echo "Generating coverage stats with: " $stats_cmd

time python3 $athena_dir/bin/coverage_stats_single.py $stats_cmd

exon_stats=$(find ${athena_dir}/output/ -name "*exon_stats.tsv")
gene_stats=$(find ${athena_dir}/output/ -name "*gene_stats.tsv")

# build string of inputs for report script
report_args=""

if [ "$cutoff_threshold" ]; then report_args+=" --threshold $cutoff_threshold"; fi
if [ "$name" ]; then report_args+=" --sample_name $name"; fi
if [ "$panel" = true ]; then report_args+=" --panel $panel_bed_name"; fi
if [ "$panel_filters" ]; then report_args+=" --panel_filters ${panel_filters} "; fi
if [ "$summary" = true ]; then report_args+=" --summary"; fi
if [ "${!snps[@]}" ]; then
    snp_vcfs=$(find ~/snps/ -name "*.vcf*")
    echo $snp_vcfs
    report_args+=" --snps $snp_vcfs";
fi

shopt -s nocasematch
if [[ "$per_chromosome_coverage" == "true" ]]; then report_args+=" --per_base_coverage $pb_bed"; fi

report_cmd="$athena_dir/bin/coverage_report_single.py --exon_stats $exon_stats --gene_stats $gene_stats --raw_coverage $annotated_bed --limit $limit"
report_cmd+=$report_args
echo "Generating report with: " $report_cmd

# generate report
time python3 $report_cmd
report=$(find ${athena_dir}/output/ -name "*coverage_report.html")

# compress annotated bed since it can be large
gzip "$annotated_bed"

