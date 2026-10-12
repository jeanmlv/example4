# example4
dicas : ctrl + shift + V para colar no terminal 

aws s3 ls s3://med-ai-clinical/cnto1959uco3001_ke_lte_w188/  > para ver Domino esta acessando corretamente os dados no Med.AI (S3)

cat /domino/datasets/local/clinical-trial-data/sync_all_medai_ClinicalTrial_s3.sh

unset MEDAI_KEY MEDAI_SECRET MEDAI_TOKEN

echo "Cole a Access Key e pressione Enter:"
IFS= read -r MEDAI_KEY

echo "Cole a Secret Key e pressione Enter:"
IFS= read -rs MEDAI_SECRET
echo

echo "Cole o Session Token e pressione Enter:"
IFS= read -rs MEDAI_TOKEN
echo

echo "Verificando preenchimento..."
for var in MEDAI_KEY MEDAI_SECRET MEDAI_TOKEN; do
    if [[ -n "${!var}" ]]; then
        echo "$var: OK"
    else
        echo "$var: VAZIO"
    fi
done



        
