# example4

Hi Shinobu, here's a concrete example from the ANTHEM-UC study.

The study is split into three separate folders (WK12, WK28 and WK78), each containing its own ADMAY0 dataset.

For subject 77242113UC02001-AR100040001 at Week 28 with PARAMCD = ENFSCOR, I found different values across the source datasets:

WK12 ADMAY0: AVAL = 1
WK78 ADMAY0: AVAL = 2

When these datasets are merged into a single ARD, both records are preserved because they have the same subject/visit/PARAMCD combination, so the ARD currently concatenates them (1 | 2) instead of selecting a single value.
