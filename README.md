# example4

Hi Shinobu,

The example that Pablo is referring to is from the ANTHEM-UC study. The source dataset is ADMAY0, and the parameter is ENFSCOR.

The ADaM datasets for this study are split across three separate folders (WK12, WK28, and WK78), each containing its own copy of the ADaM datasets.

ADMAY0.csv is available in both the WK12 and WK78 folders, for example:

/domino/datasets/local/clinical-trial-data/77242113UC02001-ANTHEM-UC-UNBLINDED-WK12/load-2529/Data/_csv
/domino/datasets/local/clinical-trial-data/77242113UC02001-ANTHEM-UC-UNBLINDED-WK78/load-3134/Data/_csv

For subject 77242113UC02001-AR100040001, at Week 28, with PARAMCD = ENFSCOR, I found different values across the source datasets:

WK12: AVAL = 1
WK78: AVAL = 2

When these datasets are merged into a single ARD, both records are preserved because they have the same USUBJID / AVISIT / PARAMCD combination. As a result, the ARD currently concatenates the values (1 | 2) instead of selecting a single value.
