/* Chuyen time2 wordcount=3 thanh wordcount==1
local cond regexm(time2,"[h|g][ ]+") & wordcount(time2)==3
tab time2 if `cond'
replace time2=regexr(time2,"[g|h][ ]+","h") if wordcount(time2)==3
replace time2=regexr(time2,"ngày ","") if wordcount(time2)==3
replace time2=regexr(time2," PM$","")  if wordcount(time2)==3
replace time2="7h30 11/10" if time2=="7h30 11 /10" & wordcount(time2)==3
replace time2=subinstr(time2,"  "," ",.)
replace time2=strlower(time2)

gen time2c=""
gen time2d=""

local cond wordcount(time2)==2
local w1   word(time2,1)
local w2   word(time2,2)
replace time2c=`w1' if `cond' & regexm(`w1',"h|:")
replace time2c=`w2' if `cond' & regexm(`w2',"h|:")
replace time2d=`w2' if `cond' & regexm(`w1',"h|:")
replace time2d=`w1' if `cond' & regexm(`w2',"h|:")

local cond1 wordcount(time2)==1
*local cond regexm(time2,"[0-9]+h[0-9]+$")
local cond  regexm(time2,"([0-9]+:[0-9]+)/([0-9][0-9]$)")
local cond regexm(time2,"[0-9][g|:][0-9][0-9]$")
local cond mi(time2c) & mi(time2d)

tab time2 if `cond' & `cond1'
*/
local cond0 wordcount(time2)==1 & madieutra==401
local cond1 mi(time2d)
local cond3 mi(time2c)
local cond2 regexm(time2,"([0-9]+)/([0-9]+)/([0-9]+$)")
local cond4 real(ustrright(time2,2))>17
local cond mi(time2d) & mi(time2c)

*local cond regexm(time2,"([0-9]+h[0-9]+)([0-9]+/[0-9]+$)")

tab time2 if `cond' 

cap drop a
gen a=time4
forvalue i=0/9 {
	replace a=subinstr(a,"`i'","A",.)
}
gen b=wordcount(a)


* Draft code for mdoel
sysuse auto, clear
gen duphong=(weight<3000)
global xmodel mpg trunk length turn

logit foreign $xmodel if duphong==1, or
estimates store duphong
logit foreign $xmodel if duphong==0, or
estimates store kduphong

coefplot kduphong duphong, eform ///
	||, drop(_cons) nolabel byopts(xrescale) legend(off) graphregion(color(white))
addplot : , xline(1) norescaling legend(on order(0 "Không dự phòng" 1 "Dự phòng"))
tab thuoc if duphong==1

* date 23/03/2020
* date 26/03/2020
* code to check time2 and time3 in the madieutra=201
global expression regexm(time2c,"([0-9]*)h([0-9]*$)")
gen time2=.
replace time2=real(regexs(1))+real(regexs(2))/60 if $expression
replace time2=real(regexs(1)) if $expression & mi(time2)
global expression regexm(time3,"([0-9]*)h([0-9]*$)")
gen time3c=real(regexs(1))+real(regexs(2))/60 if $expression
replace time3c=real(regexs(1)) if $expression & mi(time3c)

gen testtime=time3c+time3d if regexm(time3d,"p$")

count if testtime<0

** lam sach time3c va time3d
replace time3c=subinstr(time3c,"/","",.)
replace time3c=subinstr(time3c,"p","",.)
replace time3c=subinstr(time3c,",","",.)

replace time3d=regexr(time3d,"/$","")
replace time3d=subinstr(time3d,"(","",.)
replace time3d=subinstr(time3d,")","",.)
replace time3d=regexr(time3d,"^/","")

tab time3d if regexm(time3d,"19$|019$")
tab time3d if !regexm(time3d,"19$|2019$")
replace time3d="26/09/2019" if time3d=="26/09/20" & !regexm(time3d,"19$|2019$")
replace time3d="15/10/2019" if time3d=="15/10/2010"
replace time3d="18/09/2019" if time3d=="18/9/201"
replace time3d="11/10/2019" if time3d=="011/10"

replace time3d="17/10/2019" if time3d=="1710"
replace time3d="25" if time3d=="225" 
tab time3d if !regexm(time3d,"19$|2019$") & strpos(time3d,"/")
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
tab time3d if !inlist(mtime3dc,9,10) & !mi(time3dc)
global cond !inlist(mtime3dc,9,10) & !mi(time3dc)
replace time3d=regexs(2)+regexs(1)+regexs(3) if $cond & regexm(time3d,"([0-9]*/)([0-9]*/)([0-9]*)")
replace time3d="25/09/2019" if time3=="8h 25/05/19" & madieutra==309
drop time3dc mtime3dc

** So sánh thời gian của tim3 và time4
keep id time3c time4c
tab time4c if !regexm(time4c,"h|:")
tab time3c if !regexm(time3c,"h|:")

split time3c,p("h" ":" "g")
destring time3c1 time3c2 time3c3, replace
replace time3c2=regexr(time3c2,"[a-z]","")
replace time3c3=regexr(time3c3,"[a-z]","")
destring time3c2 time3c3, replace force

split time4c,p("h" ":" "g")
destring time4c1 time4c2 time4c3, replace
replace time4c2=regexr(time4c2,"[a-z]","")
destring time4c1 time4c2 time4c3, replace force

tab time3c if time3c1>24 & time3c1!=.
tab time4c if time4c1>24 & time4c1!=.

replace time3c1=. if time3c1>24 & time3c1!=.
replace time4c1=. if time4c1>24 & time4c1!=.

gen time3=time3c1
replace time3=time3+time3c2/60 if !mi(time3c2)

gen time4=time4c1
replace time4=time4c1+time4c2/60 if !mi(time4c2)

gen testtime=time4-time3
br if testtime<=0 | (mi(time4) | mi(time3))

