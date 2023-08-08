process athena {
    debug true
    tag "${reads[0].toString().split("-")[0]},${reads[1].toString().split("-")[0]},${reads[2].toString().split("-")[0]}"
    publishDir params.outdir3, mode:'copy'

    input:
    path exons
    path(reads)
    val threshold
    val cutoff_threshold
    val panel
    val limit
    path static_bedtools
    val summary

    output:
    
    path "athena*/output/*"
    
    """
    echo "Running ${reads[0]} ${reads[1]} ${reads[2]}"
    bash nextflow-bin/eggd_athena.sh ${reads[1].toString().split("\\_")[0]} ${reads[0]} $exons ${reads[1]}  ${reads[2]} "${threshold}" $cutoff_threshold $panel $limit $summary
    
    """

}
