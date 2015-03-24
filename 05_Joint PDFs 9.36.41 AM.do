************************************************************************************************************
* Estimates and graphs joint PDFs of parameters.
* IMPORTANT: You need to install mylabels, spgrid, spkde, spmap, and tddens to run this program.
* Written by Kirill D on 11/13/14.
************************************************************************************************************

clear all
set more off
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Survey Results with Estimates.dta"
*keep if cohort == 1 //specify cohort
drop wbeta_effort wdelta_effort wbeta_hat_effort wbeta_stair wdelta_stair wbeta_hat_stair //drop winsorized parameters in permanent dataset
preserve

**************************************************************
* Joint PDF of Alpha and Beta_stair.
**************************************************************

/* Normalize variables in the range [0,1]. */
summarize alpha beta_stair
clonevar x = alpha
clonevar y = beta_stair
replace x = (x-0) / (3-0) //subtract min value in numerator and divide by difference between max and min values
replace y = (y-.5) / (2.25-.5)
mylabels 0(.5)3, myscale((@-0) / (3-0)) local(XLAB)
mylabels .5(.25)2.25, myscale((@-.5) / (2.25-.5)) local(YLAB)
keep x y
save "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta", replace

/* Generate a 100x100 grid. */
spgrid, shape(hexagonal) xdim(100)   ///
 xrange(0 1) yrange(0 1)            ///
 dots replace                       ///
 cells("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta")          ///
 points("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta")

/* Estimate the bivariate probability density function. */
spkde using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta",   ///
 xcoord(x) ycoord(y)              ///
 bandwidth(fbw) fbw(0.1) dots     ///
 saving("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", replace)

/* Draw the density plot. */
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", clear
recode lambda (.=0)
spmap lambda using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta",      ///
 id(spgrid_id) clnum(20) fcolor(Rainbow)   ///
 ocolor(none ..) legend(off)               ///
 point(data("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta") x(x) y(y))           ///
 freestyle aspectratio(1)                  ///
 xtitle(" " "Alpha")               ///
 xlab(`XLAB')                              ///
 ytitle("Beta_stair" " ")                       ///
 ylab(`YLAB', angle(0))					///
 title("Joint PDF of Alpha and Beta_stair")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Alpha vs Beta stair.pdf", replace

**************************************************************
* ZOOMED Joint PDF of Alpha and Beta_stair.
**************************************************************
restore
preserve
drop if alpha > 1
drop if beta_stair < .5 | beta_stair > 1.5

/* Use tddens to do one version of the joint PDF. */
tddens alpha beta_stair, sgraph title("Joint PDF of Alpha and Beta_stair") sgopt(title("Surface Plot of Alpha and Beta_stair"))
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Tddens Beta stair 1.pdf", name(h) replace
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Tddens Beta stair 2.pdf", name(f) replace
graph drop _all

/* Normalize variables in the range [0,1]. */
summarize alpha beta_stair
clonevar x = alpha
clonevar y = beta_stair
replace x = (x-0) / (1-0) //subtract min value in numerator and divide by difference between max and min values
replace y = (y-.5) / (1.5-.5)
mylabels 0(.25)1, myscale((@-0) / (1-0)) local(XLAB)
mylabels .5(.25)1.5, myscale((@-.5) / (1.5-.5)) local(YLAB)
keep x y
save "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta", replace

/* Generate a 100x100 grid. */
spgrid, shape(hexagonal) xdim(100)   ///
 xrange(0 1) yrange(0 1)            ///
 dots replace                       ///
 cells("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta")          ///
 points("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta")

/* Estimate the bivariate probability density function. */
spkde using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta",   ///
 xcoord(x) ycoord(y)              ///
 bandwidth(fbw) fbw(0.1) dots     ///
 saving("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", replace)

/* Draw the density plot. */
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", clear
recode lambda (.=0)
spmap lambda using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta",      ///
 id(spgrid_id) clnum(20) fcolor(Rainbow)   ///
 ocolor(none ..) legend(off)               ///
 point(data("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta") x(x) y(y))           ///
 freestyle aspectratio(1)                  ///
 xtitle(" " "Alpha")               ///
 xlab(`XLAB')                              ///
 ytitle("Beta_stair" " ")                       ///
 ylab(`YLAB', angle(0))					///
 title("Joint PDF of Alpha and Beta_stair (Zoomed)")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Alpha vs Beta stair (Zoomed).pdf", replace

**************************************************************
* Joint PDF of Alpha and Beta_effort.
**************************************************************
restore
preserve

/* Normalize variables in the range [0,1]. */
winsor beta_effort, gen(wbeta_effort) p(0.025) //need to top/bottom-code extreme outliers in beta_effort
summarize alpha wbeta_effort
clonevar x = alpha
clonevar y = wbeta_effort
replace x = (x-0) / (3-0) //subtract min value in numerator and divide by difference between max and min values
replace y = (y-.25) / (2.75-.25)
mylabels 0(1)3, myscale((@-0) / (3-0)) local(XLAB)
mylabels .25(.5)2.75, myscale((@-.25) / (2.75-.25)) local(YLAB)
keep x y
save "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta", replace

/* Generate a 100x100 grid. */
spgrid, shape(hexagonal) xdim(100)   ///
 xrange(0 1) yrange(0 1)            ///
 dots replace                       ///
 cells("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta")          ///
 points("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta")

/* Estimate the bivariate probability density function. */
spkde using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta",   ///
 xcoord(x) ycoord(y)              ///
 bandwidth(fbw) fbw(0.1) dots     ///
 saving("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", replace)

/* Draw the density plot. */
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", clear
recode lambda (.=0)
spmap lambda using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta",      ///
 id(spgrid_id) clnum(20) fcolor(Rainbow)   ///
 ocolor(none ..) legend(off)               ///
 point(data("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta") x(x) y(y))           ///
 freestyle aspectratio(1)                  ///
 xtitle(" " "Alpha")               ///
 xlab(`XLAB')                              ///
 ytitle("Beta_effort, Winsorized fraction .025" " ")                       ///
 ylab(`YLAB', angle(0))				///
 title("Joint PDF of Alpha and Beta_effort")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Alpha vs Beta effort.pdf", replace

**************************************************************
* ZOOMED Joint PDF of Alpha and Beta_effort.
**************************************************************
restore
preserve
drop if alpha > 1
drop if beta_effort < .5 | beta_effort > 1.5

/* Use tddens to do one version of the joint PDF. */
tddens alpha beta_effort, sgraph title("Joint PDF of Alpha and Beta_effort") sgopt(title("Surface Plot of Alpha and Beta_effort"))
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Tddens Beta effort 1.pdf", name(h) replace
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Tddens Beta effort 2.pdf", name(f) replace
graph drop _all

/* Normalize variables in the range [0,1]. */
summarize alpha beta_effort
clonevar x = alpha
clonevar y = beta_effort
replace x = (x-0) / (1-0) //subtract min value in numerator and divide by difference between max and min values
replace y = (y-.5) / (1.5-.5)
mylabels 0(.25)1, myscale((@-0) / (1-0)) local(XLAB)
mylabels .5(.25)1.5, myscale((@-.5) / (1.5-.5)) local(YLAB)
keep x y
save "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta", replace

/* Generate a 100x100 grid. */
spgrid, shape(hexagonal) xdim(100)   ///
 xrange(0 1) yrange(0 1)            ///
 dots replace                       ///
 cells("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta")          ///
 points("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta")

/* Estimate the bivariate probability density function. */
spkde using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridPoints.dta",   ///
 xcoord(x) ycoord(y)              ///
 bandwidth(fbw) fbw(0.1) dots     ///
 saving("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", replace)

/* Draw the density plot. */
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-Kde.dta", clear
recode lambda (.=0)
spmap lambda using "~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/2D-GridCells.dta",      ///
 id(spgrid_id) clnum(20) fcolor(Rainbow)   ///
 ocolor(none ..) legend(off)               ///
 point(data("~/Dropbox/EGBias/ALP Data/Analysis/Data/Joint PDF Working Files/xy.dta") x(x) y(y))           ///
 freestyle aspectratio(1)                  ///
 xtitle(" " "Alpha")               ///
 xlab(`XLAB')                              ///
 ytitle("Beta_effort" " ")                       ///
 ylab(`YLAB', angle(0))					///
 title("Joint PDF of Alpha and Beta_effort (Zoomed)")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Joint PDFs/Alpha vs Beta effort (Zoomed).pdf", replace
