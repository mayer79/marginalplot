#' Postprocess Marginal Object
#'
#' This function helps to improve the output of [marginal()],
#' [partial_dependence()], [average_observed()]. Except for `sort` and `drop_stats`,
#' all arguments are vectorized, i.e., you can pass a list of the same length as
#' `object`.
#'
#' @param object Object of class "marginal".
#' @param sort Should `object` be sorted in decreasing order of feature importance?
#'   Importance is measured by the exposure weighted variance of the most
#'   relevant available statistic (pd > pred > obs). The default is `FALSE`.
#'   This step is applied after all other postprocessings.
#' @param drop_stats Statistics to drop, by default `NULL`.
#'   Subset of "pred", "obs", "pd". Not vectorized over `object` elements.
#' @param eval_at_center If `FALSE` (default), the points are aligned with (weighted)
#'   average X values per bin. If `TRUE`, the points are aligned with bar centers.
#'   Since categoricals are always evaluated at bar centers, this only affects numerics.
#' @param collapse_m If a categorical X has more than `collapse_m` levels,
#'   low exposure levels are collapsed into a new level "Other".
#'    By default `Inf` (no collapsing).
#' @param drop_below_n Drop categories with exposure below this value.
#'   Only for categorical X variables.
#' @param drop_below_prop Drop categories with relative exposure below this value.
#'   Only for categorical X variables.
#' @param explicit_na Should `NA` levels be converted to strings?
#'   Only for categorical X variables.
#' @param na.rm Should `NA` levels in X be dropped?
#' @seealso [marginal()], [average_observed()], [partial_dependence()]
#' @export
#' @examples
#' fit <- lm(Sepal.Length ~ ., data = iris)
#' xvars <- colnames(iris)[-1]
#' marginal(fit, v = xvars, data = iris, y = "Sepal.Length", breaks = 5) |>
#'   postprocess(sort = TRUE, eval_at_center = TRUE) |>
#'   plot(num_points = TRUE)
postprocess <- function(
  object,
  sort = FALSE,
  drop_stats = NULL,
  eval_at_center = FALSE,
  collapse_m = Inf,
  drop_below_n = 0,
  drop_below_prop = 0,
  explicit_na = TRUE,
  na.rm = FALSE
) {
  stopifnot(inherits(object, "marginal"))

  out <- mapply(
    postprocess_one,
    x = object,
    eval_at_center = eval_at_center,
    collapse_m = collapse_m,
    drop_below_n = drop_below_n,
    drop_below_prop = drop_below_prop,
    explicit_na = explicit_na,
    na.rm = na.rm,
    MoreArgs = list(drop_stats = drop_stats),
    SIMPLIFY = FALSE
  )

  if (isTRUE(sort)) {
    imp <- main_effect_importance(out)
    out <- out[order(imp, decreasing = TRUE, na.last = TRUE)]
  }

  class(out) <- "marginal"
  out
}

postprocess_one <- function(
  x,
  drop_stats,
  collapse_m,
  eval_at_center,
  drop_below_n,
  drop_below_prop,
  explicit_na,
  na.rm,
  ...
) {
  num <- is.numeric(x$eval_at)
  all_stats <- c("pred", "obs", "pd")

  if (!is.null(drop_stats)) {
    stopifnot(drop_stats %in% all_stats)
    x <- x[setdiff(colnames(x), drop_stats)]
  }

  if (num) {
    if (isTRUE(eval_at_center)) {
      x$eval_at <- x$bar_at
    }
  }

  if (!num) {
    if (collapse_m < nrow(x)) {
      x_list <- split(x, order(x$exposure, decreasing = TRUE) < collapse_m)
      x_keep <- x_list$`TRUE`
      x_agg <- x_list$`FALSE`

      # Prepare new factors
      x_keep <- droplevels(x_keep)
      lvl <- levels(x_keep$bar_at)
      if ("Other" %in% lvl) {
        stop("Factor level 'Other' already exists in 'bar_at'!")
      }
      levels(x_keep$bar_at) <- levels(x_keep$eval_at) <- c(lvl, "Other")

      # Collapse other rows
      S <- x_agg[intersect(colnames(x), all_stats)]
      gS <- grouped_mean(S, g = rep.int(1, nrow(S)), w = x_agg$exposure)
      x_new <- data.frame(bar_at = "Other", bar_width = 0.7, eval_at = "Other", gS)
      x <- rbind(x_keep, x_new)  # Column order dof x_new oes not matter
    }
    if (drop_below_n > 0) {
      x <- subset(x, exposure >= drop_below_n)
    }
    if (drop_below_prop > 0) {
      x <- subset(x, exposure / sum(exposure) >= drop_below_prop)
    }
    if (isTRUE(explicit_na)) {
      s <- is.na(x$bar_at)
      if (any(s)) {
        lvl <- levels(x$bar_at)
        if ("NA" %in% lvl) {
          stop("'bar_at' contains level 'NA'. This is incompatible with missing handling.")
        }
        levels(x$bar_at) <- levels(x$eval_at) <- c(lvl, "NA")
        x[s, c("bar_at", "eval_at")] <- "NA"
      }
    }
  }

  if (isTRUE(na.rm)) {
    x <- subset(x, !is.na(bar_at))
  }

  droplevels(x)
}

#' Main Effect Importance
#'
#' Extracts the exposure weighted variances of the most relevant statistic
#' (pd > pred > obs) from a "marginal" object. This serves as a simple "main effect"
#' importance measure.
#'
#' @param x Marginal object.
#' @param statistic The statistic used to calculate the variance for.
#' One of 'pd', 'pred', or 'obs'.
#' @seealso [postprocess()]
#' @export
#' @examples
#' fit <- lm(Sepal.Length ~ ., data = iris)
#' xvars <- colnames(iris)[-1]
#' M <- marginal(fit, v = xvars, data = iris, y = "Sepal.Length", breaks = 5)
#' main_effect_importance(M)
main_effect_importance <- function(x, statistic = NULL) {
  if (is.null(statistic)) {
    vars <- intersect(c("pd", "pred", "obs"), colnames(x[[1L]]))
    statistic <- vars[1L]
    message("Importance via exposure weighted variance of '", statistic, "'")
  }
  vapply(x, FUN = .one_imp, v = statistic, FUN.VALUE = numeric(1))
}

# Helper function
.one_imp <- function(x, v) {
  ok <- is.finite(x[[v]])
  stats::cov.wt(x[ok, v, drop = FALSE], x[["exposure"]][ok], method = "ML")$cov[1L, 1L]
}
