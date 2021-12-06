mydir
qui do "$codes\GA-setup.do"
cap log close _all
log using "${gadoc}${syssep}${c_date}form1-combind-v2", replace 

cd "${gadataset}"
use using 101-module2-form1-20200226.dta, clear
append using 102-module2-form1-20200226.dta
append using 203-module2-form1-20200226.dta
append using 204-module2-form1-20200226.dta
append using 205-module2-form1-20200226.dta
append using 206-module2-form1-20200226.dta
append using 207-module2-form1-20200226.dta
append using 209-module2-form1-20200226.dta
append using 210-module2-form1-20200226.dta
append using 301-module2-form1-20200226.dta
append using 302-module2-form1-20200226.dta
append using 303-module2-form1-20200226.dta
append using 304-module2-form1-20200226.dta
append using 307-module2-form1-20200226.dta
append using 308-module2-form1-20200226.dta
append using 309-module2-form1-20200226.dta
append using 310-module2-form1-20200226.dta
append using 401-module2-form1-20200226.dta
append using 402-module2-form1-20200226.dta
append using 403-module2-form1-20200226.dta
append using 405-module2-form1-20200226.dta
append using 406-module2-form1-20200226.dta
append using 406-module2-form1-20200226-1.dta
append using 406-module2-form1-20200226-2.dta
append using 406-module2-form1-20200226-3.dta
append using 407-module2-form1-20200226.dta
append using 408-module2-form1-20200226.dta
append using 409-module2-form1-20200226.dta
append using 410-module2-form1-20200226.dta

* move data 
replace H=G if inlist(madieutra,209,304)
replace G=F if inlist(madieutra,209,304)
replace F=E if inlist(madieutra,209,304)
replace E=D if inlist(madieutra,209,304)
replace D=C if inlist(madieutra,209,304)
replace B=A if inlist(madieutra,209,304)

* Drop blank vars
drop I J C A
missings dropobs B D E F G H, force
replace B=trim(B)
drop if inlist(B,"Mã Mô đun","(1)","1.2.Thông tin về mô đun Xpert MTB/RIF")

gen todrop=(mi(B))
li if todrop
drop if todrop
drop todrop
compress

ren (B D E F G H) (mamodule tlapdat tsudung tsuco tmodulemoi mamodulethaythe)
append using form1-module2-additional.dta
compress
save form1-20200226-module2-combined.dta
log close _all




