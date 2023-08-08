#functions to get transcript list from bed file

panel_bed="$1"
prefix="$(basename -- $panel_bed .bed)" 
cut -f 4 $panel_bed | sort | uniq |cut -d '.' -f 1 > transcripts.tsv
transcripts=$(cut -f 4 $panel_bed | sort | uniq |cut -d '.' -f 1)

set +x
transcript_list=$(for tr in $transcripts;do echo -n "Feature match $tr\. or ";done)
final_transcript_list=${transcript_list%????}
echo $final_transcript_list>${prefix}_transcripts.txt
set -x
