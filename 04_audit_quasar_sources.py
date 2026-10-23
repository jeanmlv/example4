"""Offline audit of Thea.View QUASAR inventory; does not call API or modify source files.
Usage: python 04_audit_quasar_sources.py --input 'video_inventory_output/all_video_inventory.csv'
"""
import argparse
from pathlib import Path
import pandas as pd

p=argparse.ArgumentParser();p.add_argument('--input',required=True);p.add_argument('--output-dir',default='quasar_source_audit');a=p.parse_args()
out=Path(a.output_dir);out.mkdir(parents=True,exist_ok=True)
d=pd.read_csv(a.input,dtype=str,keep_default_na=False)
d=d[d['study'].str.contains('QUASAR',case=False,na=False)].copy()
if d.empty: raise SystemExit('No QUASAR records in input.')
required={'data_type','video_class','batch','item_id','folder_id','extension','relative_path','site','patient_id','visit','filename'}
if required-set(d.columns):raise SystemExit('Missing columns: '+str(required-set(d.columns)))
summary=d.groupby(['data_type','video_class','extension'],dropna=False).agg(video_file_items=('item_id','size'),distinct_item_ids=('item_id','nunique')).reset_index()
summary.to_csv(out/'01_inventory_by_source_class.csv',index=False)
batch=d.groupby(['batch','data_type']).size().unstack(fill_value=0).reindex(columns=['rawdata','processed'],fill_value=0).reset_index()
batch['processed_minus_raw']=batch['processed']-batch['rawdata'];batch=batch.sort_values('processed_minus_raw',ascending=False)
batch.to_csv(out/'02_batch_comparison.csv',index=False)
# Normalize only straightforward filenames, do not claim clinical-level deduplication.
def stem(v):
 v=str(v).casefold().strip()
 if v.endswith('.transcoded.mp4'): return v[:-len('.transcoded.mp4')]
 for ext in ['.avi','.mp4','.wmv','.mov','.mkv','.mpeg','.mpg','.m4v','.webm']:
  if v.endswith(ext):return v[:-len(ext)]
 return v
x=d.copy();x['normalized_filename']=x.filename.map(stem)
keys=['site','patient_id','visit','normalized_filename']
r=set(map(tuple,x.loc[x.data_type=='rawdata',keys].drop_duplicates().to_numpy()))
pr=x.loc[x.data_type=='processed',keys].drop_duplicates().copy()
pr['matching_raw_filename_key']=list(map(lambda k: k in r,map(tuple,pr[keys].to_numpy())))
pr.groupby('matching_raw_filename_key').size().rename('processed_filename_keys').to_csv(out/'03_processed_filename_match_counts.csv')
# Summaries only; no patient identifiers or paths written to outputs.
lines=['QUASAR offline source audit','',f'Raw video file items: {sum(d.data_type=="rawdata"):,}',f'Processed video file items: {sum(d.data_type=="processed"):,}',f'Processed normalized filename keys matching raw (site, patient, visit, filename): {int(pr.matching_raw_filename_key.sum()):,}',f'Processed normalized filename keys without raw match: {int((~pr.matching_raw_filename_key).sum()):,}','', 'A missing exact filename match does NOT establish a distinct clinical recording.','The source folder IDs cannot be independently confirmed from this CSV because the extraction stores the parent folder_id for each file, not the rawdata/processed root IDs.','To verify the actual root IDs, inspect the two root folders in Thea.View or log their names and IDs during the study-root discovery step.','Check extraction_summary.json: both roots must have status COMPLETE and no API errors.','', 'Largest batch differences:']
for _,row in batch.head(8).iterrows(): lines.append(f"{row['batch']}: raw={row['rawdata']}, processed={row['processed']}, difference={row['processed_minus_raw']:+}")
(out/'00_audit_readme.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('\n'.join(lines))
print('Outputs:',out.resolve())
