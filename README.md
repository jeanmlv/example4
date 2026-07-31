# example4

Thanks, Shinobu, for confirming this and for looking into the data.

Just to make sure I implement the ARD generation correctly, should this be the general rule whenever we merge multiple data transfers?

In other words, if the same USUBJID/AVISIT/PARAMCD combination exists with different values across transfers, should we always keep the value from the latest transfer or load?

For example, in this case we would keep the WK78 value instead of WK12. Similarly, if we have multiple loads of the same study (e.g., load-1899 vs. load-1903), should we always keep the value from the latest load, or should this be evaluated on a study-by-study basis?

I just want to make sure we apply a consistent rule across all studies.
