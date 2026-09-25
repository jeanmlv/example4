# example4

VALUE_CONFLICTS, DUPLICATE_KEYS, COLUMN_VISIT_QC e SOURCE_FILES. o que mostra cada uma dessas abas

Claro. Pensando especificamente no objetivo do seu merged.ard.file.py — reconciliar ARDs diferentes sem perder informação — cada aba responde a uma pergunta diferente.

Aba	Pergunta que responde	O que você procura
FILE_COMPARISON	Como os arquivos diferem estruturalmente?	linhas, colunas, subjects, visits, colunas exclusivas
VALUE_CONFLICTS	Quando ambos têm dado para a mesma chave/coluna, os valores divergem?	conflitos reais entre ARDs
DUPLICATE_KEYS	Existem múltiplas linhas para a mesma chave dentro de um ARD?	problemas de granularidade/duplicação
COLUMN_VISIT_QC	Em quais visitas cada coluna realmente possui dados?	cobertura das variáveis ao longo das visitas
SOURCE_FILES	Quais arquivos participaram da construção do merged ARD?	rastreabilidade/proveniência
VALUE_CONFLICTS

Essa é provavelmente a aba mais importante para validar o merge.

Imagine a mesma chave:

USUBJID = 10001 + AVISIT = WEEK 8 + AVISITN = 8

e a mesma variável existe nos dois arquivos:

Arquivo	CALPRO
Final ARD	125
M4WK ARD	140

Isso é um value conflict. Não estamos falando de missing complementado pelo outro arquivo; os dois possuem um valor, mas discordam.

Essa aba deve permitir identificar situações do tipo:

mesma key + mesma column + dois ou mais valores não-missing diferentes.

Se VALUE_CONFLICTS estiver vazia ou tiver pouquíssimos casos, é um ótimo indicativo de consistência entre os ARDs. Se houver conflitos, precisamos entender qual regra o script usa para escolher o valor final.

DUPLICATE_KEYS

Essa aba olha para a estrutura das linhas, não para diferenças de valores entre arquivos.

Sua chave de integração provavelmente é algo como:

USUBJID + AVISIT + AVISITN

Então ela procura situações como:

USUBJID	AVISIT	AVISITN
10001	WEEK 8	8
10001	WEEK 8	8

Se isso ocorre dentro do mesmo arquivo, você tem duas linhas disputando a mesma chave.

No seu FILE_COMPARISON, vimos:

DUPLICATE_COMPLETE_KEY_ROWS = 0
DUPLICATE_COMPLETE_KEY_GROUPS = 0

Então, pelo menos para esses dois arquivos, aparentemente não foram encontradas duplicatas de chave completa. É por isso que também:

ROWS = ROWS_AFTER_INTERNAL_CONSOLIDATION

Essa é uma boa evidência de que cada ARD já estava consistente nessa granularidade.

COLUMN_VISIT_QC

Essa aba olha para a cobertura das variáveis por visita.

Por exemplo, uma variável poderia aparecer assim:

COLUMN	AVISIT	Final	M4WK
CALPRO	SCREENING	120	120
CALPRO	WEEK 8	115	118
CALPRO	WEEK 44	0	110

Isso é muito útil porque uma coluna simplesmente existir no arquivo não significa que ela tenha informação em todas as visitas.

No seu caso isso pode responder perguntas como:

"Essa variável existe nos dois ARDs, mas o M4WK traz dados dela em visitas que o Final não possui?"

Isso complementa bastante o FILE_COMPARISON: o primeiro mostra cobertura estrutural por arquivo; COLUMN_VISIT_QC entra no nível variável × visita.

SOURCE_FILES

Essa é principalmente uma aba de lineage/provenance.

Ela registra quais arquivos entraram na integração, por exemplo:

CNTO1275CRD3004_uniti_jr_final_ard_20260922.xlsx

e

CNTO1275CRD3004_uniti_jr_m4wk_ard_20260922.xlsx

Dependendo de como seu script foi construído, ela também pode registrar outras informações sobre esses arquivos.

O objetivo é permitir que alguém olhando o merged ARD posteriormente consiga responder:

"Quais arquivos de origem foram usados para construir este ARD?"

Isso é particularmente importante para rastreabilidade.

Como eu usaria essas abas para validar seu merged ARD

O fluxo lógico é:

FILE_COMPARISON → "O que cada ARD trouxe?"

DUPLICATE_KEYS → "As chaves estavam estruturalmente válidas antes/depois da consolidação?"

VALUE_CONFLICTS → "Quando ambos tinham informação, eles concordavam?"

COLUMN_VISIT_QC → "Onde cada variável realmente possui cobertura ao longo das visitas?"

SOURCE_FILES → "De quais arquivos vieram os dados?"

E tem uma distinção muito importante:

Complementação ≠ conflito.

Se Final tem CALPRO = missing e M4WK tem CALPRO = 120, isso é complementação.

Se Final tem CALPRO = 100 e M4WK tem CALPRO = 120, isso é conflito.

Se você me mostrar agora um print da aba VALUE_CONFLICTS, consigo interpretar exatamente como o seu script está tratando esse segundo cenário.

