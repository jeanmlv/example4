# example4

Hi Ravi, I made an update to the Data Splits section of the inventory based on the JAK UC split file that the team shared.

I reorganized it into two levels:

05_DATA_SPLITS is now the summary-level table. It captures how the data is split for each study, including the Dataset Role, Split Label, CV Fold, Split %, number of patients, number of videos, split file, and location.

For JAK, for example, I used JAKUC_splits.csv and summarized the information based on the dataset, CV_Fold, and split_label fields. The development data is divided into dev_fold0, dev_fold1, and dev_fold2, while int_test and holdout are captured separately. I calculated the number of patients using the unique Subject IDs within each split and the number of videos based on the number of video records. The Split % is based on the proportion of unique patients in each split.

I also created 05A_DATA_SPLIT_DETAILS for the granular information. Here, instead of having only the summary, we keep the subject-level/video-level records, including Subject ID, Bag ID, Visit, Dataset Role, CV Fold, Split Label, and Video File Path.

So the idea is basically:
05_DATA_SPLITS = summary view
05A_DATA_SPLIT_DETAILS = detailed/source-level view

I already populated JAK as an example/reference. Could you use the same approach to populate the remaining studies whenever this level of split information is available in the source files?

If a study only has high-level Train/Validation/Test information and no detailed split file, we can just populate what is available in 05_DATA_SPLITS and leave the more granular fields/details blank.

