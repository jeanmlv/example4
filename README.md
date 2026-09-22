# example4

For example, if you are looking for the SES-CD Total Score:

In the PARAMCD_DICT, search for SESTOT. You’ll see that SESTOT corresponds to SES-CD Total Score and comes from the ADSESCD dataset.

Then, in the ARD, search for SESTOT again. You’ll find the column ADSESCD_PARAMCD_SESTOT_AVAL, which contains the actual SES-CD Total Score values for each subject/visit.

So the logic is basically: PARAMCD_DICT → identify the PARAMCD (SESTOT) → ARD → search SESTOT → check the corresponding values.

You can follow the same approach for the other clinical measures you’re looking for
