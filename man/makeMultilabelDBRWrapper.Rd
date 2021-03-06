% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MultilabelDBRWrapper.R
\name{makeMultilabelDBRWrapper}
\alias{makeMultilabelDBRWrapper}
\title{Use dependent binary relevance method (DBR) to create a multilabel learner.}
\usage{
makeMultilabelDBRWrapper(learner)
}
\arguments{
\item{learner}{[\code{\link{Learner}} | \code{character(1)}]\cr
The learner.
If you pass a string the learner will be created via \code{\link{makeLearner}}.}
}
\value{
[\code{\link{Learner}}].
}
\description{
Every learner which is implemented in mlr and which supports binary
classification can be converted to a wrapped DBR multilabel learner.
The multilabel classification problem is converted into simple binary classifications
for each label/target on which the binary learner is applied.
For each target, actual information of all binary labels (except the target variable) is used as additional features.
During prediction these labels need are obtained by the binary relevance method using the same binary learner.

Models can easily be accessed via \code{\link{getLearnerModel}}.
}
\examples{
d = getTaskData(yeast.task)
# drop some labels so example runs faster
d = d[seq(1, nrow(d), by = 10), c(1:3, 15:117)]
task = makeMultilabelTask(data = d, target = c("label1", "label2", "label3"))
lrn = makeLearner("classif.rpart")
lrn = makeMultilabelBinaryRelevanceWrapper(lrn)
lrn = setPredictType(lrn, "prob")
# train, predict and evaluate
mod = train(lrn, yeast.task)
pred = predict(mod, yeast.task)
performance(pred, measure = list(multilabel.hamloss, multilabel.subset01, multilabel.f1))
# the next call basically has the same structure for any multilabel meta wrapper
getMultilabelBinaryPerformances(pred, measures = list(mmce, auc))
# above works also with predictions from resample!

}
\references{
Montanes, E. et al. (2013)
\emph{Dependent binary relevance models for multi-label classification}
Artificial Intelligence Center, University of Oviedo at Gijon, Spain.
}
\seealso{
Other multilabel: \code{\link{getMultilabelBinaryPerformances}},
  \code{\link{makeMultilabelBinaryRelevanceWrapper}},
  \code{\link{makeMultilabelClassifierChainsWrapper}},
  \code{\link{makeMultilabelNestedStackingWrapper}},
  \code{\link{makeMultilabelStackingWrapper}}

Other wrapper: \code{\link{makeBaggingWrapper}},
  \code{\link{makeConstantClassWrapper}},
  \code{\link{makeCostSensClassifWrapper}},
  \code{\link{makeCostSensRegrWrapper}},
  \code{\link{makeDownsampleWrapper}},
  \code{\link{makeFeatSelWrapper}},
  \code{\link{makeFilterWrapper}},
  \code{\link{makeImputeWrapper}},
  \code{\link{makeMulticlassWrapper}},
  \code{\link{makeMultilabelBinaryRelevanceWrapper}},
  \code{\link{makeMultilabelClassifierChainsWrapper}},
  \code{\link{makeMultilabelNestedStackingWrapper}},
  \code{\link{makeMultilabelStackingWrapper}},
  \code{\link{makeOverBaggingWrapper}},
  \code{\link{makePreprocWrapperCaret}},
  \code{\link{makePreprocWrapper}},
  \code{\link{makeRemoveConstantFeaturesWrapper}},
  \code{\link{makeSMOTEWrapper}},
  \code{\link{makeTuneWrapper}},
  \code{\link{makeUndersampleWrapper}},
  \code{\link{makeWeightedClassesWrapper}}
}

