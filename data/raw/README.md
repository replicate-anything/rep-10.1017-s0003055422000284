# Data source (not stored in git)

Analysis data are fetched at run time from Harvard Dataverse by the `access_data` step.

| Field | Value |
|-------|-------|
| Paper DOI | [10.1017/S0003055422000284](https://doi.org/10.1017/S0003055422000284) |
| Dataverse DOI | [10.7910/DVN/OXSQMU](https://doi.org/10.7910/DVN/OXSQMU) |
| File | `data-1.tab` |
| Local output | `outputs/data.dta` (gitignored; produced by `access_data`) |

First live run needs network access. Re-run `access_data` or use `run_replication(doi, "tab_1", given = "nothing")` on a fresh clone.
