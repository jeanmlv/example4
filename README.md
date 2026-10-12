# example4
dicas : ctrl + shift + V para colar no terminal 

aws s3 ls s3://med-ai-clinical/cnto1959uco3001_ke_lte_w188/  > para ver Domino esta acessando corretamente os dados no Med.AI (S3)

cat /domino/datasets/local/clinical-trial-data/sync_all_medai_ClinicalTrial_s3.sh

1- Primeiro, no Terminal do Domino, execute:

DEST="/domino/datasets/local/clinical-trial-data/CNTO1959UCO3001-QUASAR-LTE-WK188"

mkdir -p "$DEST"

Isso criará a pasta:
CNTO1959UCO3001-QUASAR-LTE-WK188

1- Primeiro, no Terminal do Domino, execute:

DEST="/domino/datasets/local/clinical-trial-data/CNTO1959UCO3001-QUASAR-LTE-WK188"

mkdir -p "$DEST"

Isso criará a pasta:
CNTO1959UCO3001-QUASAR-LTE-WK188

Antes de copiar, execute uma simulação:

aws s3 sync \
  "s3://med-ai-clinical/cnto1959uco3001_ke_lte_w188/" \
  "$DEST/" \
  --dryrun

Esse comando mostrará os arquivos que seriam transferidos, sem efetuar a cópia.

2- Transferir os dados

Se a simulação estiver correta, o dataset de destino permitir escrita e a movimentação estiver autorizada pelas regras de acesso aos dados clínicos, execute:

aws s3 sync \
  "s3://med-ai-clinical/cnto1959uco3001_ke_lte_w188/" \
  "$DEST/" \
  --no-progress

O comando preservará a estrutura dos diretórios:
CNTO1959UCO3001-QUASAR-LTE-WK188
load-3296
load-3297

Os arquivos internos de cada load também serão copiados.

3-validar a importação

Após a sincronização, execute:

du -sh "$DEST"

Para verificar o tamanho total dos dados importados.
Depois:

find "$DEST" -type f | wc -l


Para contar os arquivos.

E:
ls -lah "$DEST"


Para verificar os dois diretórios.





        
