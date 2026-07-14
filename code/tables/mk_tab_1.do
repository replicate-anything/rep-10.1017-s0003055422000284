* Table 1: Prevalence of unresolved and violent disputes
version 17
set more off, permanently

clear
use "${processed}/data.dta", clear
do "${maindir}/code/helpers/setup_analysis.do"

eststo clear

foreach y of varlist unresolved_dum iverb_phys_dum {
    areg `y' assigned $i_ctrls $c_ctrls [pweight = IPW] if leader==0, cl(centercode) ab(block)
    eststo `y'_ITT_res
    estadd local i_ctrls "Yes"
    estadd local c_ctrls "Yes"
    estadd local block_FE "Yes"
    estadd local weights "Yes"
    estadd local estimator "OLS"

    areg `y' assigned $i_ctrls $c_ctrls [pweight = IPW] if leader==1, cl(centercode) ab(block)
    eststo `y'_ITT_lead
    estadd local i_ctrls "Yes"
    estadd local c_ctrls "Yes"
    estadd local block_FE "Yes"
    estadd local weights "Yes"
    estadd local estimator "OLS"
}

esttab unresolved_dum_ITT_res unresolved_dum_ITT_lead iverb_phys_dum_ITT_res iverb_phys_dum_ITT_lead ///
    using "${result}/tab_1_table.html", ///
    html replace ///
    label b(3) se(3) eqlabels(none) ///
    mtitle("Residents" "Leaders" "Residents" "Leaders") ///
    mgroups("Any unresolved disputes" "Any violent disputes", pattern(1 0 1 0)) ///
    keep(assigned) ///
    star(* 0.10 ** 0.05 *** 0.01) nonotes ///
    scalars("i_ctrls Individual controls" "c_ctrls Community controls" "block_FE Block FE" "weights Weights" "estimator Estimator")

* Machine-readable benchmarks for substantive checks
file open bench using "${result}/tab_1_benchmarks.csv", write replace
file write bench "model,coef,se,nobs" _n
foreach m in unresolved_dum_ITT_res unresolved_dum_ITT_lead iverb_phys_dum_ITT_res iverb_phys_dum_ITT_lead {
    quietly est restore `m'
    file write bench ("`m',") %9.3f (_b[assigned]) (",") %9.3f (_se[assigned]) (",") (e(N)) _n
}
file close bench
