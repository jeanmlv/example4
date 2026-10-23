# example4


Hi Pablo,

I've completed the initial QUASAR video availability analysis using the rawdata and processed folders in Thea.View.

I developed and executed a Python workflow to extract the video inventory, calculate the coverage metrics, and validate the results.

I've attached an Excel summary organized into three tabs: raw_videos, processed_videos, and definitions.

For each visit, the analysis includes:

- **Unique patients at visit:** Number of distinct patients with at least one video at that visit.
- **Video files:** Total number of video files identified.
- **Estimated distinct recordings:** Number of recordings after metadata-based deduplication.
- **Cumulative unique patients:** Number of distinct patients with at least one video in any scheduled visit up to and including the specified visit.
- **Complete longitudinal patients:** Number of patients with at least one video at every scheduled visit up to and including the specified visit.

I included both cumulative and complete longitudinal patient counts to cover the different interpretations of patient availability across visits.

One point to note is that processed data contains more video files than rawdata. The distinct recording counts are therefore preliminary estimates, pending further reconciliation of the processing outputs.

The workflow is now scripted and can be reused for other studies. As a next step, we can explore automating the reporting and integrating these metrics into the ARGES Commons dashboard.

Best regards,
Jean
