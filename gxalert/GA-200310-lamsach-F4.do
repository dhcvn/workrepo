* Date: 2020 03 10
* Lam sach ngay thang cho Form 4
macro drop all

global time1=clock("`c(current_date)' `c(current_time)'","DMYhms") 
local username=c(username)
if "`username'"=="DaoHuyCu" mydir2
else mydir
myenvir
global username `c(username)'
global codes="C:\Users\"+"$username"+"\Dropbox\Mywork\2.Codes"
if "`username'"=="DaoHuyCu" {
	qui do "$codes\GA-setup2.do"
	cap log close
	*local logfile="$gadoc"+
	log using "$garesult$system_sep$c_date-log-ls.txt", replace text
}
else {
	qui do "$codes\GA-setup.do"
	cap log close
	log using "$gadoc$system_sep$c_date-log-ls1.txt", replace text
}
cd "${gadataset}"
use form4-20200304-combined.dta, clear

la var stt       "Số thứ tự"
la var name      "Tên bệnh nhân"
la var mage      "Tuổi của nam"
la var fage      "Tuổi của nữ"
la var add       "Địa chỉ của BN"
la var rsample   "Nơi gửi mẫu"
la var hiv       "Tình trạng HIV"
la var labcode   "Mã xét nghiệm"
la var xpertres  "Kết quả xét nghiệm"
la var time1     "Thời gian lấy mẫu"
la var time2     "Thời gian nhận mẫu"
la var time3     "Thời gian bắt đầu xét nghiệm"
la var time4     "Thời gian kết thúc xét nghiệm"
la var time5     "Ban hành kết quả"
la var time6     "Nơi gửi nhận được kết quả"
la var time7     "BS có kết quả"
la var time8     "BN được điều trị"
la var pid       "Mã bệnh nhân/Số ĐK ĐT"
la var snote     "Ghi chú"
la var madieutra "Mã điểm điều tra"

gen id=_n
* name
codebook name
replace name=trim(name)

* age
codebook mage fage
replace mage=trim(mage)
replace fage=trim(fage)
gen checkage=(!mi(mage)* !mi(fage))
qui tab mage if checkage==1 & mage<fage
qui tab fage if checkage==1 & mage>fage
l   madieutra stt name if checkage==1 & mage<fage & mage=="20/02/2019"
//Truong hop nay la nam, 8 thang tuoi ten la nguyen duc truong an
qui tab mage if regexm(strlower(mage),"th")
qui tab fage if regexm(strlower(fage),"th")

gen tuoitrecon=""
replace tuoitrecon=mage if regexm(strlower(mage),"th")
replace tuoitrecon=fage if regexm(strlower(fage),"th")
replace tuoitrecon=subinstr(strlower(tuoitrecon),"th","",.)
replace tuoitrecon=string(round(real(tuoitrecon)/12,.1)) if tuoitrecon!=""

* gender 0=female, 1=male
gen gender=(fage=="0" | mi(fage)) 
replace gender=1 if checkage==1 & mage<fage & mage=="20/02/2019"
qui tab gender if mi(mage) & mi(fage)
* Correct gender based on name if missing male age and female age
replace gender=0 if mi(mage) & mi(fage) & regexm(strlower(name),"thị")
replace gender=0 if inlist(id,1108,1109)

gen age=. //18 cases missing age
replace age=real(mage) if gender==1 & strlen(mage)<3 
replace age=2019-real(mage) if gender==1 & mi(tuoitrecon) & strlen(mage)==4 & mi(age)
replace age=real(subinstr(strlower(mage),"t","",.)) if regexm(strlower(mage),"t$") & mi(age)
replace age=round((d(17oct2019)-date(mage,"DMY"))/365.25,.1) if mi(age) & gender==1 & tuoitrecon=="" & !mi(mage) & mi(age)

replace age=real(fage) if gender==0 & strlen(fage)<3 & mi(age)
replace age=real(subinstr(strlower(fage),"t","",.)) if regexm(strlower(fage),"t$") & mi(age)
replace age=real(fage) if gender==0 & strlen(fage)==3 & mi(age) & uisdigit(fage)
replace age=2019-real(fage) if gender==0 & mi(tuoitrecon) & strlen(fage)==4 & mi(age)
replace age=round((d(17oct2019)-date(fage,"DMY"))/365.25,.1) if gender==0 & mi(age) & mi(tuoitrecon)

replace age=real(tuoitrecon) if mi(age) & !mi(tuoitrecon)
la var age "Age of patient"

* address, rsample, lab code
replace add=trim(add)
replace rsample=trim(rsample)
replace labcode=trim(labcode)

* Xpert result, missing xpertres 10 
replace xpertres=trim(xpertres)
replace xpertres=ustrlower(xpertres)

la de mtb 0 negative 1 positive 2 trace 3 ERROR 9 Unknown, replace
la de rif 0 NO 1 RR 2 Indeterminate, replace

gen mtb=.
la var mtb "
replace mtb=1 if regexm(ustrlower(xpertres),"^có")
replace mtb=2 if mtb==1 & regexm(ustrlower(xpertres),"vết")
replace mtb=1 if regexm(ustrlower(xpertres),"(^mtb|^tb)") & regexm(ustrlower(xpertres),"[+]")
replace mtb=2 if regexm(ustrlower(xpertres),"(^mtb|^tb)") & regexm(ustrlower(xpertres),"vết") & mi(mtb)
replace mtb=0 if regexm(ustrlower(xpertres),"(^mtb|^tb)") & mi(mtb)
replace mtb=0 if regexm(ustrlower(xpertres),"^không|^khồng") & mi(mtb)
replace mtb=0 if regexm(xpertres,"không có mtb") &  mi(mtb)
replace mtb=2 if regexm(ustrlower(xpertres),"vết|trace")  & mi(mtb)
replace mtb=0 if regexm(ustrlower(xpertres),"âm|âm tính") & mi(mtb)
replace mtb=1 if regexm(ustrlower(xpertres),"có") & mi(mtb)
//?error/có mtb va kháng rif  hoi lai chi Van ve nhung truong hop ntn
replace mtb=1 if inlist(id,3677,2381)
replace mtb=9 if inlist(xpertres,"kxđ","ko xác định","no result")
replace mtb=3 if mi(mtb) & !mi(xpertres)
la val mtb mtb

* rif
gen rif=.
la var rif "Rifampicin resistance result"
replace rif=0 if regexm(ustrlower(xpertres),"(^mtb|^tb)") & regexm(xpertres,"-") & mtb==1
replace rif=2 if regexm(ustrlower(xpertres),"kxđ|kxđk") & mtb==1 & mi(rif)
replace rif=1 if inlist(xpertres,"mtb+/r+","tb+/r+","mtb (+)/r(+)","mtb (+) /rif (+)")
replace rif=2 if mtb==1 & mi(rif) & regexm(ustrlower(xpertres),"(^mtb|^tb)")
replace rif=1 if mtb==1 & mi(rif) & !regexm(ustrlower(xpertres),"không")
replace rif=2 if mtb==1 & mi(rif) & regexm(ustrlower(xpertres),"không xđk|không xác định")
replace rif=2 if id==2381
replace rif=0 if mtb==1 & mi(rif)
replace rif=2 if mtb==2 & mi(rif)
la val rif rif

qui tab xpertres if mtb==1 & mi(rif) & regexm(ustrlower(xpertres),"không xđk|không xác định")

* Lam sach thoi gian
foreach v of varlist time1-time8 {
	replace `v'=trim(`v')
}

* time1 51 truong hop missing
* Cleaning step base on word count of the time
qui tab time1 if wordcount(time1)==1 
qui tab time1 if wordcount(time1)==2
qui tab time1 if wordcount(time1)==3
qui tab time1 if wordcount(time1)==4
replace time1=subinstr(time1,"  "," ",.)

* word count==3
replace time1=regexr(time1,"[g|h|:] ","h") if wordcount(time1)==3
replace time1=regexr(time1,"[g|h|:] ","h") if inlist(id, ///
1112, ///
1113, ///
1114, ///
1115, ///
1117, ///
1118, ///
1119, ///
1120, ///
1121, ///
1122)
replace time1=regexr(time1,"ngày ","") if wordcount(time1)==3
replace time1="6h18 18/9" if time1=="6 18 18/9" & wordcount(time1)==3

gen time1c=""
replace time1c=word(time1,1) if wordcount(time1)==2 & regexm(strlower(word(time1,1)),"h|:")
replace time1c=word(time1,2) if wordcount(time1)==2 & regexm(strlower(word(time1,2)),"h|:")
replace time1c="14h00" if mi(time1c) & wordcount(time1)==2 //ID=1699
replace time1c="8h07"  if id==2138 & time1c=="h07/10/19"

gen time1d=""
replace time1d=word(time1,2) if wordcount(time1)==2 & regexm(strlower(word(time1,1)),"h|:")
replace time1d=word(time1,1) if wordcount(time1)==2 & regexm(strlower(word(time1,2)),"h|:")
replace time1d="15/10" if id==1699

replace time1c=subinstr(time1c,"/","",.) if regexm(time1c,"/$")
replace time1c=subinstr(time1c,"p","",.) if regexm(time1c,"p$")
replace time1d=regexr(time1d,"[(]","")
replace time1d=regexr(time1d,"[)]","")
replace time1d="1/10" if time1d=="n1/10"
replace time1d="17/9" if time1d=="179"
replace time1d="5/10" if time1d=="510"
replace time1d="8/10" if time1d=="810"
replace time1d="15/10" if time1d=="1510" & id==608
replace time1d=time1d+"/10" if strlen(time1d)<3 & !mi(time1d)
replace time1d=subinstr(time1d,".","/",.)
replace time1d=regexr(time1d,"/19$","/2019")
replace time1d=regexr(time1d,"2020$","2019")
replace time1d="26/09/2019" if id==2122 & time1d=="26/09/20"
replace time1d="26/09/2019" if time1d=="26/09/9" & inlist(id,2119,2120)
replace time1d=time1d+"/2019" if !regexm(time1d,"2019$") & !mi(time1d)

* wordcount time1==1
global rege1 "([0-9]+:[0-9]+)[/]([0-9]+$)"
*[0-9]+[:][0-9]+[/][0-9]$
qui tab time1 if regexm(time1,"$rege1") & wordcount(time1)==1
replace time1c=regexs(1) if regexm(time1,"$rege1") & wordcount(time1)==1 & mi(time1c)
replace time1d=regexs(2) if regexm(time1,"$rege1") & wordcount(time1)==1 & mi(time1d)

global rege1 "([0-9]+:[0-9]+)/([0-9]+/[0-9]+/[0-9]+$)"
qui tab time1 if regexm(time1,"$rege1") & wordcount(time1)==1
replace time1c=regexs(1) if regexm(time1,"$rege1") & wordcount(time1)==1
replace time1d=regexs(2) if regexm(time1,"$rege1") & wordcount(time1)==1

global rege2 "([0-9]+[h][0-9]+)[(]([0-9]+[/][0-9]+)[)]"
qui tab time1 if regexm(time1,"$rege2") & wordcount(time1)==1
replace time1c=regexs(1) if regexm(time1,"$rege2") & wordcount(time1)==1 & mi(time1c)
replace time1d=regexs(2) if regexm(time1,"$rege2") & wordcount(time1)==1 & mi(time1d)

global rege3 "([0-9]+[h][0-9][0-9])[/]([0-9]+)"
qui tab time1 if regexm(time1, "$rege3") & mi(time1c)
replace time1c=regexs(1) if regexm(time1, "$rege3") & wordcount(time1)==1 & mi(time1c)
replace time1d=regexs(2) if regexm(time1, "$rege3") & wordcount(time1)==1 & mi(time1d)

global rege4 "([0-9]+[h])[(]([0-9]+[/][0-9]+)[)]"
replace time1c=regexs(1) if regexm(time1,"$rege4") & wordcount(time1)==1 & mi(time1c)
replace time1d=regexs(2) if regexm(time1,"$rege4") & wordcount(time1)==1 & mi(time1d)

global rege5 "[0-9]+[h][0-9]+$"
qui tab time1 if regexm(time1,"$rege5") & mi(time1d)
replace time1c=regexs(0) if regexm(time1,"$rege5") & wordcount(time1)==1 & mi(time1c)
replace time1d="" if time1d!="" & regexm(time1,"$rege5") & wordcount(time1)==1 & mi(time1c)

replace time1="6h20,17/9/2019" if time1=="6h20,17/9/201"
global rege6 "([0-9]+[h][0-9]+),([0-9]+/[0-9]+/[0-9]+$)"
qui tab time1 if regexm(time1, "$rege6") & mi(time1c)
replace time1c=regexs(1) if regexm(time1, "$rege6") & wordcount(time1)==1 & mi(time1c) 
replace time1d=regexs(2) if regexm(time1, "$rege6") & wordcount(time1)==1 & mi(time1d)

global rege7 "([0-9]+[h]),([0-9]+/[0-9]+/[0-9]+$)"
qui tab time1 if regexm(time1,"$rege7") & mi(time1c)
replace time1c=regexs(1) if regexm(time1,"$rege7") & wordcount(time1)==1 & mi(time1c)
replace time1d=regexs(2) if regexm(time1,"$rege7") & wordcount(time1)==1 & mi(time1d)

replace time1c=time1 if regexm(time1,"p$") & wordcount(time1)==1 & mi(time1c)
replace time1c=time1 if regexm(time1,"h$") & wordcount(time1)==1 & mi(time1c)
replace time1c=time1 if regexm(time1,"g$") & wordcount(time1)==1 & mi(time1c)
replace time1c=time1 if regexm(time1,"[0-9]+g[0-9]+$") & mi(time1c)

replace time1c="6h"  if time1=="6,2/10/2019h"
replace time1d="2/10/2019" if time1=="6,2/10/2019h"
replace time1c=time1 if regexm(time1,"[0-9]+:[0-9]+:[0-9]+$") & mi(time1c)
replace time1c=time1 if regexm(time1,"^[0-9]+:[0-9][0-9]$") & mi(time1c)
replace time1c=regexs(1) if regexm(time1,"(^[0-9]+h[0-9][0-9])([0-9]+/[0-9]+$)") & mi(time1c)
replace time1d=regexs(2) if regexm(time1,"(^[0-9]+h[0-9][0-9])([0-9]+/[0-9]+$)") & mi(time1d)

replace time1c="8h10" if time1=="8:10:/01"
replace time1d="01"   if time1=="8:10:/01"
replace time1c="8h30" if time1=="8;30/21"
replace time1d="21"   if time1=="8;30/21"
replace time1c="9h30" if time1=="9;30/30"
replace time1d="30"   if time1=="9;30/30"
replace time1c="6h15" if time1=="6h15,,16/10/2019"
replace time1d="16/10/2019" if time1=="6h15,,16/10/2019"
replace time1d=time1 if regexm(time1,"2019$") & mi(time1d)

replace time1c=subinstr(time1c,":","h",1)
replace time1c=strlower(time1c)
replace time1c=regexr(time1c,"p$","")
qui tab time1d if !regexm(time1d,"2019$")
replace time1d="17/9/2019" if time1d=="17/9/201"
replace time1d=regexr(time1d,"/19$","/2019")
replace time1d=time1d+"/2019" if !regexm(time1d,"2019$") & regexm(time1d,"/[0-9]+")

qui tab time1d if madieutra==101 & !regexm(time1d,"2019$") & !mi(time1d)
replace time1d=time1d+"/09"+"/2019" if madieutra==101 & !regexm(time1d,"2019$") & !mi(time1d) & real(time1d)>17
replace time1d=time1d+"/10"+"/2019" if madieutra==101 & !regexm(time1d,"2019$") & !mi(time1d) & real(time1d)<18
replace time1d="30/09/2019" if time1d=="030/09/2019" & madieutra==101
replace time1d="10/10/2019" if !regexm(time1d,"2019$") & madieutra==308 & !mi(time1d)
replace time1d="20" if !regexm(time1d,"2019$") & madieutra==406 & time1d=="2020"
replace time1d=time1d+"/09"+"/2019" if madieutra==406 & !regexm(time1d,"2019$") & !mi(time1d) & real(time1d)>17
replace time1d=time1d+"/10"+"/2019" if madieutra==406 & !regexm(time1d,"2019$") & !mi(time1d) & real(time1d)<18
replace time1d=time1d+"/09"+"/2019" if madieutra==407 & !regexm(time1d,"2019$") & !mi(time1d) & inlist(time1d,"25")
replace time1d=time1d+"/10"+"/2019" if madieutra==407 & !regexm(time1d,"2019$") & !mi(time1d) & inlist(time1d,"3","7")

qui tab madieutra if mi(time1d) & !mi(time1c)
qui tab time1 if mi(time1d) & !mi(time1c) & madieutra==101
qui tab stt   if mi(time1d) & !mi(time1c) & madieutra==101
replace time1c="11h16" if time1=="11;16/19"
replace time1d="19/09/2019" if time1=="11;16/19"

* Correct base on time2
local cond1 "mi(time1d) & !mi(time1c) & madieutra==101"
local cond2 regexm(time2,"/[0-9]+$")
replace time1d=ustrright(time2,2)+"/09/2019" if real(ustrright(time2,2))>17 & `cond1' & `cond2'
replace time1d=ustrright(time2,2)+"/10/2019" if `cond1' & `cond2'
* Correct base on time4
local cond2 regexm(time4,"/[0-9]+$")
replace time1d=ustrright(time4,2)+"/09/2019" if real(ustrright(time4,2))>17 & `cond1' & `cond2'
replace time1d=ustrright(time4,2)+"/10/2019" if `cond1' & `cond2'

* Correct time1d of madieutra 207 base on raw data
local cond madieutra==207
replace stt=203 if madieutra==207 & mi(stt)
replace time1d="18/09/2019" if `cond' & stt<13
replace time1d="19/09/2019" if `cond' & stt<18 & stt>=13
replace time1d="20/09/2019" if `cond' & stt<24 & stt>=18
replace time1d="23/09/2019" if `cond' & stt<33 & stt>=24
replace time1d="24/09/2019" if `cond' & stt<44 & stt>=33
replace time1d="25/09/2019" if `cond' & stt<55 & stt>=44
replace time1d="26/09/2019" if `cond' & inlist(stt,55,56,57,58)
replace time1d="27/09/2019" if `cond' & inlist(stt,59,60,61)
replace time1d="02/10/2019" if `cond' & stt<88 & stt>=62
replace time1d="03/10/2019" if `cond' & stt<94 & stt>=88
replace time1d="04/10/2019" if `cond' & stt<105 & stt>=94
replace time1d="07/10/2019" if `cond' & stt<116 & stt>=105
replace time1d="08/10/2019" if `cond' & inlist(stt,116,117,118,119,120)
replace time1d="09/10/2019" if `cond' & stt<137 & stt>=121
replace time1d="10/10/2019" if `cond' & stt<159 & stt>=137
replace time1d="11/10/2019" if `cond' & stt<183 & stt>=159
replace time1d="15/10/2019" if `cond' & stt<192 & stt>=183
replace time1d="16/10/2019" if `cond' & stt<202 & stt>=192
replace time1d="17/10/2019" if `cond' & stt<210 & stt>=202

local cond madieutra==306
replace time1d="19/09/2019" if `cond' & stt>=1 & stt<9
replace time1d="23/09/2019" if `cond' & stt>=9 & stt<13
replace time1d="24/09/2019" if `cond' & stt>=13 & stt<16
replace time1d="26/09/2019" if `cond' & stt>=16 & stt<20
replace time1d="27/09/2019" if `cond' & stt>=20 & stt<24
replace time1d="01/10/2019" if `cond' & stt>=24 & stt<28
replace time1d="04/10/2019" if `cond' & stt>=28 & stt<36
replace time1d="08/10/2019" if `cond' & stt>=36 & stt<40
replace time1d="10/10/2019" if `cond' & stt>=41 & stt<49
replace time1d="11/10/2019" if `cond' & stt>=49 & stt<56
replace time1d="15/10/2010" if `cond' & stt>=56 & stt<58
replace time1d="16/10/2019" if `cond' & stt>=58 & stt<62
* Dong Hung thi khong co ngay thang, 403

replace time1d="26/09/2019" if madieutra==405 & inlist(stt,5,6,7,8)
replace time1d="03/10/2019" if madieutra==405 & inlist(stt,9,10,11,12)
replace time1d="04/10/2019" if madieutra==405 & inlist(stt,13,14,15)
replace time1d="09/10/2019" if madieutra==405 & inlist(stt,16,17,18,19)
replace time1d="11/10/2019" if madieutra==405 & inlist(stt,20,21,22,23)
replace time1d="16/10/2019" if madieutra==405 & inlist(stt,24,25,26)
replace time1d="16/10/2019" if madieutra==408
replace time1d="18/09/2019" if madieutra==408 & inlist(labcode,"71","72","73","74","75","76","77")

replace time1d="19/09/2019" if madieutra==410 & inlist(labcode, ///
"2019-0145", ///
"2019-0146", ///
"2019-0147", ///
"2019-0148", ///
"2019-0149", ///
"2019-0150")
replace time1d="29/09/2019" if madieutra==410 & labcode=="151"
replace time1d="04/10/2019" if madieutra==410 & labcode=="152"
replace time1d="08/10/2019" if madieutra==410 & inlist(labcode,"2019 - 153", "2019 - 154")
replace time1d="10/10/2019" if madieutra==410 & labcode=="2019 - 155"

local cond1 madieutra==401
local cond2 regexm(time1,"([0-9][0-9])/([0-9][0-9])/([0-9][0-9])")
replace time1c=regexs(2)+"h"+regexs(1) if `cond1' & `cond2'
replace time1d=regexs(3)+"/09/2019" if `cond1' & `cond2' & real(ustrright(time1,2))>17
replace time1d=regexs(3)+"/10/2019" if `cond1' & `cond2' & mi(time1d)

* luu y dieu kien cua dong hung
local cond mi(time1d) & !mi(time1) & madieutra!=403
qui tab time1 if `cond'
replace time1d=ustrright(time1,2)+"/09/2019" if `cond' & real(ustrright(time1,2))>17
replace time1d=ustrright(time1,2)+"/10/2019" if `cond'
replace time1c="7h00"  if madieutra==303 & inlist(stt,188,189)
replace time1c="9h00"  if madieutra==303 & stt==190 & mi(time1c)
replace time1c="10h00" if madieutra==207 & stt==155 & mi(time1c)
replace time1d="09/10/2019" if madieutra==207 & stt==155

local cond1 mi(time1c) & !mi(time1) & madieutra!=403
local cond2 regexm(time1,"([0-9]+)[;|/]([0-9]+)/[0-9]+$")
qui tab time1 if `cond1' & `cond2'
replace time1c=regexs(1)+"h"+regexs(2) if `cond1' & `cond2'

local cond2 regexm(time1,"([0-9]+)h/([0-9]+)/[0-9]+$")
replace time1c=regexs(1)+"h"+regexs(2) if `cond1' & `cond2'
replace time1c="10h05" if time1=="1005/14"
replace time1c="14h00" if time1=="14:0030"

* Cross check and correct for mistake infot
gen time1dc=date(time1d,"DMY")
gen mtime1d=month(time1dc)
qui tab time1 if mi(time1dc) | !inlist(mtime1d,9,10)
local cond1 (mi(time1dc) | !inlist(mtime1d,9,10))
local cond2 regexm(time1,"(^[0-9]+)/([0-9]+)/([0-9]+)")
replace time1d=regexs(2)+"/"+regexs(1)+"/"+regexs(3) if `cond1' & `cond2'
drop time1dc mtime1d

**** Time2
codebook time2 //missing 3
qui tab time2 if wordcount(time2)==1
qui tab time2 if wordcount(time2)==2
qui tab time2 if wordcount(time2)==3

* Chuyen time2 wordcount=3 thanh wordcount==1
local cond regexm(time2,"[h|g][ ]+") & wordcount(time2)==3
qui tab time2 if `cond'
replace time2=regexr(time2,"[g|h][ ]+","h") if wordcount(time2)==3
replace time2=regexr(time2,"ngày ","") if wordcount(time2)==3
replace time2=regexr(time2," PM$","")  if wordcount(time2)==3
replace time2="7h30 11/10" if time2=="7h30 11 /10" & wordcount(time2)==3
replace time2=subinstr(time2,"  "," ",.)
replace time2=strlower(time2)

* tao va lam sach bien moi
gen time2c=""
gen time2d=""

local cond wordcount(time2)==2
local w1   word(time2,1)
local w2   word(time2,2)
replace time2c=`w1' if `cond' & regexm(`w1',"h|:")
replace time2c=`w2' if `cond' & regexm(`w2',"h|:")
replace time2d=`w2' if `cond' & regexm(`w1',"h|:")
replace time2d=`w1' if `cond' & regexm(`w2',"h|:")

* wordcount time2=1
* time only
global cond  "mi(time2c) & !mi(time2)"
global cond2 "mi(time2d) & !mi(time2)"
global expression regexm(time2,"^[0-9][h|g][0-9]*$") | ///
				regexm(time2,"^[0-9]h[0-9]*p$") |      ///
				regexm(time2,"^[0-9]h$") |             ///
				regexm(time2,"^[0-9]:[0-9][0-9]$")
qui tab time2 if $cond & ($expression)
replace time2c=time2 if $cond & ($expression) //365 real changes made

global expression regexm(time2,"^[0-9][0-9][h|:][0-9]*$") | ///
				regexm(time2,"^[0-9]*:[0-9]*:[0-9]*$")
qui tab time2 if $cond & ($expression)
replace time2c=time2 if $cond & ($expression) //652 real change made

* Time and date
global expression regexm(time2,"(^[0-9]h[0-9]*)/([0-9]*$)") | ///
regexm(time2,"(^[0-9]h[0-9]*)[(]([0-9]*/[0-9]*)[)]$") | ///
regexm(time2,"(^[0-9]h[0-9]*)[,]([0-9]*/[0-9]*/[0-9]*$)") | ///
regexm(time2,"(^[0-9]:[0-9][0-9])/([0-9]*$)") | ///
regexm(time2,"(^[0-9]h/[0-9][0-9])/([0-9][0-9]$)")
qui tab time2 if $cond & ($expression)

global expression regexm(time2,"(^[0-9]h[0-9]*)/([0-9]*$)")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)
global expression regexm(time2,"(^[0-9]h[0-9]*)[(]([0-9]*/[0-9]*)[)]$")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)
global expression regexm(time2,"(^[0-9]h[0-9]*)[,]([0-9]*/[0-9]*/[0-9]*$)")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)
global expression regexm(time2,"(^[0-9]:[0-9][0-9])/([0-9]*$)")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)
global expression regexm(time2,"(^[0-9]h/[0-9][0-9])/([0-9][0-9]$)")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)

global  expression regexm(time2,"(^[0-9][0-9]h[0-9][0-9])([0-9]*/[0-9]*$)")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)
global expression regexm(time2,"(^[0-9][0-9]h[0-9]*)[(]([0-9]*/[0-9]*)[)]$")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)
global expression regexm(time2,"(^[0-9][0-9]h[0-9]*)/([0-9]*/$)")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)
global expression regexm(time2,"(^[0-9][0-9]:[0-9]*)/([0-9]*$)")
replace time2c=regexs(1) if $cond & ($expression)
replace time2d=regexs(2) if $cond2 & ($expression)

replace time2c=regexs(2)+"h"+regexs(1) if $cond & madieutra==401 & regexm(time2,"(^[0-9]*)/([0-9]*)/([0-9]*$)")
replace time2d=regexs(3) if $cond2 & madieutra==401 & regexm(time2,"(^[0-9]*)/([0-9]*)/([0-9]*$)")

replace time2c="8h56" if time2=="08/52/11" & madieutra==406 & $cond
replace time2c="8h00" if time2=="08:00/19/09/2019" & $cond
replace time2c="15h45" if time2=="15/:45/08" & $cond

replace time2d="11" if time2=="08/52/11" & madieutra==406 & $cond2
replace time2d="19/09/2019" if time2=="08:00/19/09/2019" & $cond2
replace time2d="11/10/2019" if time2=="11/10/2019" & $cond2
replace time2d="12/10/2019" if time2=="12/10/2019" & $cond2
replace time2d="08" if time2=="15/:45/08" & $cond2

qui tab time2 if $cond
qui tab time2 if $cond2

* lam sach nhung truong co thoi gian vao khong co ngay thang
* Correct time2d of madieutra 207 base on raw data
local cond madieutra==207
replace stt=203 if madieutra==207 & mi(stt)
replace time2d="18/09/2019" if `cond' & stt<13
replace time2d="19/09/2019" if `cond' & stt<18 & stt>=13
replace time2d="20/09/2019" if `cond' & stt<24 & stt>=18
replace time2d="23/09/2019" if `cond' & stt<33 & stt>=24
replace time2d="24/09/2019" if `cond' & stt<44 & stt>=33
replace time2d="25/09/2019" if `cond' & stt<55 & stt>=44
replace time2d="26/09/2019" if `cond' & inlist(stt,55,56,57,58)
replace time2d="27/09/2019" if `cond' & inlist(stt,59,60,61)
replace time2d="02/10/2019" if `cond' & stt<88 & stt>=62
replace time2d="03/10/2019" if `cond' & stt<94 & stt>=88
replace time2d="04/10/2019" if `cond' & stt<105 & stt>=94
replace time2d="07/10/2019" if `cond' & stt<116 & stt>=105
replace time2d="08/10/2019" if `cond' & inlist(stt,116,117,118,119,120)
replace time2d="09/10/2019" if `cond' & stt<137 & stt>=121
replace time2d="10/10/2019" if `cond' & stt<159 & stt>=137
replace time2d="11/10/2019" if `cond' & stt<183 & stt>=159
replace time2d="15/10/2019" if `cond' & stt<192 & stt>=183
replace time2d="16/10/2019" if `cond' & stt<202 & stt>=192
replace time2d="17/10/2019" if `cond' & stt<210 & stt>=202

local cond madieutra==306
replace time2d="19/09/2019" if `cond' & stt>=1 & stt<9
replace time2d="23/09/2019" if `cond' & stt>=9 & stt<13
replace time2d="24/09/2019" if `cond' & stt>=13 & stt<16
replace time2d="26/09/2019" if `cond' & stt>=16 & stt<20
replace time2d="27/09/2019" if `cond' & stt>=20 & stt<24
replace time2d="01/10/2019" if `cond' & stt>=24 & stt<28
replace time2d="04/10/2019" if `cond' & stt>=28 & stt<36
replace time2d="08/10/2019" if `cond' & stt>=36 & stt<40
replace time2d="10/10/2019" if `cond' & stt>=41 & stt<49
replace time2d="11/10/2019" if `cond' & stt>=49 & stt<56
replace time2d="15/10/2010" if `cond' & stt>=56 & stt<58
replace time2d="16/10/2019" if `cond' & stt>=58 & stt<62
* Dong Hung thi khong co ngay thang, 403

replace time2d="26/09/2019" if madieutra==405 & inlist(stt,5,6,7,8)
replace time2d="03/10/2019" if madieutra==405 & inlist(stt,9,10,11,12)
replace time2d="04/10/2019" if madieutra==405 & inlist(stt,13,14,15)
replace time2d="09/10/2019" if madieutra==405 & inlist(stt,16,17,18,19)
replace time2d="11/10/2019" if madieutra==405 & inlist(stt,20,21,22,23)
replace time2d="16/10/2019" if madieutra==405 & inlist(stt,24,25,26)
replace time2d="16/10/2019" if madieutra==408
replace time2d="18/09/2019" if madieutra==408 & inlist(labcode,"71","72","73","74","75","76","77")

replace time2d="19/09/2019" if madieutra==410 & inlist(labcode, ///
"2019-0145", ///
"2019-0146", ///
"2019-0147", ///
"2019-0148", ///
"2019-0149", ///
"2019-0150")
replace time2d="29/09/2019" if madieutra==410 & labcode=="151"
replace time2d="04/10/2019" if madieutra==410 & labcode=="152"
replace time2d="08/10/2019" if madieutra==410 & inlist(labcode,"2019 - 153", "2019 - 154")
replace time2d="10/10/2019" if madieutra==410 & labcode=="2019 - 155"

* chinh sua  nhung truong hop con lai
global expression regexm(time3,"/([0-9]*$)")
replace time2d=regexs(1) if madieutra==101 & $expression & mi(time2d)
global expression regexm(time4,"/([0-9]*$)")
replace time2d=regexs(1) if madieutra==101 & $expression & mi(time2d) 
replace time2d="22" if madieutra==101 & mi(time2d) & time4=="17:00-22"

* chinh sua nhung truong hop con lai
* Do thoi gian lay mau cua diem 201 la vao buoi sang truoc 10h vay len cac thoi gian sau se trong khoang ngay day
replace time2d=time1d if madieutra==201 & mi(time2d)
replace time2d=regexs(1) if regexm(time3,"[0-9]*,([0-9]*/[0-9]*/[0-9]*$)") & madieutra==205 & $cond2
replace time2d=regexs(1) if regexm(time3,"[0-9]*, ([0-9]*/[0-9]*/[0-9]*$)") & madieutra==205 & $cond2
replace time2d=time1d    if madieutra==303 & $cond2

* lam sach time2c va time2d
replace time2c=subinstr(time2c,"/","",.)
replace time2c=subinstr(time2c,"p","",.)
replace time2c=subinstr(time2c,",","",.)

replace time2d=regexr(time2d,"/$","")
replace time2d=subinstr(time2d,"(","",.)
replace time2d=subinstr(time2d,")","",.)

qui tab time2d if regexm(time2d,"19$|019$")
qui tab time2d if !regexm(time2d,"19$|2019$")
replace time2d="09/10/2019" if time2d=="31dec1899"
replace time2d="15/10/2019" if time2d=="15/10/2010"
replace time2d="18/09/2019" if time2d=="18/9/201"
replace time2d="26/09/2019" if time2d=="26/09/20"
replace time2d="17/10/2019" if time2d=="1710"
replace time2d="25" if time2d=="225" 
qui tab time2d if !regexm(time2d,"19$|2019$") & strpos(time2d,"/")
replace time2d=time2d+"/2019" if !regexm(time2d,"19$|2019$") & strpos(time2d,"/")

replace time2d=regexr(time2d,"/19$","/2019")
replace time2d=regexr(time2d,"[.]19$",".2019")
replace time2d=time2d+"/09/2019" if strlen(time2d)<3 & real(time2d)>17 & !mi(time2d)
replace time2d=time2d+"/10/2019" if strlen(time2d)<3 & !mi(time2d)

replace time2d="01/10/2019" if time2d=="01/101/2019"
replace time2d="02/10/2019" if time2d=="02/201/2019"

gen time2dc=date(time2d,"DMY")
gen mtime2dc=month(time2dc)
global cond mi(time2dc) & !mi(time2d)
replace time2d=regexs(2)+regexs(1)+regexs(3) if $cond & regexm(time2d,"([0-9]*/)([0-9]*/)([0-9]*)")
qui tab time2d if !inlist(mtime2dc,9,10) & !mi(time2dc)
global cond !inlist(mtime2dc,9,10) & !mi(time2dc)
replace time2d=regexs(2)+regexs(1)+regexs(3) if $cond & regexm(time2d,"([0-9]*/)([0-9]*/)([0-9]*)")
replace time2d="25/09/2019" if time2=="8h 25/05/19" & madieutra==309
drop time2dc mtime2dc

//!TIME3
** Time3: thoi gian bat dau lam xet nghiem
* Cleaning step base on word count of the time
qui tab time3 if wordcount(time3)==1 
qui tab time3 if wordcount(time3)==2
qui tab time3 if wordcount(time3)==3

* Chuyen time3 wordcount=3 thanh wordcount==1
local cond regexm(time3,"[h|g][ ]+") & wordcount(time3)==3
qui tab time3 if `cond'
replace time3=regexr(time3,"[g|h][ ]+","h") if wordcount(time3)==3
replace time3=regexr(time3,"ngày ","") if wordcount(time3)==3
replace time3=subinstr(time3,"  "," ",.)
replace time3=strlower(time3)

replace time3=regexr(time3,": ","") if wordcount(time3)==3
replace time3=regexr(time3," /","") if wordcount(time3)==3
* tao va lam sach bien moi
gen time3c=""
gen time3d=""

local cond wordcount(time3)==2
local w1   word(time3,1)
local w2   word(time3,2)
replace time3c=`w1' if `cond' & regexm(`w1',"h|:")
replace time3c=`w2' if `cond' & regexm(`w2',"h|:")
replace time3d=`w2' if `cond' & regexm(`w1',"h|:")
replace time3d=`w1' if `cond' & regexm(`w2',"h|:")

global cond  mi(time3c) & !mi(time3)
global cond2 mi(time3d) & !mi(time3)
global expression regexm(time3,"^[0-9][0-9]:[0-9][0-9]$") | ///
regexm(time3,"^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$") | ///
regexm(time3,"^[0-9]*h$") | ///
regexm(time3,"^[0-9]*h[0-9]$") | ///
regexm(time3,"^[0-9]*h[0-9][0-9]$") | ///
regexm(time3,"^[0-9]*h[0-9]*p$") | ///
regexm(time3,"^[0-9]*g[0-9][0-9]$") 
qui tab time3 if $cond & ($expression)

replace time3c=time3 if $cond & ($expression)
qui tab time3 if regexm(time3,"(^[0-9]h[0-9]*),([0-9]*/[0-9]*/[0-9]*$)") & $cond
global expression regexm(time3,"(^[0-9]h[0-9]*),([0-9]*/[0-9]*/[0-9]*$)")
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression 

global expression regexm(time3,"(^[0-9]h/[0-9]*)/([0-9][0-9]$)")
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"(^[0-9]h[0-9]*)[(]([0-9]*/[0-9]*)[)]$")
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"(^[0-9]:[0-9][0-9])/([0-9][0-9]$)")
qui tab time3 if $cond & $expression
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"(^[0-9]*)/([0-9]*)/([0-9]*[/]*$)")
qui tab time3 if $cond & $expression & madieutra==401
replace time3c=regexs(2)+"h"+regexs(1) if $cond & $expression & madieutra==401
replace time3d=regexs(3) if $cond2 & $expression & madieutra==401

global expression regexm(time3,"([0-9]*:[0-9][0-9])/[:]*([0-9]*$)")
qui tab time3 if $cond & $expression
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression
replace time3c="11:35"   if time3=="35:11/28"

global expression regexm(time3,"(^[0-9]*h[0-9]*)[(]([0-9]*/[0-9]*[)]$)")
qui tab time3 if $cond & $expression
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"(^[0-9]*h[0-9][0-9])/([0-9]*$)")
qui tab time3 if $cond & $expression
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"(^[0-9]*h[0-9][0-9])([0-9]*/[0-9]*$)")
qui tab time3 if $cond  & $expression
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"(^[0-9][0-9]h/[0-9][0-9])(/[0-9][0-9]$)")
qui tab time3 if $cond & $expression
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"(^[0-9][0-9]h[0-9]*),([0-9]*/[0-9]*/[0-9]*$)")
qui tab time3 if $cond & $expression
replace time3c=regexs(1) if $cond  & $expression
replace time3d=regexs(2) if $cond2 & $expression

global expression regexm(time3,"([0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9])([0-9][0-9]:[0-9][0-9]:[0-9][0-9])")
qui tab time3 if $cond & $expression
replace time3c=regexs(2) if $cond  & $expression
replace time3d=regexs(1) if $cond2 & $expression

global expression regexm(time3,"^([0-9][0-9])([0-9][0-9]) ([0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9])")
qui tab time3 if $cond & $expression
replace time3c=regexs(1)+"h"+regexs(2) if $cond  & $expression
replace time3d=regexs(3) if $cond2 & $expression

replace time3c="9h32" if time3=="9hh32,20/09/19"
replace time3d="20/09/2019" if time3=="9hh32,20/09/19"
replace time3d=time3 if time3=="12/10/2019" & madieutra==303 & $cond2

global expression regexm(time4,"[0-9]*:[0-9]*/([0-9]*$)")
replace time3d=regexs(1) if $cond2 & $expression & madieutra==101
replace time3d=time2d if $cond2 & madieutra==101

* ma diem dieu tra 207
local cond madieutra==207
replace time3d="18/09/2019" if `cond' & stt<13
replace time3d="19/09/2019" if `cond' & stt<18 & stt>=13
replace time3d="20/09/2019" if `cond' & stt<24 & stt>=18
replace time3d="23/09/2019" if `cond' & stt<33 & stt>=24
replace time3d="24/09/2019" if `cond' & stt<44 & stt>=33
replace time3d="25/09/2019" if `cond' & stt<55 & stt>=44
replace time3d="26/09/2019" if `cond' & inlist(stt,55,56,57,58)
replace time3d="27/09/2019" if `cond' & inlist(stt,59,60,61)
replace time3d="02/10/2019" if `cond' & stt<88 & stt>=62
replace time3d="03/10/2019" if `cond' & stt<94 & stt>=88
replace time3d="04/10/2019" if `cond' & stt<105 & stt>=94
replace time3d="07/10/2019" if `cond' & stt<116 & stt>=105
replace time3d="08/10/2019" if `cond' & inlist(stt,116,117,118,119,120)
replace time3d="09/10/2019" if `cond' & stt<137 & stt>=121
replace time3d="10/10/2019" if `cond' & stt<159 & stt>=137
replace time3d="11/10/2019" if `cond' & stt<183 & stt>=159
replace time3d="15/10/2019" if `cond' & stt<192 & stt>=183
replace time3d="16/10/2019" if `cond' & stt<202 & stt>=192
replace time3d="17/10/2019" if `cond' & stt<210 & stt>=202

* madieu tra 201
gen control=($cond2 & madieutra==201)
replace time3d=time2d if $cond2 & madieutra==201
replace time3d="28/09/2019" if control==1 & time3=="8h" & time2c=="16h30"
replace time3d="12/10/2019" if control==1 & time3=="13h30" & time2=="15h"

* madieutra 306
local cond madieutra==306
replace time3d="19/09/2019" if `cond' & stt>=1 & stt<9
replace time3d="23/09/2019" if `cond' & stt>=9 & stt<13
replace time3d="24/09/2019" if `cond' & stt>=13 & stt<16
replace time3d="26/09/2019" if `cond' & stt>=16 & stt<20
replace time3d="27/09/2019" if `cond' & stt>=20 & stt<24
replace time3d="01/10/2019" if `cond' & stt>=24 & stt<28
replace time3d="04/10/2019" if `cond' & stt>=28 & stt<36
replace time3d="08/10/2019" if `cond' & stt>=36 & stt<40
replace time3d="10/10/2019" if `cond' & stt>=41 & stt<49
replace time3d="11/10/2019" if `cond' & stt>=49 & stt<56
replace time3d="15/10/2010" if `cond' & stt>=56 & stt<58
replace time3d="16/10/2019" if `cond' & stt>=58 & stt<62

* madieutra 405
replace time3d="26/09/2019" if madieutra==405 & inlist(stt,5,6,7,8)
replace time3d="03/10/2019" if madieutra==405 & inlist(stt,9,10,11,12)
replace time3d="04/10/2019" if madieutra==405 & inlist(stt,13,14,15)
replace time3d="09/10/2019" if madieutra==405 & inlist(stt,16,17,18,19)
replace time3d="11/10/2019" if madieutra==405 & inlist(stt,20,21,22,23)
replace time3d="16/10/2019" if madieutra==405 & inlist(stt,24,25,26)

replace time3c=time3c+time3d if madieutra==408 & regexm(time3d,"p$")
replace time3d="16/10/2019"  if madieutra==408
replace time3d="18/09/2019"  if madieutra==408 & inlist(labcode,"71","72","73","74","75","76","77")


* madieutra 410
replace time3d="19/09/2019" if $cond2 & madieutra==410 & inlist(labcode, ///
"2019-0145", ///
"2019-0146", ///
"2019-0147", ///
"2019-0148", ///
"2019-0149", ///
"2019-0150")
replace time3d="29/09/2019" if $cond2 & madieutra==410 & labcode=="151"
replace time3d="04/10/2019" if $cond2 & madieutra==410 & labcode=="152"
replace time3d="08/10/2019" if $cond2 & madieutra==410 & inlist(labcode,"2019 - 153", "2019 - 154")
replace time3d="10/10/2019" if $cond2 & madieutra==410 & labcode=="2019 - 155"

replace time3d=time2d if $cond2 & madieutra!=403 & time3!="lỗi 5011"

qui tab time3 if $cond
qui tab time3 if $cond2
qui tab time3d
** lam sach time3c va time3d
replace time3c=subinstr(time3c,"/","",.)
replace time3c=subinstr(time3c,"p","",.)
replace time3c=subinstr(time3c,",","",.)

replace time3d=regexr(time3d,"/$","")
replace time3d=subinstr(time3d,"(","",.)
replace time3d=subinstr(time3d,")","",.)
replace time3d=regexr(time3d,"^/","")

qui tab time3d if regexm(time3d,"19$|019$")
qui tab time3d if !regexm(time3d,"19$|2019$")
replace time3d="26/09/2019" if time3d=="26/09/20" & !regexm(time3d,"19$|2019$")
replace time3d="15/10/2019" if time3d=="15/10/2010"
replace time3d="18/09/2019" if time3d=="18/9/201"
replace time3d="11/10/2019" if time3d=="011/10"
replace time3d="25" if time3d=="35"
replace time3d="02/10" if time3d=="20/10"

*replace time3d="17/10/2019" if time3d=="1710"
*replace time3d="25" if time3d=="225" 
qui tab time3d if !regexm(time3d,"19$|2019$") & strpos(time3d,"/")
replace time3d=time3d+"/2019" if !regexm(time3d,"19$|2019$") & strpos(time3d,"/")
replace time3d=regexr(time3d,"/19$","/2019")
replace time3d=regexr(time3d,"[.]19$",".2019")
replace time3d=time3d+"/09/2019" if strlen(time3d)<3 & real(time3d)>17 & !mi(time3d)
replace time3d=time3d+"/10/2019" if strlen(time3d)<3 & !mi(time3d)

replace time3d="01/10/2019" if time3d=="01/101/2019"
replace time3d="02/10/2019" if time3d=="02/201/2019"

gen time3dc=date(time3d,"DMY")
gen mtime3dc=month(time3dc)
global cond mi(time3dc) & !mi(time3d)
replace time3d=regexs(2)+regexs(1)+regexs(3) if $cond & regexm(time3d,"([0-9]*/)([0-9]*/)([0-9]*)")

qui tab time3d if !inlist(mtime3dc,9,10) & !mi(time3dc)
global cond !inlist(mtime3dc,9,10) & !mi(time3dc)
replace time3d=regexs(2)+regexs(1)+regexs(3) if $cond & regexm(time3d,"([0-9]*/)([0-9]*/)([0-9]*)")
replace time3d="27/09/2019" if time3d=="06/27/2019"
replace time3d="25/09/2019" if time3d=="25/8/2019"
drop time3dc mtime3dc

**!! Time4
qui tab time4 if wordcount(time4)==1 
qui tab time4 if wordcount(time4)==2
qui tab time4 if wordcount(time4)==3

global cond regexm(time4,"[h|g][ ]+") & wordcount(time4)==3
qui tab time4 if $cond
replace time4=regexr(time4,"[g|h][ ]+","h") if wordcount(time4)==3
replace time4=regexr(time4,"ngày ","") if wordcount(time4)==3
replace time4=regexr(time4," AM$","")  if wordcount(time4)==3
replace time4="10:40 27/09/2019" if time4=="10: 40 27/09/2019" & wordcount(time4)==3
replace time4=subinstr(time4,"  "," ",.)
replace time4=strlower(time4)

gen time4c=""
gen time4d=""

local cond wordcount(time4)==2
local w1   word(time4,1)
local w2   word(time4,2)
replace time4c=`w1' if `cond' & regexm(`w1',"h|:")
replace time4c=`w2' if `cond' & regexm(`w2',"h|:")
replace time4d=`w2' if `cond' & regexm(`w1',"h|:")
replace time4d=`w1' if `cond' & regexm(`w2',"h|:")

global cond  "mi(time4c) & !mi(time4)"
global cond2 "mi(time4d) & !mi(time4)"
replace time4="21:52/25" if time4=="2l:52/25"
global expression regexm(time4,"(^[0-9][0-9][:|;][0-9]*)[/|-]([0-9]*)")

replace time4c=regexs(1) if $cond  & $expression
replace time4d=regexs(2) if $cond2 & $expression

global expression regexm(time4,"^[0-9][0-9]:[0-9][0-9]$") | ///
regexm(time4,"^[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]$")
replace time4c=time4 if $cond & ($expression) //Time only

replace time4=subinstr(time4,"j","h",.)
global expression regexm(time4,"^[0-9][0-9][h/g][0-9]*[p]*$")
replace time4c=time4 if $cond & $expression

replace time4=subinstr(time4,"`","",.)
replace time4=subinstr(time4,"h/","h",.)

local cond1 madieutra==401
local cond2 regexm(time4,"([0-9][0-9])/([0-9][0-9])/([0-9][0-9])")
replace time4c=regexs(2)+"h"+regexs(1) if `cond1' & `cond2'
replace time4d=regexs(3)+"/09/2019"    if `cond1' & `cond2' & real(ustrright(time4,2))>17
replace time4d=regexs(3)+"/10/2019"    if `cond1' & `cond2' & mi(time4d)

global expression regexm(time4,"([0-9][0-9]h[0-9]*)[/|(][0-9]*")
*!!
replace time4d=time3d if $cond2 & $expression
replace time4c=regexs(1) if $cond & $expression
global expression regexm(time4,"(^[0-9][0-9]h[0-9][0-9]),([0-9][0-9]/[0-9][0-9]/[0-9][0-9]$)")
replace time4c=regexs(1) if $cond  & $expression
replace time4d=regexs(2) if $cond2 & $expression

global expression regexm(time4,"(^[0-9][0-9])/([0-9][0-9])/([0-9][0-9]$)")
replace time4c=regexs(2)+"h"+regexs(1) if $cond & $expression
replace time4d=regexs(3)+"/09/2019"    if $cond2 & $expression & real(ustrright(time4,2))>17
replace time4d=regexs(3)+"/10/2019"    if $cond2 & $expression & mi(time4d)

replace time4c="11h35" if time4=="11/35 07/10/19" & $cond
replace time4d="07/10/19" if time4=="11/35 07/10/19" & $cond2

global expression regexm(time4,"([0-9][0-9]/[0-9][0-9]/2019)([0-9]*:[0-9]*:[0-9]*$)")
replace time4c=regexs(2) if $cond & $expression
replace time4d=regexs(1) if $cond2 & $expression

global expression regexm(time4,"^[0-9]h[0-9][0-9]$")
qui tab time4 if $cond & $expression
replace time4c=time4 if $cond & $expression

qui tab time4 if $cond
global expression regexm(time4,"(^[0-9][h|:][0-9][0-9])/([0-9]*)")
replace time4c=regexs(1) if $cond  & $expression
replace time4d=regexs(2) if $cond2 & $expression
replace time4c="13:00:20" if $cond & time4=="13:00:20"
replace time4c="" if time4=="12/10/2019" & time4c=="12/10/2019"

replace time4c=regexr(time4c,"/$","")
replace time4c=subinstr(time4c,";","",.)
qui tab time4c if !regexm(time4c,"h|:")
replace time4c=regexs(1)+"h"+regexs(2) if regexm(time4c,"(^[0-9][0-9])([0-9][0-9]$)")

* So sánh biến thời gian của time3 và time4, vì là thời gian từ lúc xét nghiệm đến lúc có kết quả.
* Thời gian thông thường sẽ là 3h và trong cùng 1 ngày
* Tuy nhiên trong trường hợp mẫu chuyển về trong kíp trực thì có thể chênh lệch các ngày với nhau
* chuyển giờ thành giờ chiều
replace time4c=strofreal(real(ustrleft(time4c,1))+12)+ustrright(time4c,3) ///
if inlist(id, ///
1870, ///
1871, ///
1872, ///
1873, ///
1882, ///
1894, ///
1951, ///
1952, ///
1953, ///
1960, ///
1961, ///
1986, ///
2049, ///
2052, ///
2053, ///
2054, ///
2059, ///
2060, ///
2061, ///
2068, ///
6012, ///
6013, ///
6014, ///
6015, ///
6016)
replace time3c="10h30" if inlist(id, ///
47, ///
48, ///
49, ///
50)
replace time3c="10h58" if id==2077
replace time3c="9h32"  if id==1123
replace time4c="11h57" if id==2298
replace time4c="15h36" if id==2210
replace time4c="16h54" if id==3123
replace time4c="20h57" if id==3681
replace time4c="21h29" if id==3015|id==3017
replace time4c="9h44"  if id==6811
replace time4c="" if inlist(id, ///
3653, ///
1395, ///
1990, ///
2074, ///
2410, ///
3712, ///
3713, ///
3714, ///
3715, ///
3716, ///
4360, ///
4361, ///
4362, ///
4435, ///
5924, ///
5926, ///
6023, ///
2613)

gen time3chour=real(regexs(1)) if regexm(time3c,"(^[0-9]*)")
qui list time1c time2c time3 time4 if time3chour<=5
qui list id time3d time3 time4 if time3chour>21 & !mi(time3chour)
replace time3d=strofreal(real(ustrleft(time3d,2))-1)+ustrright(time3d,8) ///
if inlist(id, 2698,2699,3813,3849)

* Còn những trường hợp còn lại thì sẽ cho thành missing:
* - Thời gian làm và thời gian có kết quả như nhau
* - Thời gian làm và thời gian trả ra kết quả như nhau
replace time4c="" if inlist(id, 3653, ///
1725, ///
2047, ///
2048, ///
2050, ///
711, ///
2057, ///
6661, ///
6689, ///
6690, ///
6691, ///
6692, ///
1395, ///
1990, ///
2074, ///
2410, ///
3712, ///
3713, ///
3714, ///
3715, ///
3716, ///
4360, ///
4361, ///
4362, ///
4435, ///
5924, ///
5926, ///
6023, ///
2377, ///
2613)
* Trừ những mẫu xét nghiệm trong đêm phải chuyển sang ngày hôm sau thì vẫn chung 1 ngày
replace time4d=time3d if !inlist(id, 2698,2699,3813,3849)

* //TIME 5: thời gian công bố kết quả
* Thường thì sẽ công bố kết quả cùng ngày với thời gian có kết quả
* Những trường hợp bất thường là công bố kết quả sau ngày đó hoặc trước ngày đó, hoặc 
* Trong cùng 1 ngày nhưng ở thời điểm sớm hơn
** time5
qui tab time5 if wordcount(time5)==1 
qui tab time5 if wordcount(time5)==2
qui tab time5 if wordcount(time5)==3

global cond regexm(time5,"[h|g][ ]+") & wordcount(time5)==3
qui tab time5 if $cond
replace time5=regexr(time5,"[g|h][ ]+","h") if wordcount(time5)==3
replace time5=regexr(time5,"ngày ","")      if wordcount(time5)==3
replace time5=regexr(time5," PM$","")  if wordcount(time5)==3
replace time5=regexr(time5,"[ :]",":") if wordcount(time5)==3
replace time5=regexr(time5,": ",":") if wordcount(time5)==3
replace time5=regexr(time5,"ngày","")
replace time5=trim(time5)
replace time5=subinstr(time5,"  "," ",.)

* Chuyen time5 thanh ngay cua thang time4
qui tab time5 if wordcount(time5)==2
gen time5c=""
gen time5d=""

local cond wordcount(time5)==2
local w1   word(time5,1)
local w2   word(time5,2)
replace time5c=`w1' if `cond' & regexm(`w1',"h|:")
replace time5c=`w2' if `cond' & regexm(`w2',"h|:")
replace time5d=`w2' if `cond' & regexm(`w1',"h|:")
replace time5d=`w1' if `cond' & regexm(`w2',"h|:")

global cond  "mi(time5c) & !mi(time5)"
global cond2 "mi(time5d) & !mi(time5)"

qui tab1 time5* if regexm(time5d,"p$")
replace time5c=time5 if regexm(time5d,"p$")
replace time5d=""    if regexm(time5d,"p$")
replace time5d="" if strlen(time5d)<=2 & !mi(time5d) & !strpos(time5,"/")

log close _all
global time2=clock("`c(current_date)' `c(current_time)'","DMYhms")
di "Tổng thời gian chạy lệnh là: " ($time2-$time1)/1000 "s"

save form4-20200505-combined.dta, replace
