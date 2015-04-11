This is a Naive Bayes document classifier using a bag of words representation of websites that are eitehr student made or faculty made.

The classification is done with either Bernoulli, Polynomial, or Gaussian weighting, with a MAP (smoothed) estimate option for the bernoullie and polynomial classifications.

Finally there is a repetition of one word in the data set (column 668) and a reclassification to measure any changes in classification accuracy.

 The folds.txt file delineates folds in the data (data.txt) to facilitate cross validation.

To use just run "python ParsedData.py" in the current folder structure.



