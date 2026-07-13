# Preventing Rebel Resurgence after Civil War (Blair et al., APSR 2022)

Folder-backed replication study for [replicateEverything](https://github.com/replicate-anything/replicateEverything).

- **Paper:** [10.1017/S0003055422000284](https://doi.org/10.1017/S0003055422000284)
- **Data:** [Harvard Dataverse 10.7910/DVN/OXSQMU](https://doi.org/10.7910/DVN/OXSQMU) — fetched by `access_data` (not committed)
- **Engines:** R (data access) + Stata 17+ (tables)

## Pipeline

| Step | Engine | Output |
|------|--------|--------|
| `access_data` | R | `outputs/data.dta` |
| `tab_1` | Stata | `outputs/tab_1.html` |

## Run locally

```r
options(
  replicateEverything.registry_root = "<monorepo>/registry",
  replicateEverything.study_folders_root = "<monorepo>"
)
devtools::load_all("<monorepo>/replicateEverything")

# Full chain (fetch + Table 1) on a fresh clone:
run_replication(
  "10.1017/S0003055422000284",
  "tab_1",
  given = "nothing",
  language = "stata",
  format = TRUE,
  install_deps = TRUE
)

# Or build all display outputs:
build_study_outputs(".", install_deps = TRUE)
```

Set `STATA` to your Stata executable if needed. First run downloads `data-1.tab` from Dataverse (internet required).

## Scope

Table 1 is wired. Additional main-text tables from the author `analysis.do` can be added as `tab_N` steps.
