# example4

Pergunta do Pablo	Onde está no proposal
What videos do we have access to? What’s missing?	02_DATA_AVAILABILITY + 03_ASSETS
What ARDs do we have access to? What’s missing?	02_DATA_AVAILABILITY + 06_ARD
What data is being used for training/validation/holdout?	05_DATA_SPLITS
What data has already been processed?	04_PROCESSING
What still needs to be processed?	04_PROCESSING
Where is the raw data?	03_ASSETS → S3 Location / DB Schema
Where is the processed data?	04_PROCESSING → Results Location
Where are the splits used for training?	05_DATA_SPLITS → Location / Split File

Hi Ravi,

I created a proposed structure for reorganizing the current IBD data inventory before we start building the Streamlit dashboard.

The main idea is to move away from having most of the information concentrated in a few very wide worksheets and instead organize the data into separate, related tables. Each table represents a specific part of the inventory, and they can all be linked using the Study ID as the main key.

This structure is intended to directly support the questions Pablo mentioned, such as:

What video data do we currently have access to, and what is missing?
What ARDs are available, and what is missing?
Which studies/data are being used for training, validation and holdout?
What data has already been processed and what still needs to be processed?
Where are the raw data, processed data and model splits located?

The proposed workbook is therefore organized into seven main tables:

01_STUDIES – master list of studies and general clinical trial information
02_DATA_AVAILABILITY – high-level availability of videos, SDTM/ADaM, ARDs and other relevant data
03_ASSETS – individual Med.ai/data assets and their technical locations
04_PROCESSING – status of preprocessing, feature extraction, CMES inference and modeling
05_DATA_SPLITS – training, validation, test/holdout datasets and their locations
06_ARD – ARD-level information and variable mapping coverage
07_ARD_VARIABLES – detailed mapping of variables of interest to the variables available in each ARD

The idea is that the Streamlit app would read these tables and join them using the Study ID. This should make it much easier to build filters, KPIs, study-level views and availability/status matrices.
