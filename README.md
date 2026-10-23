# example4


Metric	Interpretation
unique_patients_at_visit	Number of distinct patients with at least one video file identified at the specified visit. Patients are counted once per visit, regardless of the number of video files available.
file_items	Total number of video files identified at the specified visit, including original, transcoded, or other file versions. Multiple files may correspond to the same underlying recording.
technical_recordings_est	Estimated number of distinct technical video recordings at the specified visit after metadata-based deduplication. This estimate may not represent the exact number of unique clinical videos.
cumulative_unique_patients	Cumulative number of distinct patients with at least one video available at the specified scheduled visit or any preceding scheduled visit. Each patient is counted only once across visits.

Unscheduled visits: Cumulative unique patient counts are not calculated for unscheduled visits because these visits do not have a fixed position in the predefined study visit sequence. They are reported separately using visit-specific patient and video counts.

visit_type	Classification of the visit as scheduled or unscheduled. Scheduled visits follow the predefined study visit sequence, while unscheduled visits occur outside that sequence.
study	Clinical study associated with the extracted video records.


        
