# example4

Relacionando diretamente ao ARD

Você pode explicar o fluxo assim:

CRF
   ↓
SDTM
(Data as collected)
   ↓
ADaM
(Analysis-ready)
   ↓
ARD
(Integration of multiple ADaM datasets)

Então dizer:

The ARD is essentially an integration layer built on top of multiple ADaM datasets. Rather than deriving variables again from SDTM, we leverage the existing ADaM derivations and integrate them into a single wide patient-level dataset.

E se perguntarem por que não gerar o ARD diretamente do SDTM?

Uma resposta sólida seria:

Technically it would be possible, but it would require recreating many derivations that have already been validated in ADaM, such as analysis visits, analysis populations, derived endpoints, analysis flags, and other statistical variables. Using ADaM is therefore more efficient, consistent, and aligned with the datasets used for statistical analyses.

Essa resposta demonstra entendimento de Clinical Programming

Na prática, o racional é:

SDTM responde: "What data were collected?"
ADaM responde: "What data are used for the statistical analysis?"
ARD responde: "Can we integrate all analysis variables into one easy-to-query patient-level table?"

Essa é exatamente a lógica que você está implementando no seu projeto de geração de ARDs. Se você explicar dessa forma em uma reunião, a justificativa será tecnicamente consistente e alinhada com as práticas de CDISC e Statistical Programming.
