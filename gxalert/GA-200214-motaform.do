* Set up
mydir
qui do "$codes\GA-setup.do"
cap log close _all
log using "${gadoc}${syssep}${c_date}form1-thongtinmodule", replace 
* Date: 21-02-2020. 24-02-2020
* Mo ta nhung file so lieu dang excel hoac xls
cd "$gapro_data"
use "20200221-motafolder.dta", clear

gen f4fullname="$form4"+"\"+filename
** Vì thông tin trong phiếu là phiếu mẫu nên không dùng thông tin này được
drop if inlist(madieutra,201,202,306,305) //form1
* drop if inlist(madieutra,201,202,209,305,306) //Giu lai nhung phieu trong form3


tab phieu, gen(phieuc)
numlabel, add mask(#.) force
drop if duoifile=="docx"

** Tao loop qua cac file
*** form1
/*
gsort -phieuc1 madieutra
qui count if phieuc1==1
foreach v of numlist 1/`r(N)' {
	local rdata=fullname[`v']
	l madieutra if fullname=="`rdata'"
	preserve
	qui import excel using "`rdata'", all clear
	qui d, varlist
	local v="`r(varlist)'"
	foreach i of local v {
		l `v' if regexm(`i',"Họ và tên") | regexm(`i', "2.  Thông tin về trang thiết bị")
	}
	restore
}
*/
* Import số liệu form1
/* run one time only because donot overwrite file
merge m:m madieutra phieu using phieu1-nhansu-range.dta,
tab _merge, m
gsort -_merge madieutra
qui count if _merge==3
local i=0
foreach v of numlist 1/`r(N)' {
	local  rdata=fullname[`v']
	local  irange=rangeimport1[`v']
	local  diemdt=madieutra[`v']
	preserve
	qui import excel using "`rdata'", all clear cellrange(`irange')
	qui gen madieutra=`diemdt'
	missings report
		if fileexists("${gadataset}\`diemdt'-nhansu-form1-${c_date}.dta")==1 | /// 
	   fileexists("${gadataset}\`diemdt'-nhansu-form1-${c_date}-`i'.dta")==1 {
		local i=`i'+1
		save "${gadataset}\`diemdt'-nhansu-form1-${c_date}-`i'.dta"
	}
	else {
		save "${gadataset}\`diemdt'-nhansu-form1-${c_date}.dta"
	}
	restore
}
*/
*** form 4
//Giữ lại những điểm có form4 chỉ chứa trong 1 sheet số liệu
*keep if inlist(madieutra,206,207,208,301,302,303,308,309,401,402,403,405,409,410) 
*keep if inlist(madieutra,101,102,204,205,209,210,304,307,310,404)
*keep if inlist(madieutra,101,102,204,205,209,210,304,307,310,404,406,407) //for form4
*keep if phieuc4==1
/*
gsort -phieuc4 madieutra
qui count if phieuc4==1
foreach v of numlist 1/`r(N)' {
	local rdata=f4fullname[`v']
	l madieutra if f4fullname=="`rdata'" 
	import excel using "`rdata'", describe
	
	*l madieutra if fullname=="`rdata'" & "`r(range_2)'"==""
}

foreach v of numlist 1/`r(N)' { 
	local rdata=f4fullname[`v']
	di "`rdata'"
	l madieutra if f4fullname=="`rdata'"
	preserve
	import excel using "`rdata'", describe
	import excel using "`rdata'", all clear
	qui d, varlist
	local v="`r(varlist)'"
		foreach i of local v {
		l `v' if regexm(`i',"Họ và tên")
	}
	restore
}

global fixedrange "B9:U550"
*/

/*
merge m:1 madieutra phieu using "phieu4-1sheet-range.dta"
gsort -phieuc4 madieutra
qui count if phieuc4==1
foreach v of numlist 1/`r(N)' {
	local  rdata=fullname[`v']
	local  irange=importrange[`v']
	local  diemdt=madieutra[`v']
	preserve
	qui import excel using "`rdata'", all clear cellrange(`irange')
	qui gen madieutra=`diemdt'
	missings report
	if fileexists("${gadataset}\`diemdt'-form4-${c_date}.dta")==1 | /// 
	   fileexists("${gadataset}\`diemdt'-form4-${c_date}-`i'.dta")==1 {
		local i=`i'+1
		save "${gadataset}\`diemdt'-form4-${c_date}-`i'.dta"
	}
	else {
		save "${gadataset}\`diemdt'-form4-${c_date}.dta"
	}
	restore
}
*local nsave=2
qui count if phieuc4==1
foreach v of numlist 1/`r(N)' {
	local  rdata=f4fullname[`v']
	local  diemdt=madieutra[`v']
	preserve
	qui import excel using "`rdata'", describe
	local nsheet=`r(N_worksheet)'
	foreach i of numlist 1/`nsheet' {
		local sheetname=r(worksheet_`i')
		qui import excel using "`rdata'", all clear sheet("`sheetname'")
		qui gen madieutra=`diemdt'
		local savefile="${gadataset}" + "`diemdt'" + "-form4-" + "${c_date}" + "_" + "`i'"
		
		cap save "`savefile'" 
		while _rc!=0 {
			local i=`i'+1
			local savefile="${gadataset}" + "`diemdt'" + "-form4-" + "${c_date}" + "_" + "`i'"
			cap save "`savefile'"
		}
	}
	restore
}
*/
/* Form 3 import
keep if phieuc3==1
sort madieutra
qui count if phieuc3==1
foreach v of numlist 1/`r(N)' {
	local rdata=fullname[`v']
	local fname=filename[`v']
	preserve
	di "`fname'"
	import excel using "`rdata'", describe
	restore
}
*/
* So lieu khong theo he thong nen khong the import chinh xac so lieu vao dc 
* form 1: thông tin về module Xpert
keep if phieuc1==1
qui count
/*
foreach v of numlist 1/`r(N)' {
	local rdata=fullname[`v']
	l madieutra if fullname=="`rdata'"
	preserve
	qui import excel using "`rdata'", all clear
	qui d, varlist
	local v="`r(varlist)'"
	foreach i of local v {
		l `v' if regexm(`i',"Tên TTB") | regexm(`i', "1.2.Thông tin về mô đun Xpert MTB/RIF")
	}
	restore
}

merge m:1 madieutra using "phieu1-module-range.dta", nogen
ren importrange rangeimport2
replace rangeimport2="B22:H39" if madieutra==203

qui count
foreach v of numlist 1/`r(N)' {
	local  rdata=fullname[`v']
	local  irange=rangeimport2[`v']
	local  diemdt=madieutra[`v']
	preserve
	qui import excel using "`rdata'", all clear cellrange(`irange')
	qui gen madieutra=`diemdt'
		if fileexists("${gadataset}\`diemdt'-module1-form1-${c_date}.dta")==1 | /// 
	       fileexists("${gadataset}\`diemdt'-module1-form1-${c_date}-`i'.dta")==1 {
		local i=`i'+1
		save "${gadataset}\`diemdt'-module1-form1-${c_date}-`i'.dta"
	}
	else {
		save "${gadataset}\`diemdt'-module1-form1-${c_date}.dta"
	}
	restore
}
*/

foreach v of numlist 1/`r(N)' {
	local rdata=fullname[`v']
	l madieutra if fullname=="`rdata'"
	preserve
	import excel using "`rdata'", describe
	qui import excel using "`rdata'", all clear
	qui d, varlist
	local v="`r(varlist)'"
	foreach i of local v {
		l `v' if regexm(`i',"Mã Mô đun")
	}
	restore
}
merge m:1 madieutra using "phieu1-module-range.dta", nogen
qui count
foreach v of numlist 1/`r(N)' {
	local  rdata=fullname[`v']
	local  irange=rangeimport3[`v']
	local  diemdt=madieutra[`v']
	preserve
	qui import excel using "`rdata'", all clear cellrange(`irange')
	qui gen madieutra=`diemdt'
		if fileexists("${gadataset}\`diemdt'-module2-form1-${c_date}.dta")==1 | /// 
	       fileexists("${gadataset}\`diemdt'-module2-form1-${c_date}-`i'.dta")==1 {
		local i=`i'+1
		save "${gadataset}\`diemdt'-module2-form1-${c_date}-`i'.dta"
	}
	else {
		save "${gadataset}\`diemdt'-module2-form1-${c_date}.dta"
	}
	restore
}

log close _all
