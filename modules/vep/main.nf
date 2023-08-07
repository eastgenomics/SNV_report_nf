process vep {
    tag "$post_filtering_vcf"
    debug true
    //publishDir params.outdir2, mode:'copy'
    
    input:

    path post_filtering_vcf
    path fasta
    path cache_dir
   
    path clinvar
    path clinvar_index
    val clinvar_custom_str
    
    path hgmd
    path hgmd_index
    val hgmd_custom_str
    
    path gnomADg
    path gnomADg_index
    val gnomADg_custom_str
    
    path gnomADe
    path gnomADe_index
    val gnomADe_custom_str
    
    path twe
    path twe_index
    val twe_custom_str
    
    path plugin_dir
    path spliceAI_snv
    path spliceAI_snv_index
    path spliceAI_indel
    path spliceAI_indel_index
    
    path ravel
    path ravel_index
    path cadd_snv
    path cadd_snv_index
    path cadd_gnomad_genome
    path cadd_gnomad_genome_index
    path cadd_indel37
    path cadd_indel37_index
    
    val field_str
    val buffer_size
    val cache_version
    
    output:
    
    path "*_temp_annotated.vcf" , emit:temp_vcf
    
    
    """
   #!/bin/bash 
   set -euxo pipefail
   echo "Running $post_filtering_vcf"
   mkdir "cache_file_folder"
   tar xf $cache_dir -C cache_file_folder
   
    vep --cache --cache_version $cache_version --dir_cache cache_file_folder \
      -i $post_filtering_vcf --format vcf -o ${post_filtering_vcf.getBaseName()}_temp_annotated.vcf \
      --vcf --no_stats --fasta $fasta \
      --offline --refseq --exclude_predicted --symbol --hgvs --check_existing --variant_class --numbers --exclude_null_alleles --force_overwrite \
      --assembly GRCh37 \
      --custom $clinvar,$clinvar_custom_str \
      --custom $hgmd,$hgmd_custom_str \
      --custom $gnomADg,$gnomADg_custom_str \
      --custom $gnomADe,$gnomADe_custom_str \
      --custom $twe,$twe_custom_str \
      --dir_plugins $plugin_dir \
      --plugin SpliceAI,snv=$spliceAI_snv,indel=$spliceAI_indel \
      --plugin REVEL,$ravel \
      --plugin CADD,$cadd_snv,$cadd_gnomad_genome,$cadd_indel37 --fields "$field_str" \
      --buffer_size $buffer_size \
      --fork \$(grep -c ^processor /proc/cpuinfo) \
      --compress_output bgzip --shift_3prime 1

    """
}

