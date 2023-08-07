process generate_variannt_workbook{

  debug true
  tag "$vcf"
  publishDir params.outdir1, mode:'copy'
  
  input:
  path vcf
  val exclude_columns
  val acmg
  val rename_columns
  val add_comment_column
  val keep_tmp
  val reorder_columns
  val human_filter
  val summary
  val keep_filtered
  path menifest
  
  output:
  path "*{.split.vcf.gz,filter.vcf.gz}"
  path "*xlsx"
  
  
  
  """
    echo "Running $vcf"
    parent_job_id=$DX_JOB_ID
    echo "parent job id: \$parent_job_id"
    
    sub_job_id=\$DX_JOB_ID
    echo "sub job id: \$sub_job_id"
    
    bash nextflow-bin/code_workbook.sh $vcf $menifest "${vcf.toString().split("-")[0]}" "$exclude_columns" "$acmg" \\
  "$rename_columns" "$add_comment_column" $keep_tmp "$reorder_columns" "$human_filter" "${vcf.toString().split("_")[0]}" "$summary" "\$sub_job_id" "\$parent_job_id" $keep_filtered 
   
  """

}
