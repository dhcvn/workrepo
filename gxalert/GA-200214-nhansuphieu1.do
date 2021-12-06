* Set up
mydir
qui do "$codes\GA-setup.do"

cd "${gadataset}"
use 101-nhansu-form1-20200224.dta, clear
append using 102-nhansu-form1-20200224.dta
append using 203-nhansu-form1-20200224.dta
append using 204-nhansu-form1-20200224.dta
append using 205-nhansu-form1-20200224.dta
append using 206-nhansu-form1-20200224.dta
append using 207-nhansu-form1-20200224.dta
append using 209-nhansu-form1-20200224.dta
append using 210-nhansu-form1-20200224.dta
append using 301-nhansu-form1-20200224.dta
append using 302-nhansu-form1-20200224.dta
append using 303-nhansu-form1-20200224.dta
append using 304-nhansu-form1-20200224.dta
append using 307-nhansu-form1-20200224.dta
append using 308-nhansu-form1-20200224.dta
append using 309-nhansu-form1-20200224.dta
append using 310-nhansu-form1-20200224.dta
append using 401-nhansu-form1-20200224.dta
append using 402-nhansu-form1-20200224.dta
append using 403-nhansu-form1-20200224.dta
append using 405-nhansu-form1-20200224.dta
append using 406-nhansu-form1-20200224.dta
append using 407-nhansu-form1-20200224.dta
append using 408-nhansu-form1-20200224.dta
append using 409-nhansu-form1-20200224.dta
append using 410-nhansu-form1-20200224.dta

replace H=G if madieutra==304|madieutra==209
replace G=F if madieutra==304|madieutra==209
replace F=E if madieutra==304|madieutra==209
replace E=D if madieutra==304|madieutra==209
replace C=B if madieutra==304|madieutra==209

** Drop not-used vars
drop B D A
ren (C E F G H) (name spec expmon doxpert certi)
drop if mi(name)
drop if regexm(name, "([0-9])")
drop if name=="Họ và tên"
compress
note _dta: Số liệu nhân sự lần 1, thiếu 201 202 208 305 306 404
save nhansu-form1-${c_date}-v1.dta, replace

import excel using "$form1\nhansu-form1-additional.xlsx", first all clear
note _dta: Số liệu nhân sự bổ sung 201 202 208 305 306 404
destring madieutra, replace
append using nhansu-form1-20200224-v1.dta

replace name=trim(name)
replace expmon=trim(expmon)
replace expmon=subinstr(expmon," tháng","",.)
destring expmon, gen(expmon_c) force

replace expmon_c=84 if madieutra==209 & mi(expmon_c)
replace expmon_c=real(ustrleft(expmon,1))*12+real(ustrright(expmon,1)) if madieutra==207 & mi(expmon_c)
replace expmon_c=real(ustrleft(expmon,1))*12 if madieutra==303 & mi(expmon_c)

compress
note _dta: so lieu tong hop day du 31 diem hien tai
save nhansu-form1-${c_date}-v2.dta
** 201 202, 404 là phiếu document, pheiesu 306 là tổng hợp vào 1 files excel duy nhất
use nhansu-form1-20200224-v2.dta, clear
