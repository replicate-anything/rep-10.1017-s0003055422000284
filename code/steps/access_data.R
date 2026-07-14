# Access analysis data from Harvard Dataverse
# Study repo: rep-10.1017-s0003055422000284

read_dataverse_config <- function() {
  root <- Sys.getenv("REPLICATE_STUDY_ROOT", unset = "")
  if (!nzchar(root)) {
    root <- "."
  }
  cfg <- yaml::read_yaml(file.path(root, "replication.yml"))$dataverse
  if (is.null(cfg)) {
    stop("replication.yml must define a dataverse: block.", call. = FALSE)
  }
  cfg
}

make_access_data <- function() {
  cfg <- read_dataverse_config()
  server <- cfg$server %||% "dataverse.harvard.edu"
  dataset <- cfg$dataset
  filename <- cfg$file %||% cfg$filename
  if (is.null(dataset) || !nzchar(dataset)) {
    stop("dataverse.dataset is required in replication.yml.", call. = FALSE)
  }
  if (is.null(filename) || !nzchar(filename)) {
    stop("dataverse.file is required in replication.yml.", call. = FALSE)
  }

  # Deposit lists data-1.tab; metadata originalFileName is data-1.dta — fetch native Stata.
  dat <- dataverse::get_dataframe_by_name(
    filename = filename,
    dataset = dataset,
    original = TRUE,
    .f = haven::read_dta,
    server = server
  )

  root <- Sys.getenv("REPLICATE_STUDY_ROOT", unset = "")
  if (!nzchar(root)) {
    root <- "."
  }
  out_path <- file.path(root, "outputs", "data.dta")
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  haven::write_dta(dat, out_path)

  dat
}

`%||%` <- function(a, b) if (is.null(a)) b else a
