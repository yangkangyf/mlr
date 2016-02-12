context("classif_xgboost")

test_that("classif_xgboost", {
  requirePackages("xgboost", default.method = "load")

  set.seed(getOption("mlr.debug.seed"))
  model = xgboost::xgboost(data = data.matrix(binaryclass.train[,1:60]),
    label = as.numeric(binaryclass.train[,61])-1,
    nrounds = 20, objective = "binary:logistic", verbose = 0)
  pred = xgboost::predict(model, data.matrix(binaryclass.test[,1:60]))
  pred = factor(as.numeric(pred>0.5), labels = binaryclass.class.levs)

  set.seed(getOption("mlr.debug.seed"))
  testSimple("classif.xgboost", binaryclass.df, binaryclass.target, binaryclass.train.inds, pred,
    parset = list(nrounds = 20))
})


# we had a bug here, reported by mail
# test_that("classif_xgboost works with objective softprob", {
#   requirePackages("xgboost", default.method = "load")

#   # construct easily separable data and check that error is 0
#   n = 50L
#   d = rbind(
#     data.frame(x1 = rnorm(n, mean = 10), x2 = rnorm(50, mean = 10), y = 1),
#     data.frame(x1 = rnorm(n, mean = 0), x2 = rnorm(50, mean = 0), y = -1)
#   )
#   d$y = as.factor(d$y)
#   task = makeClassifTask(data = d, target = "y")

#   lrn = makeLearner("classif.xgboost", objective = "multi:softprob")
#   r = holdout(lrn, task)
#   expect_equal(r$aggr, 0)
# })




#
