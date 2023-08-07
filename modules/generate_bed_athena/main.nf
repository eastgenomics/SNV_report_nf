process generate_bed_athena {
    tag "$sample_file"
    debug true
    publishDir params.outdir1, mode:'copy'
    
    input:
    
    val sample_file
    path manifest
    path gene_panels
    path exons_nirvana
    path nirvana_genes2transcripts
    
        
    output:
    
    path "*-R*.bed", emit:athena_bed_file

    script:
    
    """
    echo "Running $sample_file"
    bash nextflow-bin/generate_bed.sh ${sample_file} ${manifest} ${gene_panels} ${exons_nirvana} ${nirvana_genes2transcripts} ""
    
    """

}

