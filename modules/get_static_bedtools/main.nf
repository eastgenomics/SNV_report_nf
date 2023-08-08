process get_static_bedtools {
    debug true
    //publishDir params.outdir1, mode:'copy'

    output:
    
    path "bedtools", emit:static_bedtool
    
    """
     gzip -d -k --force nextflow-bin/bedtools.static.binary.gz
     mv nextflow-bin/bedtools.static.binary bedtools
     chmod a+x bedtools
    """

} 
