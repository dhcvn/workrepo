* Set up
mydir
qui do "$codes\GA-setup.do"
cap log close _all
log using "${gadoc}${syssep}${c_date}form1-combind", replace 

cd "${gadataset}"
use using 101-module1-form1-20200226.dta, clear
append using 102-module1-form1-20200226.dta
append using 203-module1-form1-20200226.dta
append using 204-module1-form1-20200226.dta
append using 205-module1-form1-20200226.dta
append using 206-module1-form1-20200226.dta
append using 207-module1-form1-20200226.dta
append using 209-module1-form1-20200226.dta
append using 210-module1-form1-20200226.dta
append using 301-module1-form1-20200226.dta
append using 302-module1-form1-20200226.dta
append using 303-module1-form1-20200226.dta
append using 304-module1-form1-20200226.dta
append using 307-module1-form1-20200226.dta
append using 308-module1-form1-20200226.dta
append using 309-module1-form1-20200226.dta
append using 310-module1-form1-20200226.dta
append using 401-module1-form1-20200226.dta
append using 402-module1-form1-20200226.dta
append using 403-module1-form1-20200226.dta
append using 405-module1-form1-20200226.dta
append using 406-module1-form1-20200226.dta
append using 406-module1-form1-20200226-1.dta
append using 406-module1-form1-20200226-2.dta
append using 406-module1-form1-20200226-3.dta
append using 407-module1-form1-20200226.dta
append using 408-module1-form1-20200226.dta
append using 409-module1-form1-20200226.dta
append using 410-module1-form1-20200226.dta

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
drop if B=="Mã Mô đun" & madieutra==101
drop if B=="711930" & madieutra==101
drop if B=="Tên TTB" | B=="(1)" | E=="Thời gian hiệu chuẩn theo yêu cầu"
drop if regexm(B,"1.2")
replace B=trim(B)
tab B
compress

qui count
foreach i of numlist 1/`=`r(N)'-1' {
	local genxpert1=B[`i']
	local genxpert2=B[`=`i'+1']
	if "`genxpert2'"=="" {
		replace B="`genxpert1'" in `=`i'+1'
	}
}
ren (B D E F G H) (thietbi mathietbi dset2018 ddid2018 dset2019 ddid2019)
tab madieutra if regexm(dset2018,"2019")
* lam sach bien thiet bi
replace thietbi="1" if regexm(thietbi,"1.")
replace thietbi="2" if regexm(thietbi,"2.")
destring thietbi, replace
la de thietbi 1 genxpert 2 nhietke
la val thietbi thietbi

append using form1-module-additional
missings tag mathietbi dset2018 ddid2018 dset2019 ddid2019, gen(mimathietbi)
drop if mimathietbi==5 & madieutra==204 & thietbi==1
sort madieutra
unique madieutra
compress
save form1-${c_date}-module-combined //filename: form1-20200226-module-combined.dta 
