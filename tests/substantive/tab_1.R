# Substantive (published-value) checks for Table 1 — Blair et al. (APSR 2022)
#
# Benchmarks: APSR Table 1, "Assigned to treatment" row (coef, SE) and N.

tab_1_assigned_benchmark <- function() {
  data.frame(
    model = c(
      "unresolved_dum_ITT_res",
      "unresolved_dum_ITT_lead",
      "iverb_phys_dum_ITT_res",
      "iverb_phys_dum_ITT_lead"
    ),
    coef = c(-0.027, -0.093, 0.001, -0.051),
    se = c(0.033, 0.041, 0.010, 0.026),
    nobs = c(2673L, 1182L, 2673L, 1182L),
    stringsAsFactors = FALSE
  )
}

stata_benchmark_csv_path <- function(object) {
  `%||%` <- function(a, b) if (is.null(a)) b else a
  log_path <- NULL
  if (is.character(object) && length(object) == 1L && nzchar(object)) {
    log_path <- object
  } else if (is.list(object) && !is.data.frame(object)) {
    log_path <- object$output_path %||% object$smcl_path %||% NULL
    if (!is.null(log_path) && length(log_path) > 1L) log_path <- log_path[[1L]]
    log_path <- as.character(log_path)
  }
  if (is.null(log_path) || !nzchar(log_path)) {
    stop("Could not resolve Stata output path from replication result.", call. = FALSE)
  }
  file.path(dirname(log_path), "tab_1_benchmarks.csv")
}

check_stata_benchmark_csv <- function(path, spec, tolerance = 0.001) {
  if (!file.exists(path)) {
    stop("Benchmark CSV not found: ", path, call. = FALSE)
  }
  actual <- read.csv(path, stringsAsFactors = FALSE)
  required <- c("model", "coef", "se", "nobs")
  missing <- setdiff(required, names(actual))
  if (length(missing) > 0L) {
    stop("Benchmark CSV missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (nrow(actual) != nrow(spec)) {
    stop("Expected ", nrow(spec), " benchmark rows but got ", nrow(actual), ".", call. = FALSE)
  }

  failures <- character(0)
  for (i in seq_len(nrow(spec))) {
    row <- actual[actual$model == spec$model[[i]], , drop = FALSE]
    if (nrow(row) != 1L) {
      failures <- c(failures, paste0("model ", spec$model[[i]], ": not found in CSV"))
      next
    }
    if (abs(row$coef - spec$coef[[i]]) > tolerance) {
      failures <- c(
        failures,
        sprintf(
          "%s coef: expected %.3f, got %.3f",
          spec$model[[i]], spec$coef[[i]], row$coef
        )
      )
    }
    if (abs(row$se - spec$se[[i]]) > tolerance) {
      failures <- c(
        failures,
        sprintf(
          "%s se: expected %.3f, got %.3f",
          spec$model[[i]], spec$se[[i]], row$se
        )
      )
    }
    if (as.integer(row$nobs) != spec$nobs[[i]]) {
      failures <- c(
        failures,
        sprintf(
          "%s N: expected %d, got %d",
          spec$model[[i]], spec$nobs[[i]], as.integer(row$nobs)
        )
      )
    }
  }

  if (length(failures) > 0L) {
    stop(
      "Published benchmark check failed:\n",
      paste0(" - ", failures, collapse = "\n"),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

parse_tab_1_esttab_html <- function(html) {
  if (!is.character(html) || length(html) != 1L || !nzchar(html)) {
    stop("Expected formatted esttab HTML.", call. = FALSE)
  }
  html <- gsub("\n", "", html, fixed = TRUE)
  coef_row <- regmatches(
    html,
    regexpr(
      "Assigned to treatment</td><td>\\s*([-0-9.]+).*?</td><td>\\s*([-0-9.]+).*?</td><td>\\s*([-0-9.]+).*?</td><td>\\s*([-0-9.]+)",
      html,
      perl = TRUE
    )
  )
  if (!length(coef_row)) {
    stop("Could not parse 'Assigned to treatment' row from esttab HTML.", call. = FALSE)
  }
  coefs <- as.numeric(regmatches(
    coef_row[[1]],
    gregexpr("[-]?[0-9]+\\.[0-9]+", coef_row[[1]], perl = TRUE)
  )[[1]])
  obs_row <- regmatches(
    html,
    regexpr("Observations\\s*</td><td>\\s*([0-9]+).*?</td><td>\\s*([0-9]+).*?</td><td>\\s*([0-9]+).*?</td><td>\\s*([0-9]+)", html, perl = TRUE)
  )
  if (!length(obs_row)) {
    stop("Could not parse Observations row from esttab HTML.", call. = FALSE)
  }
  nobs <- as.integer(regmatches(
    obs_row[[1]],
    gregexpr("[0-9]+", obs_row[[1]], perl = TRUE)
  )[[1]])
  if (length(coefs) != 4L || length(nobs) != 4L) {
    stop("Parsed unexpected number of Table 1 columns.", call. = FALSE)
  }
  data.frame(
    model = c(
      "unresolved_dum_ITT_res",
      "unresolved_dum_ITT_lead",
      "iverb_phys_dum_ITT_res",
      "iverb_phys_dum_ITT_lead"
    ),
    coef = coefs,
    se = NA_real_,
    nobs = nobs,
    stringsAsFactors = FALSE
  )
}

check_tab_1_benchmark <- function(actual, spec, tolerance = 0.001) {
  failures <- character(0)
  for (i in seq_len(nrow(spec))) {
    row <- actual[actual$model == spec$model[[i]], , drop = FALSE]
    if (nrow(row) != 1L) {
      failures <- c(failures, paste0("model ", spec$model[[i]], ": not found"))
      next
    }
    if (abs(row$coef - spec$coef[[i]]) > tolerance) {
      failures <- c(
        failures,
        sprintf("%s coef: expected %.3f, got %.3f", spec$model[[i]], spec$coef[[i]], row$coef)
      )
    }
    if (!is.na(spec$se[[i]]) && !is.na(row$se) && abs(row$se - spec$se[[i]]) > tolerance) {
      failures <- c(
        failures,
        sprintf("%s se: expected %.3f, got %.3f", spec$model[[i]], spec$se[[i]], row$se)
      )
    }
    if (as.integer(row$nobs) != spec$nobs[[i]]) {
      failures <- c(
        failures,
        sprintf("%s N: expected %d, got %d", spec$model[[i]], spec$nobs[[i]], as.integer(row$nobs))
      )
    }
  }
  if (length(failures) > 0L) {
    stop(
      "Published benchmark check failed:\n",
      paste0(" - ", failures, collapse = "\n"),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

find_tab_1_benchmark_csv <- function(object) {
  path <- tryCatch(stata_benchmark_csv_path(object), error = function(e) NULL)
  if (!is.null(path) && file.exists(path)) {
    return(path)
  }
  roots <- unique(c(
    Sys.getenv("REPLICATE_STUDY_ROOT", unset = ""),
    Sys.getenv("REPLICATE_STUDY_DIR", unset = ""),
    getwd()
  ))
  roots <- roots[nzchar(roots)]
  for (root in roots) {
    for (rel in c("outputs/staging/tab_1_benchmarks.csv", "outputs/tab_1/tab_1_benchmarks.csv")) {
      candidate <- file.path(root, rel)
      if (file.exists(candidate)) {
        return(candidate)
      }
    }
  }
  NULL
}

#' @param object Stata replication result or formatted esttab HTML from `run_replication()`.
#' @param tolerance Numeric tolerance for coef/se (default 0.001).
substantive_check_tab_1 <- function(object, tolerance = 0.001) {
  spec <- tab_1_assigned_benchmark()
  if (is.character(object) && length(object) == 1L && grepl("Assigned to treatment", object, fixed = TRUE)) {
    actual <- parse_tab_1_esttab_html(object)
    return(check_tab_1_benchmark(actual, spec, tolerance = tolerance))
  }
  path <- find_tab_1_benchmark_csv(object)
  if (is.null(path)) {
    stop("Could not locate tab_1_benchmarks.csv for substantive check.", call. = FALSE)
  }
  actual <- read.csv(path, stringsAsFactors = FALSE)
  check_tab_1_benchmark(actual, spec, tolerance = tolerance)
}
