import pandas as pd
import numpy as np
import sys
#read in txt file downloaded from EPIC
epic_menifest_file = sys.argv[1]
gene_panel_file = sys.argv[2]

epic_df=pd.read_csv(epic_menifest_file, sep=";",header=1) #"epic-manifest-198.txt"
#replace the specimen ID and instrument ID with reanlysis ID if present
epic_df['Specimen ID'] = np.where(~epic_df['Re-analysis Specimen ID'].isnull(), epic_df['Re-analysis Specimen ID'], epic_df['Specimen ID'])
epic_df['Instrument ID'] = np.where(~epic_df['Re-analysis Instrument ID'].isnull(), epic_df['Re-analysis Instrument ID'], epic_df['Instrument ID'])

#read in most updated genepanel file to look up
panel_df=pd.read_csv(gene_panel_file, sep="\t",names=["Rcode_panel","panel","HGNC"]) #"230602_genepanels.tsv"
#splitting R code and panel name
panel_df['Rcode']=panel_df['Rcode_panel'].str.split('_').str[0]
panel_df['panel_name']=panel_df['Rcode_panel'].str.split('_').str[1]
panel_df['PG']=panel_df['Rcode_panel'].str.split('_').str[2]
#spitting the string of Test Codes
epic_df['Test_Codes_list'] = epic_df['Test Codes'].str.split(',')

#getting the panel name base on Rcode for each sample
d=[]
for i in range (0,epic_df.shape[0]): #i is looping sample
    Rcode_list = list(epic_df['Test_Codes_list'][i]) 
    clean_Rcode = [x for x in Rcode_list if "R" in x] #remove empty
    print('sample:',epic_df["Specimen ID"][i])
    panel_names=""
    rcode_prefix=""
    panel_workbook=""
    for j in range (0,len(clean_Rcode)): #j is looping R code 
        
        temp_df=panel_df.iloc[panel_df.index[panel_df['Rcode'] == clean_Rcode[j].strip()]]
        panel_name=temp_df["Rcode"].unique()[0]+"_"+temp_df["panel_name"].unique()[0]+"_"+temp_df["PG"].unique()[0]
        rcode_pre=temp_df["Rcode"].unique()[0]
        panel_wb=temp_df['panel'].unique()[0]
        if len(clean_Rcode)==1:
            panel_names=panel_name
            rcode_prefix=rcode_pre
            panel_workbook=panel_wb
        elif len(clean_Rcode)>1 and j==0:
            panel_names=panel_name
            rcode_prefix=rcode_pre
            panel_workbook=panel_wb
        else:
            panel_names=panel_names+";"+panel_name
            rcode_prefix=rcode_prefix+"_"+rcode_pre
            panel_workbook=panel_workbook+"_"+panel_wb
    print(panel_names)
   
    d.append(
            {
                #'Specimen_ID': str(epic_df["Specimen ID"][i]),
                'Instrument_ID':str(epic_df["Instrument ID"][i]),
                #'Prefix':str(epic_df["Instrument ID"][i])+"_"+str(epic_df["Specimen ID"][i]),
                'Rcode_panel_name':panel_names,
                'Rcode_prefix':rcode_prefix,
                'panel_workbook':panel_workbook
            }  )
#create df and save in csv            
df=pd.DataFrame(d)
df.to_csv('menifest_file.csv',index=False,header=False)
