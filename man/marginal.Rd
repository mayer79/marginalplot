% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/marginal.R
\name{marginal}
\alias{marginal}
\alias{marginal.default}
\alias{marginal.ranger}
\alias{marginal.explainer}
\title{Marginal Statistics}
\usage{
marginal(object, ...)

\method{marginal}{default}(
  object,
  v,
  data,
  y = NULL,
  pred = NULL,
  pred_fun = stats::predict,
  w = NULL,
  breaks = "Sturges",
  right = TRUE,
  discrete_m = 2L,
  wprob_low = 0.01,
  wprob_high = 0.99,
  calc_pred = TRUE,
  pd_n = 500L,
  ...
)

\method{marginal}{ranger}(
  object,
  v,
  data,
  y = NULL,
  pred = NULL,
  pred_fun = NULL,
  w = NULL,
  breaks = "Sturges",
  right = TRUE,
  discrete_m = 2L,
  wprob_low = 0.01,
  wprob_high = 0.99,
  calc_pred = TRUE,
  pd_n = 500L,
  ...
)

\method{marginal}{explainer}(
  object,
  v,
  data = object[["data"]],
  y = NULL,
  pred = NULL,
  pred_fun = object[["predict_function"]],
  w = object[["weights"]],
  breaks = "Sturges",
  right = TRUE,
  discrete_m = 2L,
  wprob_low = 0.01,
  wprob_high = 0.99,
  calc_pred = TRUE,
  pd_n = 500L,
  ...
)
}
\arguments{
\item{object}{Fitted model.}

\item{...}{Further arguments passed to \code{pred_fun()}, e.g., \code{type = "response"} in
a \code{glm()} or (typically) \code{prob = TRUE} in binary probabilistic models.}

\item{v}{Vector of variable names to calculate statistics.}

\item{data}{Matrix or data.frame.}

\item{y}{Numeric vector with observed values of the response.
Can also be a column name in \code{data}. Omitted if \code{NULL} (default).}

\item{pred}{Numeric vector with predictions. If \code{NULL}, it is calculated as
\code{pred_fun(object, data, ...)}. Used to save time if \code{marginal()} is to be
called multiple times.}

\item{pred_fun}{Prediction function, by default \code{stats::predict}.
The function takes three arguments (names irrelevant): \code{object}, \code{data}, and \code{...}.}

\item{w}{Optional vector with case weights. Can also be a column name in \code{data}.}

\item{breaks}{An integer, vector, string or function specifying the bins
of the numeric X variables as in \code{\link[graphics:hist]{graphics::hist()}}. The default is "Sturges".
To allow varying values of \code{breaks} across variables, it can be a list of the
same length as \code{v}, or a \emph{named} list with \code{breaks} for certain variables.}

\item{right}{Should bins created via \code{\link[graphics:hist]{graphics::hist()}} be right-closed?
The default is \code{TRUE}. Vectorized over \code{v}. Only relevant for numeric X.}

\item{discrete_m}{Numeric X variables with up to this number of unique values
should not be binned. The default is 2. Vectorized over \code{v}.}

\item{wprob_low}{The smallest values of a numeric X are capped at the corresponding
quantile. Set to 0 to avoid Winsorizing. Note that at most 100k observations
are sampled to calculate the quantile (uses random seed). Vectorized over \code{v}.}

\item{wprob_high}{The largest values of a numeric X are capped at the corresponding
quantile. Set to 1 to avoid Winsorizing. Note that at most 100k observations
are sampled to calculate the quantile (uses random seed). Vectorized over \code{v}.}

\item{calc_pred}{Should predictions be calculated? Default is \code{TRUE}. Only relevant
if \code{pred = NULL}.}

\item{pd_n}{Size of the data used for calculating partial dependence.
The default is 500. For larger \code{data} (and \code{w}), \code{pd_n} rows are randomly sampled
(uses random seed). Each variable specified by \code{v} uses the same subsample.
Set to 0 to omit.}
}
\value{
A list (of class "marginal") with a data.frame of statistics per feature. Use
single bracket subsetting to select part of the output.
}
\description{
This is the main function of the package. It calculates
\itemize{
\item average observed,
\item average predicted,
\item partial dependence, and
\item counts/weights
over (possibly binned) features X specified by their column names \code{v}.
}
}
\details{
For numeric variables with more than \code{discrete_m = 2} disjoint values,
the same binning options (specified by \code{breaks}) are available as in
\code{\link[graphics:hist]{graphics::hist()}}. Before calculating bins, the smallest and largest 1\% of the
values are winsorized (capped) at the corresponding observed (approximate) quantiles.
}
\section{Methods (by class)}{
\itemize{
\item \code{marginal(default)}: Default method.

\item \code{marginal(ranger)}: Method for "ranger" models.

\item \code{marginal(explainer)}: Method for DALEX "explainer".

}}
\examples{
fit <- lm(Sepal.Length ~ ., data = iris)
xvars <- colnames(iris)[-1]
M <- marginal(fit, v = xvars, data = iris, y = "Sepal.Length", breaks = 5)
M
M |>
  postprocess(sort = TRUE) |>
  plot()
}
\seealso{
\code{\link[=average_observed]{average_observed()}}, \code{\link[=partial_dependence]{partial_dependence()}}
}
