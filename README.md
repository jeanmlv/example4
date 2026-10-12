# example4
dicas : ctrl + shift + V para colar no terminal 

aws s3 ls s3://med-ai-clinical/cnto1959uco3001_ke_lte_w188/  > para ver Domino esta acessando corretamente os dados no Med.AI (S3)

cat /domino/datasets/local/clinical-trial-data/sync_all_medai_ClinicalTrial_s3.sh

1. Configurar as credenciais temporárias
No Terminal do RStudio do Domino, execute:
read -r -p "AWS Access Key ID: " MEDAI_KEY
read -r -s -p "AWS Secret Access Key: " MEDAI_SECRET
echo
read -r -s -p "AWS Session Token: " MEDAI_TOKEN
echo


Cole cada valor diretamente do Med.AI quando solicitado. O Secret Key e o Session Token não aparecerão na tela enquanto você os digita.
Importante: como o Access Key ID ficou visível no print, recomendo gerar novas credenciais antes de continuar. Não compartilhe as novas chaves ou tokens aqui.
2. Testar o acesso ao S3
Ainda no Terminal, execute:
AWS_ACCESS_KEY_ID="$MEDAI_KEY" \
AWS_SECRET_ACCESS_KEY="$MEDAI_SECRET" \
AWS_SESSION_TOKEN="$MEDAI_TOKEN" \
AWS_DEFAULT_REGION="us-east-1" \
aws s3 ls \
"s3://med-ai-clinical/cnto1959uco3001_kc_lte_w188/"


Observe que utilizei o caminho kc_lte_w188, conforme aparece no seu print mais recente.
Se funcionar, esperamos:
PRE load-3296/
PRE load-3297/


3. Próxima etapa: sincronização
Quando o teste funcionar, faremos a simulação da transferência para:
/domino/datasets/local/clinical-trial-data/
└── CNTO1959UCO3001-QUASAR-LTE-WK188/
    ├── load-3296/
    └── load-3297/


A transferência será feita com aws s3 sync, utilizando as credenciais temporárias somente naquele comando, sem alterar as configurações permanentes do Domino.
Depois da operação, também eliminaremos as variáveis temporárias da sessão.
Execute os passos 1 e 2 e me envie apenas o resultado da listagem S3, sem mostrar as credenciais. Assim confirmamos o acesso antes de copiar os arquivos clínicos.





        
