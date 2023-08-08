process getting_panel_for_bed {
    
    debug true
    publishDir params.outdir1, mode:'copy'
    
    input:
        
    path epic_menifest
    path gene_panels

        
    output:
    
    path "menifest_file.csv", emit:menifest_file

    script:
    
    """
    
    python nextflow-bin/getting_panel_for_bed_nextflow.py $epic_menifest $gene_panels  
    
    """

}


