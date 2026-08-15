# example4

“For the AI model, I think we should prioritize the observed approach whenever it is available, because it is closer to the actual clinical data observed for the patient and has less influence from study-specific statistical rules.

The primary or alternative approaches may incorporate additional rules for handling missing data, intercurrent events, or non-responder assumptions. If we use those as the default, the model could potentially learn study-specific statistical assumptions rather than the underlying clinical information.

So my suggestion is to use Observed as the preferred source. If the observed version is not available, we can use the Primary or Alternative approach as a fallback, but we should flag it clearly so we maintain the data provenance.

The exception would be when both Observed and Primary/Alternative are explicitly included in our variables-of-interest list. In that case, I would keep and map both separately.”
