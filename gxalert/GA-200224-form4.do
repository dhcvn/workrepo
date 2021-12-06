mydir
myenvir
qui do "$codes\GA-setup.do"

cd "${gadataset}"
use "206-form4-20200225.dta", clear
append using "207-form4-20200225.dta"
append using "208-form4-20200225.dta"
append using "301-form4-20200225.dta"
append using "302-form4-20200225.dta"
append using "303-form4-20200225.dta"
append using "308-form4-20200225.dta"
append using "309-form4-20200225.dta"
append using "401-form4-20200225.dta"
append using "402-form4-20200225.dta"
append using "403-form4-20200225.dta"
append using "405-form4-20200225.dta"
append using "409-form4-20200225.dta"
append using "410-form4-20200225-1.dta"
append using "410-form4-20200225-2.dta"
append using "410-form4-20200225-3.dta"
append using "410-form4-20200225.dta"

ren (B C D E F G H I J)   ///
	(stt name mage fage add rsample hiv labcode xpertres)
ren (K L M N O P Q R S T) /// 
    (time1 time2 time3 time4 time5 time6 time7 time8 pid snote)
replace snote=U if mi(snote) & !mi(U)
compress
* Subset data set
drop U
drop if mi(stt)
drop if inlist(stt,"STT","(1)")
drop if stt=="Tuần 02: từ ngày 25/09/2019 đến 01/10/2019"
drop if stt=="Tuần 03: từ ngày 02/10/2019 đến 08/10/2019"

compress
save form4-200225-v1.dta, replace

*** Form4 lan2
use "${gadataset}101-form4-20200225_1.dta", clear
append using "${gadataset}101-form4-20200225_2.dta"
append using "${gadataset}101-form4-20200225_3.dta"
append using "${gadataset}101-form4-20200225_4.dta"
append using "${gadataset}102-form4-20200225_1.dta"
append using "${gadataset}102-form4-20200225_2.dta"
append using "${gadataset}102-form4-20200225_3.dta"
append using "${gadataset}102-form4-20200225_4.dta"
append using "${gadataset}102-form4-20200225_5.dta"
append using "${gadataset}204-form4-20200225_1.dta"
append using "${gadataset}204-form4-20200225_2.dta"
append using "${gadataset}204-form4-20200225_3.dta"
append using "${gadataset}204-form4-20200225_4.dta"
append using "${gadataset}205-form4-20200225_1.dta"
append using "${gadataset}209-form4-20200225_1.dta"
append using "${gadataset}209-form4-20200225_2.dta"
append using "${gadataset}209-form4-20200225_3.dta"
append using "${gadataset}209-form4-20200225_4.dta"
append using "${gadataset}210-form4-20200225_1.dta"
append using "${gadataset}304-form4-20200225_1.dta"
append using "${gadataset}304-form4-20200225_2.dta"
append using "${gadataset}304-form4-20200225_3.dta"
append using "${gadataset}304-form4-20200225_4.dta"
append using "${gadataset}304-form4-20200225_5.dta"
append using "${gadataset}307-form4-20200225_1.dta"
append using "${gadataset}307-form4-20200225_2.dta"
append using "${gadataset}307-form4-20200225_3.dta"
append using "${gadataset}307-form4-20200225_4.dta"
append using "${gadataset}307-form4-20200225_5.dta"
append using "${gadataset}310-form4-20200225_1.dta"
append using "${gadataset}404-form4-20200225_1.dta"
append using "${gadataset}404-form4-20200225_2.dta"
append using "${gadataset}404-form4-20200225_3.dta"
append using "${gadataset}404-form4-20200225_4.dta"
append using "${gadataset}404-form4-20200225_5.dta"
append using "${gadataset}406-form4-20200225_1.dta"
append using "${gadataset}406-form4-20200225_2.dta"
append using "${gadataset}406-form4-20200225_3.dta"
append using "${gadataset}406-form4-20200225_4.dta"
append using "${gadataset}407-form4-20200225_1.dta"
compress

gen nodrop=(uisdigit(B)|uisdigit(C))
drop if nodrop==0
tab madieutra if mi(B) & !mi(C)
gen needmove=(mi(B) & !mi(C))
replace B=C if needmove==1
replace C=D if needmove==1
replace D=E if needmove==1
replace E=F if needmove==1
replace F=G if needmove==1
replace G=H if needmove==1
replace H=I if needmove==1
replace I=J if needmove==1
replace J=K if needmove==1
replace K=L if needmove==1
replace L=M if needmove==1
replace M=N if needmove==1
replace N=O if needmove==1
replace O=P if needmove==1
replace P=Q if needmove==1
replace Q=R if needmove==1
replace R=S if needmove==1
replace S=T if needmove==1

ren (B C D E F G H I J)   ///
	(stt name mage fage add rsample hiv labcode xpertres)
ren (K L M N O P Q R S T) /// 
    (time1 time2 time3 time4 time5 time6 time7 time8 pid snote)
drop U-Z
compress
replace xpertres=trim(xpertres)
save "${gadataset}form4-200225-v2.dta", replace

import excel using "$gapro_data\Form4-additional.xlsx", first all clear
destring madieutra nodrop needmove, replace
append using "${gadataset}form4-200225-v1"
append using "${gadataset}form4-200225-v2"
compress
drop if mi(name)
destring stt, replace

tab madieutra, m
note _dta: Số liệu form4 tổng hợp \ $c_date
save "${gadataset}form4-${c_date}-combined.dta"


















