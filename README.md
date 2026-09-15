# example4

1 — Clinical Study

Establish the study context

1.1 Identify the clinical study and Study ID
1.2 Capture indication, phase, compound and study population
1.3 Use the Study ID as the common reference across the data ecosystem

Aqui visualmente você começa pelo estudo, e não pelo ARD.

Exemplos: ANTHEM, POWER, STARDUST, GRAVITI, GALAXI etc.

2 — Data Sources & Assets

Identify available study data

2.1 Identify available clinical, imaging and derived data assets
2.2 Determine where each asset is available
2.3 Capture asset type, source, status and location

Eu colocaria uma linha pequena de exemplos:

Examples: SDTM • ADaM • Videos • Annotations • Clinical GT • Feature Vectors

E pode mencionar verbalmente plataformas como Domino e Med.ai, sem necessariamente poluir o slide.

3 — Processing

Track data processing and provenance

3.1 Capture preprocessing and feature extraction steps
3.2 Track pipeline and code versions
3.3 Document processing owners, projects and output locations
3.4 Maintain traceability from source data to derived outputs

Esse box representa muito bem a parte do ARGES que não é necessariamente sua responsabilidade direta, então na apresentação você pode dizer:

This is where the raw or source assets are transformed into derived analytical assets. The Commons is intended to capture the provenance of those transformations rather than replace the underlying processing platforms.

4 — Data Splits

Document analytical data usage

4.1 Identify training, validation and test datasets
4.2 Capture subject-, visit- and video-level assignments
4.3 Track cross-validation folds when applicable
4.4 Link data splits to the corresponding study and processing outputs

Esse box é particularmente importante para ML.

5 — Analysis-Ready Data

Aqui eu colocaria sua área com mais destaque:

Build analysis-ready datasets

5.1 Integrate relevant study data into the ARD
5.2 Map predefined variables of interest
5.3 Assess variable availability and mapping coverage
5.4 Identify missing or unresolved variables through gap analysis
5.5 Maintain traceability to source datasets and variables

E visualmente poderia colocar embaixo:

Study data → ARD → Variable mapping → Gap analysis

Isso conecta diretamente ao processo que você já apresentou ao time.

6 — Analysis

Enable downstream analysis

6.1 Connect analysis-ready data to analytical use cases
6.2 Track dataset and analysis versions
6.3 Link analytical code, repositories and outputs
6.4 Document ownership and analysis status

E uma última linha:

ARDs • Statistical Analysis • ML Models • Dashboards • Decision Support
