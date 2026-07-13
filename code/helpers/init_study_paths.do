* Locate study root and set path globals. Call at the top of every Stata runner.
* SSC packages: declare stata_packages: in replication.yml; maintainers run
* install_study_dependencies(doi) once. Live Run probes only.

version 17
set more off, permanently

local root "`c(pwd)'"
local root : subinstr local root "\" "/", all
while !fileexists("`root'/replication.yml") & "`root'" != "" {
    local parent = substr("`root'", 1, strrpos("`root'", "/") - 1)
    if "`parent'" == "`root'" | !nzchar("`parent'") continue, break
    local root "`parent'"
}

global maindir "`root'"
global rawdir "${maindir}/data/raw"
global processed "${maindir}/outputs"

if "${REPLICATE_STATA_RESULT}" != "" {
    global result "${REPLICATE_STATA_RESULT}"
}
else {
    global result "${maindir}/outputs/staging"
}

cap mkdir "${maindir}/data"
cap mkdir "${rawdir}"
cap mkdir "${processed}"
cap mkdir "${maindir}/outputs"
cap mkdir "${result}"
