# example4


Hi Pablo,

I've completed the initial video inventory and coverage analysis for QUASAR using the rawdata and processed folders available in Thea.View.

I developed a Python workflow to extract the video metadata, calculate the visit-level metrics, and perform validation checks.

I've attached an Excel summary organized into three tabs: **raw_videos**, **processed_videos**, and **definitions**.

For each visit, the analysis provides:

- **Unique patients at visit:** Number of distinct patients with at least one video available at that visit.
- **Video files:** Total number of video files identified.
- **Estimated distinct recordings:** Number of technical recordings after metadata-based deduplication.
- **Cumulative unique patients:** Number of distinct patients with at least one video available at or before the specified scheduled visit.

Unscheduled visits are reported separately, without cumulative counts, as they do not follow a fixed visit sequence.

One point I'd like to confirm regarding your second question: the current cumulative metric counts patients with at least one video across the visits up to that point. If you meant patients with videos available at **every scheduled visit up to and including that visit**, I can calculate that longitudinal coverage metric as well.

Also, the processed folder contains more video records than rawdata, so the estimated distinct recording counts should be considered preliminary until the remaining differences are fully reconciled.

Once we confirm the metrics, we can work on automating the reporting and integrating it into the ARGES Commons dashboard.

Best regards,
Jean
        
