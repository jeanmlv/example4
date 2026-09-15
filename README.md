# example4

Yes. The ANTHEM ARD includes a PARAMCD_DICT tab that serves as a data dictionary for the variables currently available in the ARD.

Just to give you some context on how the ARD is structured: it was built by extracting and consolidating variables from the available ADaM datasets for the study into a single analysis-ready structure, organized mainly at the subject/visit level.

The column naming convention also provides traceability back to the source ADaM dataset. For example, ADSL_AGE represents the AGE variable coming from ADSL. For parameter-based datasets, the column names also retain information such as the source dataset, PARAMCD, and value variable, which makes it possible to trace an ARD variable back to its ADaM source.

The PARAMCD_DICT tab provides a more convenient view of the parameters represented in the ARD, so I think that would be a good starting point to check whether the metrics you listed are already available.
