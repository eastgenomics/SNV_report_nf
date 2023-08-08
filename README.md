# SNV_report_nf
`SNV_report_nf` workflow is to run after `dias_nextflow`. The workflow requires output files from Sentieon and Mosdepth processes from `dias_nextflow` as well as epic_menifest file downloaded from EPIC to get the Rcode for each samples.
 
The workflow has the processes to 
- generate bed file for Vep
- generate bed file for Athena
- run Vep tool
- run Athena tool
- generate variant workbook from annotated vcf

### Tools and version used in the workflow
- athena-1.5.0.tar.gz
- bedtools.static.binary.gz from eggd_athena [(v1.5.0)](https://github.com/eastgenomics/eggd_athena/releases)
- bcftools-1.18
- bedtools-2.29.1
- generate_variant_book [(v2.4.0)](https://github.com/eastgenomics/eggd_generate_variant_workbook/releases)

### nextflow.config
Contains all nextflow parameters used in different processes
### main.nf
Calls the modules and runs workflows
### nextflow_schema.json
Defines the parameter type
### modules
Contains modules for all processes 
### bin folder
Contains all the source codes/tools
### inputs.json
This file contains parameters which are defined as DNAnexus parameters and is required to run the nextflow applet. It is not required for building applet.
NOTE: `nextflow_pipeline_params` in `inputs.json` file is default to project with test samples;therefore, need to change the respective dir for each run. 

### To build dias_nextflow on DNAnexus
```
 git clone <repo>
 dx select <DNAnexus project>
 dx build --nextflow (inside the cloned folder)
 ```
 
 ### To run the built dias_nextflow applet on DNAnexus 
```
dx run applet-xxxx \
-f /local/path/to/json/file/inputs.json
```
![Image of workflow](workflow.png)
