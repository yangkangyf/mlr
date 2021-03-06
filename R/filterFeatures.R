#' @title Filter features by thresholding filter values.
#'
#' @description
#' First, calls \code{\link{generateFilterValuesData}}.
#' Features are then selected via \code{select} and \code{val}.
#'
#' @template arg_task
#' @param method [\code{character(1)}]\cr
#'   See \code{\link{listFilterMethods}}.
#'   Default is \dQuote{rf.importance}.
#' @param fval [\code{\link{FilterValues}}]\cr
#'   Result of \code{\link{generateFilterValuesData}}.
#'   If you pass this, the filter values in the object are used for feature filtering.
#'   \code{method} and \code{...} are ignored then.
#'   Default is \code{NULL} and not used.
#' @param perc [\code{numeric(1)}]\cr
#'   If set, select \code{perc}*100 top scoring features.
#'   Mutually exclusive with arguments \code{abs} and \code{threshold}.
#' @param abs [\code{numeric(1)}]\cr
#'   If set, select \code{abs} top scoring features.
#'   Mutually exclusive with arguments \code{perc} and \code{threshold}.
#' @param threshold [\code{numeric(1)}]\cr
#'   If set, select features whose score exceeds \code{threshold}.
#'   Mutually exclusive with arguments \code{perc} and \code{abs}.
#' @param mandatory.feat [\code{character}]\cr
#'   Mandatory features which are always included regardless of their scores
#' @param ... [any]\cr
#'   Passed down to selected filter method.
#' @template ret_task
#' @export
#' @family filter
filterFeatures = function(task, method = "rf.importance", fval = NULL, perc = NULL, abs = NULL,
                          threshold = NULL, mandatory.feat = NULL, ...) {
  assertClass(task, "SupervisedTask")
  assertChoice(method, choices = ls(.FilterRegister))
  select = checkFilterArguments(perc, abs, threshold)
  p = getTaskNFeats(task)
  nselect = switch(select,
    perc = round(perc * p),
    abs = min(abs, p),
    threshold = p
  )

  if (is.null(fval)) {
    fval = generateFilterValuesData(task = task, method = method, nselect = nselect, ...)$data
  } else {
    assertClass(fval, "FilterValues")
    if (!is.null(fval$method)) { ## fval is generated by deprecated getFilterValues
      colnames(fval$data)[which(colnames(fval$data) == "val")] = fval$method
      method = fval$method
      fval = fval$data[, c(1,3,2)]
    } else {
      methods = colnames(fval$data[, -which(colnames(fval$data) %in% c("name", "type")), drop = FALSE])
      if (length(methods) > 1) {
        assert(method %in% methods)
      } else {
        method = methods
        fval = fval$data
      }
    }
  }

  if (all(is.na(fval[[method]]))) {
    stopf("Filter method returned all NA values!")
  }

  if (!is.null(mandatory.feat)) {
    assertCharacter(mandatory.feat)
    if (!all(mandatory.feat %in% fval$name))
      stop("At least one mandatory feature was not found in the task.")
    if (select != "threshold" && nselect < length(mandatory.feat))
      stop("The number of features to be filtered cannot be smaller than the number of mandatory features.")
    #Set the the filter values of the mandatory features to infinity to always select them
    fval[fval$name %in% mandatory.feat, method] = Inf
  }
  if (select == "threshold")
    nselect = sum(fval[[method]] >= threshold, na.rm = TRUE)
  features = as.character(head(sortByCol(fval, method, asc = FALSE)$name, nselect))
  allfeats = getTaskFeatureNames(task)
  j = match(features, allfeats)
  features = allfeats[sort(j)]
  subsetTask(task, features = features)
}

checkFilterArguments = function(perc, abs, threshold) {
  sum.null = sum(!is.null(perc), !is.null(abs), !is.null(threshold))
  if (sum.null == 0L)
    stop("At least one of 'perc', 'abs' or 'threshold' must be not NULL")
  if (sum.null >= 2L)
    stop("Arguments 'perc', 'abs' and 'threshold' are mutually exclusive")

  if (!is.null(perc)) {
    assertNumber(perc, lower = 0, upper = 1)
    return("perc")
  }
  if (!is.null(abs)) {
    assertCount(abs)
    return("abs")
  }
  if (!is.null(threshold)) {
    assertNumber(threshold)
    return("threshold")
  }
}
