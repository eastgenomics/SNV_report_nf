process filter_after_annotation{

 debug true
 publishDir params.outdir2, mode:'copy'
 tag "${reads[0].toString().split("-")[0]} ${reads[1].toString().split("-")[0]}"
 
 input:
 path(reads)
 //path transcript
 //path transcript_list
 output:
 path "${reads[0].toString().split("\\_filtered")[0]}_annotated.vcf.gz" , emit:vep_annotated_vcf
 
 """
 #!/bin/bash 
 set -euxo pipefail
 echo "Running ${reads[0]} ${reads[1]}"
 bash nextflow-bin/filter_vep_vcf.sh ${reads[0]} "${reads[0].toString().split("\\_filtered")[0]}_annotated.vcf" ${reads[1]}
 """

}
