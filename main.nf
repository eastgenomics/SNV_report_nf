nextflow.enable.dsl=2

// -------------------------------------
// INCLUDE MODULES
// -------------------------------------

include { getting_panel_for_bed } from './modules/getting_panel_for_bed'
include { generate_bed } from './modules/generate_bed'
include { generate_bed_athena } from './modules/generate_bed_athena'
include { get_static_bedtools } from './modules/get_static_bedtools'
include { athena } from './modules/athena'
include { filter_b4_annotation } from './modules/filter_b4_annotation'
include { normalise } from './modules/normalise'
include { vep } from './modules/vep'
include { generate_transcript } from './modules/generate_transcript'
include { filter_after_annotation } from './modules/filter_after_annotation'
include { generate_variannt_workbook } from './modules/generate_variannt_workbook'


// -------------------------------------
// RUNNING WORKFLOWS
// -------------------------------------

workflow {

//generate bed files

getting_panel_for_bed(params.epic_menifest,params.gene_panels)
sample_file_ch=Channel.fromPath(params.sample_file, checkIfExists:true)
                           .map { file_path -> file_path.getSimpleName()}
                           .view()
generate_bed(sample_file_ch,getting_panel_for_bed.out.menifest_file,params.gene_panels,params.exons_nirvana,params.nirvana_genes2transcripts,params.flank)

//running vep 

vcf_ch=Channel.fromPath(params.sample_file)  
vep_bed_file_ch=generate_bed.out.vep_bed_file

vcf_ch.view()
vep_bed_file_ch.view()
    
vcf_ch
   .map { [it.toString().split("-")[0].split("/")[2],
      it] }
   .set { vcf_ch }
   
vep_bed_file_ch
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { vep_bed_file_ch }
   
vcf_ch
    .combine(vep_bed_file_ch, by: 0)
    .map { id, vcf, vep_bed -> [vcf, vep_bed] }
    .view()


filter_b4_annotation(vcf_ch
    .combine(vep_bed_file_ch, by: 0)
    .map { id, vcf, vep_bed -> [vcf, vep_bed] })
    
normalise(filter_b4_annotation.out.filtered_vcf,params.ref_bcftools)


vep(normalise.out.post_filtering_vcf,params.fasta,params.cache_file,params.clinvar,params.clinvar_index,params.clinvar_custom_str,params.hgmd,params.hgmd_index,params.hgmd_custom_str,params.gnomADg,params.gnomADg_index,params.gnomADg_custom_str,params.gnomADe,params.gnomADe_index,params.gnomADe_custom_str,params.twe,params.twe_index,params.twe_custom_str,
params.plugin_dir, params.spliceAI_snv,params.spliceAI_snv_index,params.spliceAI_indel,params.spliceAI_indel_index,params.ravel,params.ravel_index,params.cadd_snv,params.cadd_snv_index,params.cadd_gnomad_genome,params.cadd_gnomad_genome_index,params.cadd_indel37,params.cadd_indel37_index,params.field_str,params.buffer_size,params.cache_version)

generate_transcript(generate_bed.out.vep_bed_file)

vcf_ch1=vep.out.temp_vcf
transcript_ch=generate_transcript.out.transcript

vcf_ch1.view()
transcript_ch.view()

vcf_ch1
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { vcf_ch1 }
   
transcript_ch
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { transcript_ch }
   
vcf_ch1
    .combine(transcript_ch, by: 0)
    .map { id, vcf, transcript -> [vcf, transcript] }
    .view()


filter_after_annotation(vcf_ch1
    .combine(transcript_ch, by: 0)
    .map { id, vcf, transcript -> [vcf, transcript] })
    
    
//running athena  
  
generate_bed_athena(sample_file_ch,getting_panel_for_bed.out.menifest_file,params.gene_panels,params.exons_nirvana,params.nirvana_genes2transcripts)
    
get_static_bedtools()
    
ch_bed=generate_bed_athena.out.athena_bed_file
ch_pb_bed=Channel.fromPath(params.pb_bed)
ch_build=Channel.fromPath(params.build)
    
ch_bed.view()
ch_pb_bed.view()
ch_build.view()
 
    
ch_bed
  .map { [it.toString().split("-")[0].split("/")[4],
      it] }
  .set { ch_bed }
      
ch_pb_bed
 .map { [it.toString().split("-")[0].split("/")[2],
      it] }
 .set { ch_pb_bed }
     
ch_build
 .map { [it.toString().split("-")[0].split("/")[2],
      it] }
 .set { ch_build }
     
ch_bed
  .combine(ch_pb_bed, by: 0)
  .combine(ch_build, by: 0)    
  .map { id, athena_bed, pd_bed,build -> [athena_bed, pd_bed,build] }
  .view()
    
athena(params.exons_file_name,ch_bed.combine(ch_pb_bed,by: 0).combine(ch_build, by: 0).map { id, athena_bed, pd_bed,build -> [athena_bed, pd_bed,build] },params.ath_threshold,params.cutoff_threshold,params.ath_panel,params.ath_limit,get_static_bedtools.out.static_bedtool,params.summary)
    
//generate variant workbook
generate_variannt_workbook(filter_after_annotation.out.vep_annotated_vcf,params.exclude_columns,params.acmg,params.rename_columns,params.add_comment_column,
params.keep_tmp,params.reorder_columns,params.human_filter,params.summary,params.keep_filtered,getting_panel_for_bed.out.menifest_file)
    
   
}




