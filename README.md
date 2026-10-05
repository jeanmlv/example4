# example4

2. Privacy Assessment Form
Esse documento é justamente o formulário para Internal Use of Clinical Study Data for Compatible or Secondary Use. Ele se aplica quando apenas pessoal/entidades da J&J terão acesso aos dados; se houver colaboração externa, o processo é outro. TV-eFRM-17316_v4.0
Aqui conseguimos preencher bastante coisa, mas não recomendo inventarmos Department/Group, compound ou respostas de compatibility sem confirmação.
Section 1.1 — Preliminary Information
Name of Requestor
Jean Mendes

Department/Group
Aqui eu confirmaria com Basudeb/Sonal qual nomenclatura oficial usar. Provavelmente algo relacionado ao time/projeto em que vocês estão trabalhando, mas o formulário pede formalmente o Department/Group. TV-eFRM-17316_v4.0
E-mail address
Seu e-mail corporativo J&J

Full Protocol number(s)
CNTO1959UCO3001

Therapeutic Area
Gastroenterology – Ulcerative Colitis

Study Compound(s)
Aqui eu confirmaria antes de preencher. Não vale deduzir apenas pelo estudo.
Are Biological Samples being requested?
☒ No

Pelo que estamos solicitando, são datasets clínicos, não biological samples.
Are any medical images, personal images, photos, video recordings, or audio [...] being requested?
☒ No

Isso é importante: apesar de alguns endpoints envolverem endoscopic healing, pelo que entendo vocês estão solicitando dados clínicos derivados/tabulares, não as imagens endoscópicas propriamente ditas.
Date of Request
October 5, 2026

Esses são exatamente os campos exigidos na Section 1.1. TV-eFRM-17316_v4.0
3. Section 1.2 — Purpose of the research
Esse é um dos campos mais importantes.
O formulário pede uma detailed description of the purpose of the research e permite uma descrição mais curta caso exista um analysis plan anexado. TV-eFRM-17316_v4.0
Considerando também a recomendação do Pablo de não limitar o request a uma única análise/data cut, eu colocaria algo como:
The purpose of this request is to support ongoing analysis of long-term clinical study data from the QUASAR study (CNTO1959UCO3001), including updated data through Week M-188. The data will be used for internal clinical data analysis, model development, training and validation, and related analytical activities to evaluate long-term clinical outcomes. The requested SDTM and ADaM datasets will support reproducible analyses of relevant clinical endpoints and longitudinal outcomes over the course of the study.

Essa versão é abrangente sem dizer que vocês estão solicitando apenas uma análise de Week M-188.
Porém, como o formulário fala especificamente em purpose of the research, eu pediria ao Basudeb/Pablo que confirme esse texto antes da submissão, especialmente a expressão “model development, training and validation”.
4. Section 2.1 — Type of Clinical Study Data
Eu marcaria:
☒ Key-coded Clinical Study Data

O próprio formulário define isso como dados nos quais os identificadores pessoais diretos foram substituídos por um study participant identifier. TV-eFRM-17316_v4.0
Isso também corresponde ao Dataset Type → Key Coded que eu escolheria no Med.AI.
Como não estamos solicitando biological samples:
Biological sample label → ☒ N/A
Processing of biological samples → ☒ N/A

E como não estamos solicitando imagens/vídeos/áudio dos participantes:
ICF review for medical images/photos/video/audio → ☒ N/A

O formulário especificamente prevê essas opções. TV-eFRM-17316_v4.0
Para:
Describe the ICF review done and the outcome of the review:
Eu deixaria em branco/N/A, se permitido, justamente porque não estamos solicitando essas mídias. Não inventaria uma revisão de ICF que não ocorreu.
5. Section 2.2 — Compatibility Assessment
Aqui eu teria mais cautela.
O formulário pergunta se o uso é compatível com a pesquisa original e oferece várias justificativas: compreender produto, doença, aplicar aprendizados, melhorar métodos científicos, compreender como o medicamento deve ser usado etc. TV-eFRM-17316_v4.0
Para o seu caso, a opção que mais claramente parece aplicável é:
Is the proposed use ... necessary and consistent with the primary research [...] to learn about a pharmaceutical product...?
☒ Yes

Também pode ser defensável:
evaluate and understand the disease in scope of the original study and any associated health problems?
☒ Yes

E possivelmente:
improve scientific analysis methods?
☒ Yes

por causa do trabalho de model development/training/validation.
Mas eu não preencheria essas três respostas sozinho ainda. Como isso é uma declaração formal de privacy/compatibility, vale confirmar com o responsável pelo request.
As demais, na ausência de outro objetivo declarado, tenderiam a No, especialmente publicação/educational purposes, porque isso não apareceu como objetivo do trabalho.
Se todas fossem No, o próprio formulário exigiria reconsiderar Key-coded versus anonymized/synthesized ou seguir para Section 2.3. TV-eFRM-17316_v4.0
Portanto, estamos quase lá
Eu vejo somente quatro pontos que realmente precisam de confirmação antes do Submit:
1. Associate with Med.ai project/use case
2. Department/Group
3. Study Compound(s)
4. Compatibility Assessment da Section 2.2
O restante conseguimos preencher com bastante segurança a partir do request e do histórico do QUASAR.
E há um detalhe importante no próprio Med.AI: ele diz que, se você não souber o nome do CDTL, pode submeter o formulário sem a aprovação do CDTL, e o platform operations team fornecerá o contato. Portanto, a ausência dessa informação aparentemente não precisa bloquear todo o processo.
Se quiser, posso também preencher uma cópia desse DOCX para você, mantendo o layout original e deixando destacados apenas esses quatro campos como TO BE CONFIRMED, para você revisar antes de anexar ao Med.AI.
