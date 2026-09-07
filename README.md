# example4

In ML, a feature vector is a numerical representation of an observation's characteristics.

For example, a video or image might undergo some processing:

Raw video/image → preprocessing → feature extraction → feature vector → ML model

Something that is originally a video might end up being represented as:

[0.21, 0.87, 0.04, 0.62, ...]

These vectors can be used by machine learning models without needing to reprocess the raw data every time.

So, I believe Pablo wants to know:

Does this study already have derived feature vectors available?

Here, we need to clarify one thing with him: whether he is interested only in availability or also in location.

If it is availability, I would use:

Feature Vectors Availability

with:

Available / Not Available / Pending / Unknown

If he wants to know where they are located, it would be better to use:

Feature Vectors Location

with path/bucket/table.
