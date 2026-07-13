DOI <- "10.1017/S0003055422000284"
FOLDER <- "10.1017_s0003055422000284"
STUDY_REPO <- "replicate-anything/rep-10.1017-s0003055422000284"

study_test_context <- function() {
  study_root <- normalizePath(
    testthat::test_path("..", ".."),
    winslash = "/",
    mustWork = FALSE
  )
  registry_root <- normalizePath(
    file.path(study_root, "..", "registry"),
    winslash = "/",
    mustWork = FALSE
  )
  monorepo_root <- normalizePath(
    file.path(study_root, ".."),
    winslash = "/",
    mustWork = FALSE
  )

  local_index <- data.frame(
    folder = FOLDER,
    handle = "preventing-rebel-resurgence-colombia",
    doi = paste0("https://doi.org/", DOI),
    title = "Preventing Rebel Resurgence after Civil War",
    journal = "APSR",
    year = 2022,
    authors = "Blair, Moscoso, Vargas Castillo, Weintraub",
    repo = STUDY_REPO,
    stringsAsFactors = FALSE
  )

  list(
    study_root = study_root,
    registry_root = registry_root,
    monorepo_root = monorepo_root,
    local_index = local_index
  )
}

with_study_options <- function(ctx, expr) {
  withr::with_options(
    list(
      replicateEverything.registry_root = ctx$registry_root,
      replicateEverything.index = ctx$local_index,
      replicateEverything.use_sibling_packages = TRUE,
      replicateEverything.study_folders_root = ctx$monorepo_root
    ),
    expr
  )
}

test_that("replication.yml lists access_data and Table 1", {
  testthat::skip_if_not_installed("yaml")
  ctx <- study_test_context()
  yaml <- yaml::read_yaml(file.path(ctx$study_root, "replication.yml"))
  ids <- vapply(yaml$steps, function(x) as.character(x$id), character(1))
  testthat::expect_true("access_data" %in% ids)
  testthat::expect_true("tab_1" %in% ids)
  testthat::expect_true(!is.null(yaml$dataverse$dataset))
})

test_that("dataverse config documents Harvard deposit", {
  testthat::skip_if_not_installed("yaml")
  ctx <- study_test_context()
  yaml <- yaml::read_yaml(file.path(ctx$study_root, "replication.yml"))
  testthat::expect_equal(yaml$dataverse$file, "data-1.tab")
})

test_that("substantive benchmark spec has four models", {
  source(file.path(study_test_context()$study_root, "tests", "substantive", "tab_1.R"), local = TRUE)
  bench <- tab_1_assigned_benchmark()
  testthat::expect_equal(nrow(bench), 4L)
})
