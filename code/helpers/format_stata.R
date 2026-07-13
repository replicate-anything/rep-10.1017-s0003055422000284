# Format Stata table output for Shiny display
# Study repo: rep-10.1017-s0003055422000284

`%||%` <- function(a, b) if (is.null(a)) b else a

stata_result_path_local <- function(object) {
  if (is.character(object) && length(object) == 1L && nzchar(object)) {
    return(object)
  }
  if (is.list(object) && !is.data.frame(object)) {
    path <- object$output_path %||% object$smcl_path %||% NULL
    if (!is.null(path)) {
      if (length(path) > 1L) path <- path[[1L]]
      path <- as.character(path)
      if (nzchar(path)) return(path)
    }
  }
  NULL
}

esttab_html_path <- function(log_path, table_stem = NULL) {
  if (is.null(log_path) || !nzchar(log_path)) {
    return(NULL)
  }
  dir <- dirname(log_path)
  if (!is.null(table_stem) && nzchar(table_stem)) {
    candidate <- file.path(dir, paste0(table_stem, ".html"))
    if (file.exists(candidate)) {
      return(candidate)
    }
  }
  base <- tools::file_path_sans_ext(basename(log_path))
  base <- sub("_stata$", "", base)
  candidate <- file.path(dir, paste0(base, "_table.html"))
  if (file.exists(candidate)) {
    return(candidate)
  }
  NULL
}

wrap_esttab_html <- function(html) {
  if (!nzchar(html)) {
    return('<p class="text-muted">No table output captured.</p>')
  }
  if (grepl("replication-table", html, fixed = TRUE)) {
    return(html)
  }
  paste0(
    '<div class="replication-table stata-esttab-output">',
    html,
    "</div>"
  )
}

read_esttab_html <- function(path) {
  html <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  wrap_esttab_html(html)
}

format_stata_log <- function(object, table_stem = NULL) {
  path <- stata_result_path_local(object)
  if (is.null(path) || !file.exists(path)) {
    stop("Stata output not found.")
  }

  esttab_path <- esttab_html_path(path, table_stem = table_stem)
  if (!is.null(esttab_path)) {
    return(read_esttab_html(esttab_path))
  }

  stop("esttab HTML not found for Stata table output.", call. = FALSE)
}

format_tab_1_stata <- function(object) format_stata_log(object, table_stem = "tab_1_table")
