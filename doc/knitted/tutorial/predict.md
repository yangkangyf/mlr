Predicting Outcomes for New Data
================================

This section is pretty straightforward and - as you might have guessed
- deals with predicting target values for new observations. It is
implemented the same way as most of the other predict methods in R, i.e. just 
call [predict](http://berndbischl.github.io/mlr/man/predict.WrappedModel.html) on the object returned by [train](http://berndbischl.github.io/mlr/man/train.html) and pass the data to be predicted.


Quick start
-----------

### Classification example

Let's train a Linear Discriminant Analysis on the ``iris`` data and make predictions 
for the same data set.


```splus
library("mlr")

task = makeClassifTask(data = iris, target = "Species")
lrn = makeLearner("classif.lda")
mod = train(lrn, task = task)
pred = predict(mod, newdata = iris)
pred
```

```
## Prediction:
## predict.type: response
## threshold: 
## time: 0.00
## 'data.frame':	150 obs. of  2 variables:
##  $ truth   : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ response: Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
```

```splus
performance(pred)
```

```
## mmce 
## 0.02
```



### Regression example

We fit a simple linear regression model to the ``BostonHousing`` data set and predict
on the training data.


```splus
library("mlr")
library("mlbench")
data(BostonHousing)

task = makeRegrTask(data = BostonHousing, target = "medv")
lrn = makeLearner("regr.lm")
mod = train(lrn, task)
predict(mod, newdata = BostonHousing)
```

```
## Prediction:
## predict.type: response
## threshold: 
## time: 0.00
## 'data.frame':	506 obs. of  2 variables:
##  $ truth   : num  24 21.6 34.7 33.4 36.2 28.7 22.9 27.1 16.5 18.9 ...
##  $ response: num  30 25 30.6 28.6 27.9 ...
```



Further information
-------------------

There are several possibilities how to pass the observations for which 
predictions are required.
The first possibility, via the ``newdata``-argument, was already shown in the 
examples above.
If the data for which predictions are required are already contained in 
the [Learner](http://berndbischl.github.io/mlr/man/makeLearner.html), it is also possible to pass the task and optionally specify 
the subset argument that contains the indices of the test observations.

Predictions are encapsulated in a special [Prediction](http://berndbischl.github.io/mlr/man/Prediction.html) object. Read the
documentation of the [Prediction](http://berndbischl.github.io/mlr/man/Prediction.html) class to see all available
accessors.


### Classification example

In case of a classification task, the result of [predict](http://berndbischl.github.io/mlr/man/predict.WrappedModel.html) depends on 
the predict type, which was set when generating the [Learner](http://berndbischl.github.io/mlr/man/makeLearner.html). Per default, 
class labels are predicted.

We start again by loading **mlr** and creating a classification task for the 
iris dataset. We select two subsets of the data. We train a decision tree on the
first one and [predict](http://berndbischl.github.io/mlr/man/predict.WrappedModel.html) the class labels on the test set.


```splus
library("mlr")

# At first we define the classification task.
task = makeClassifTask(data = iris, target = "Species")

# Define the learning algorithm
lrn = makeLearner("classif.rpart")

# Split the iris data into a training set for learning and a test set.
training.set = seq(from = 1, to = nrow(iris), by = 2)
test.set = seq(from = 2, to = nrow(iris), by = 2)

# Now, we can train a decision tree using only the observations in
# ``train.set``:
mod = train(lrn, task, subset = training.set)

# Finally, to predict the outcome on new values, we use the predict method:
pred = predict(mod, newdata = iris[test.set, ])
```


A data frame that contains the true and predicted class labels can be accessed via


```splus
head(pred$data)
```

```
##     truth response
## 2  setosa   setosa
## 4  setosa   setosa
## 6  setosa   setosa
## 8  setosa   setosa
## 10 setosa   setosa
## 12 setosa   setosa
```


Alternatively, we can also predict directly from a task:


```splus
pred = predict(mod, task = task, subset = test.set)
head(as.data.frame(pred))
```

```
##    id  truth response
## 2   2 setosa   setosa
## 4   4 setosa   setosa
## 6   6 setosa   setosa
## 8   8 setosa   setosa
## 10 10 setosa   setosa
## 12 12 setosa   setosa
```


When predicting from a task, the resulting data frame contains an additional column, 
called ID, which tells us for which element in the original data set the prediction 
is done. 
(In the iris example the IDs and the rownames coincide.)

In order to get predicted posterior probabilities, we have to change the ``predict.type``
of the learner.


```splus
lrn = makeLearner("classif.rpart", predict.type = "prob")
mod = train(lrn, task)
pred = predict(mod, newdata = iris[test.set, ])
head(pred$data)
```

```
##     truth prob.setosa prob.versicolor prob.virginica response
## 2  setosa           1               0              0   setosa
## 4  setosa           1               0              0   setosa
## 6  setosa           1               0              0   setosa
## 8  setosa           1               0              0   setosa
## 10 setosa           1               0              0   setosa
## 12 setosa           1               0              0   setosa
```


As you can see, in addition to the predicted probabilities, a response
is produced by choosing the class with the maximum probability and
breaking ties at random.

The predicted posterior probabilities can be accessed via the [getProbabilities](http://berndbischl.github.io/mlr/man/getProbabilities.html)-function.


```splus
head(getProbabilities(pred))
```

```
##    setosa versicolor virginica
## 2       1          0         0
## 4       1          0         0
## 6       1          0         0
## 8       1          0         0
## 10      1          0         0
## 12      1          0         0
```



### Binary classification

In case of binary classification, two things are noteworthy. As you might recall, 
we can specify a positive class when generating the task. Moreover, we can set the
threshold value that is used to assign class labels based on the predicted 
posteriors.

To illustrate binary classification we use the Sonar dataset from the
[mlbench](http://cran.r-project.org/web/packages/mlbench/index.html) package. Again, we create a classification task and a learner, which 
predicts probabilities, train the learner and then predict the class labels.



```splus
library("mlbench")
data(Sonar)

task = makeClassifTask(data = Sonar, target = "Class", positive = "M")
lrn = makeLearner("classif.rpart", predict.type = "prob")
mod = train(lrn, task = task)
pred = predict(mod, task = task)
head(pred$data)
```

```
##   id truth prob.M prob.R response
## 1  1     R 0.1061 0.8939        R
## 2  2     R 0.7333 0.2667        M
## 3  3     R 0.0000 1.0000        R
## 4  4     R 0.1061 0.8939        R
## 5  5     R 0.9250 0.0750        M
## 6  6     R 0.0000 1.0000        R
```


In a binary classification setting, we can adjust the threshold, used
to map probabilities, to class labels using [setThreshold](http://berndbischl.github.io/mlr/man/setThreshold.html). Here, we set
the threshold for the *positive* class to 0.8:


```splus
pred = setThreshold(pred, 0.8)
head(pred$data)
```

```
##   id truth prob.M prob.R response
## 1  1     R 0.1061 0.8939        R
## 2  2     R 0.7333 0.2667        R
## 3  3     R 0.0000 1.0000        R
## 4  4     R 0.1061 0.8939        R
## 5  5     R 0.9250 0.0750        M
## 6  6     R 0.0000 1.0000        R
```

```splus
pred$threshold
```

```
##   M   R 
## 0.8 0.2
```



### Regression example

We again use the BostonHousing data set and learn a Gradient Boosting
Machine. We use every second observation for training/test. The
proceeding is analog to the classification case.


```splus
library(mlbench)
data(BostonHousing)

task = makeRegrTask(data = BostonHousing, target = "medv")

training.set = seq(from = 1, to = nrow(BostonHousing), by = 2)
test.set = seq(from = 2, to = nrow(BostonHousing), by = 2)

lrn = makeLearner("regr.gbm", n.trees = 100)
mod = train(lrn, task, subset = training.set)

pred = predict(mod, newdata = BostonHousing[test.set, ])

head(pred$data)
```

```
##   truth response
## 1  21.6    22.23
## 2  33.4    23.23
## 3  28.7    22.37
## 4  27.1    22.12
## 5  18.9    22.12
## 6  18.9    22.13
```

