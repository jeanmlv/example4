# example4

For some endpoints, there may be multiple observed records for the same subject and visit in the source ADaM dataset. Since the ARD is structured at the subject-by-visit level, these multiple values are concatenated into a single field rather than selecting or dropping one of them.

For example, for GBTOT, the source dataset contains AVAL values of 9, 8, 10, and 12 for the same USUBJID and AVISIT. Therefore, the ARD displays them as 9 | 8 | 10 | 12. This preserves all source observations and avoids making an assumption about which value should be retained.

xxxxx

They are not necessarily duplicate records. They share the same subject, visit, and endpoint, but they may represent different analysis records or analysis contexts in the source ADaM. When we collapse the data to the ARD subject-by-visit structure, that additional record-level distinction is no longer part of the ARD key, so the values are concatenated.

xxxx 

That's because we have multiple records for this endpoint for the same subject and visit in the source ADaM. Since our ARD has one row per subject and visit, we concatenate the observed values instead of arbitrarily selecting one and potentially losing information.
