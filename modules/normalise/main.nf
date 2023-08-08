process normalise{

 debug true
 //publishDir params.outdir2, mode:'copy'
 tag "$filtered_vcf"
 
 input:
 path filtered_vcf
 path ref_bcftools
 
 
 output:
 path "*_filtered_post_filtering.vcf", emit:post_filtering_vcf
 
 """
 #!/bin/bash 
 set -euxo pipefail
 echo "Running $filtered_vcf"
 bash nextflow-bin/normalise.sh "true" $filtered_vcf $ref_bcftools
 """

}
