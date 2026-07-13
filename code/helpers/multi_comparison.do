
	* Benjamini-Hochberg (1995) - qvalues
	
		cap program drop bhcorr
		program define bhcorr 
			syntax, mat(string) newname(string) outmat(string)
			
			preserve 
			
				* Prepare matrix
				drop _all
				svmat `mat'
				
				* Store rownames
				loc rownames: rowfullnames `mat'
				loc c: word count `rownames'
				
				* Rename var and create rownames var
				rename `mat'1 `newname'
				gen rownames = ""
				
				* Replace each var name
				forvalues i = 1/`c' {
					replace rownames = "`: word `i' of `rownames''" in `i'
				}
				qui sum `newname'
				loc totalpvals = r(N)
		
				* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
				qui gen int original_sorting_order = _n
				qui sort `newname'
				qui gen int rank = _n if !missing(`newname')
						
				* Set the initial counter to 1 
				local qval = 1

				* Generate the variable that will contain the BH q-values
				gen bh95_qval = 1 if !missing(`newname')

				* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, 
				* then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses 
				* are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are 
				* rejected at q = 0.001.

				while `qval' > 0 {
					* Generate value qr/M
					qui gen fdr_temp = `qval'*rank/`totalpvals'
					
					* Generate binary variable checking condition p(r) <= qr/M
					qui gen reject_temp = (fdr_temp >= `newname') if !missing(fdr_temp)
					
					* Generate variable containing p-value ranks for all p-values that meet above condition
					qui gen reject_rank = reject_temp*rank
					
					* Record the rank of the largest p-value that meets above condition
					qui egen total_rejected = max(reject_rank)
					
					* A p-value has been rejected at level q if its rank is less than or equal to the rank 
					* of the max p-value that meets the above condition
					replace bh95_qval = `qval' if rank <= total_rejected & !missing(rank)
					
					* Reduce q by 0.001 and repeat loop
					quietly drop fdr_temp reject_temp reject_rank total_rejected
					local qval = `qval' - .001
				}
			
				quietly sort original_sorting_order
				display "Code has completed."
				display "Benjamini Hochberg (1995) q-vals are in variable 'bh95_qval'"
				display	"Sorting order is the same as the original vector of p-values"

				* Store as matrix
				mkmat `newname' bh95 original rank, mat(`outmat') rownames(rownames)
			
			restore
		end	
	
	* Benjamini-Hochberg (1995) - rejected at q level
		cap program drop bhcorralt
		program define bhcorralt 
			syntax, mat(string) newname(string) fdr(real) outmat(string)
			
			preserve 
			
				* Prepare matrix
				drop _all
				svmat `mat'
				
				* Store rownames
				loc rownames: rowfullnames `mat'
				loc c: word count `rownames'
				
				* Rename var and create rownames var
				rename `mat'1 `newname'
				gen rownames = ""
				
				* Replace each var name
				forvalues i = 1/`c' {
					replace rownames = "`: word `i' of `rownames''" in `i'
				}
				
				* Store number of hypotheses
				qui sum `newname'
				loc totalpvals = r(N)
		
				* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
				qui gen int original_sorting_order = _n
				qui sort `newname'
				qui gen int rank = _n if !missing(`newname')
						
				* Generate the variable that will contain the BH (1995) q-values
				gen bh95_cval = (rank*`fdr')/`totalpvals'  if !missing(`newname')
				
				gen ind_bh = (`newname' < bh)
					summ rank if ind == 1
					
					if `r(N)' > 0 {
						replace ind = 1 if rank <= `r(max)' & ind == 0
					}
					
				qui sort original_sorting_order
				display "Code has completed."
				display "Benjamini Hochberg (1995) q-vals are in variable 'bh95_qval'"
				display	"Sorting order is the same as the original vector of p-values"

				* Store as matrix
				mkmat `newname' original rank ind_bh, mat(`outmat') rownames(rownames)
			
			restore
		end	
		
	* Holms
		cap program drop holmscorr
		program define holmscorr 
			syntax, mat(string) newname(string) fwer(real) outmat(string)
			
			preserve 
			
				* Prepare matrix
				drop _all
				svmat `mat'
				
				* Store rownames
				loc rownames: rowfullnames `mat'
				loc c: word count `rownames'
				
				* Rename var and create rownames var
				rename `mat'1 `newname'
				gen rownames = ""
				
				* Replace each var name
				forvalues i = 1/`c' {
					replace rownames = "`: word `i' of `rownames''" in `i'
				}
				
				* Store number of hypotheses
				qui sum `newname'
				loc N = r(N)
		
				* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
				qui gen int original_sorting_order = _n
				qui sort `newname'
				qui gen int rank = _n if !missing(`newname')
						
				* Generate the variable that will contain the Holms (1979) correction value
				gen hb 	   = `fwer'/(`N' - rank + 1)
				gen hb_ind = (`newname' < hb)
				qui sort original_sorting_order
				
				display "Code has completed."
				display "Holms corrected pvalue are in variable hb"
				display	"Sorting order is the same as the original vector of p-values"

				* Store as matrix
				mkmat `newname' original rank hb hb_ind, mat(`outmat') rownames(rownames)
			
			restore
		end	
		

	cap program drop checkmark
	program define checkmark
		syntax, outcomes(string) mat1t(string) mat1s(string) mat2t(string) ///
								  mat2s(string) mat3t(string) mat3s(string) ename(string)
		
		loc n = `: word count `outcomes''	
		forvalues j = 1/`n' {
			
			estadd scalar qval = `mat1t'[`j',2], :`ename'`j'
			estadd scalar qval2 = `mat1s'[`j',2], :`ename'`j'
			
			loc qval3 = `mat2t'[`j',4]
				if `qval3' == 0 loc t ""
				if `qval3' == 1 loc t "\checkmark"
					estadd local text "`t'", :`ename'`j'
				
			loc qval4 = `mat2s'[`j',4]
				if `qval4' == 0 loc t ""
				if `qval4' == 1 loc t "\checkmark"
					estadd local text1 "`t'", :`ename'`j'
	
			loc qval5 = `mat3t'[`j',5]
				if `qval5' == 0 loc t ""
				if `qval5' == 1 loc t "\checkmark"
					estadd local text2 "`t'", :`ename'`j'

			loc qval6 = `mat3s'[`j',5]
				if `qval6' == 0 loc t ""
				if `qval6' == 1 loc t "\checkmark"
					estadd local text3 "`t'", :`ename'`j'		
		}

	end

	
	cap program drop checkmark_pi
	program define checkmark_pi
		syntax, outcomes(string) mat1t(string) mat2t(string) ///
								  mat3t(string) ename(string)
		
		loc n = `: word count `outcomes''	
		forvalues j = 1/`n' {
			
			estadd scalar qval = `mat1t'[`j',2], :`ename'`j'
			
			loc qval3 = `mat2t'[`j',4]
				if `qval3' == 0 loc t ""
				if `qval3' == 1 loc t "\checkmark"
					estadd local text "`t'", :`ename'`j'
	
			loc qval5 = `mat3t'[`j',5]
				if `qval5' == 0 loc t ""
				if `qval5' == 1 loc t "\checkmark"
					estadd local text2 "`t'", :`ename'`j'

		}

	end
