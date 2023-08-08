process filter_b4_annotation{

 debug true
 //publishDir params.outdir2, mode:'copy'
 tag "${reads[0].toString().split("-")[0]} ${reads[1].toString().split("-")[0]}"
 input:
 path(reads)

 
 output:
 path "*_filtered.vcf", emit:filtered_vcf
 
 """
 #!/bin/bash 
 set -euxo pipefail
 echo "Running ${reads[0]} ${reads[1]}"
 nextflow-bin/filter_vcf.sh ${reads[1]} ${reads[0]}
 """

}
