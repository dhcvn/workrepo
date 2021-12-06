** Kham pha folder so lieu GXAlert
** Date: 14-02-2020
** Setting up evironment
mydir 
qui do "$codes\GA-setup.do"
clear
cd "$garaw_date"
filelist
drop if dirname=="." //total files in the folder are 236 save

split dirname, p(/)
drop dirname1
* contract dirname2 dirname3 dirname4 dirname5 dirname6 //original folder include 38 subfolders
* Create file extension
gen duoifile = ustrright(filename,4)
br if duoifile=="heic"

tab dirname3
tab dirname4
tab dirname4 duoifile
tab dirname5

gen cluster=real(ustrleft(dirname4,2))
tab cluster

gen madiem=real(ustrright(ustrleft(dirname4,4),2))
tab madiem

gen madieutra=real(ustrleft(dirname4,4))

tab madiem cluster
tab duoifile if 2.cluster & 1.madiem
tab duoifile if 2.cluster & 8.madiem

tab duoifile if 3.cluster & 1.madiem
tab duoifile if 3.cluster & 6.madiem
tab duoifile if 3.cluster & 8.madiem
tab duoifile if 3.cluster & 10.madiem

tab duoifile if 4.cluster & 1.madiem
tab duoifile if 4.cluster & 2.madiem
tab duoifile if 4.cluster & 4.madiem
tab duoifile if 4.cluster & 6.madiem
tab duoifile if 4.cluster & 8.madiem
tab duoifile if 4.cluster & 9.madiem

bys cluster madiem: tab duoifile
tab madieutra duoifile
************************************
* cac buoc thuc hien
* 1. xoa folder backup (thuc hien 1 lan duy nhat)
* 2. Doi ten files (thuc hien 1 lan duy nhat)

/*
local folder1 "C:\Users\DELL\Google Drive\GxAlert\Data GxAlert\II.Nhóm có số lượng XN năm 2018 cao_0201-0210\0208_BV 30.4 Sóc Trăng\OLd"
local folder2 "C:\Users\DELL\Google Drive\GxAlert\Data GxAlert\III.Nhóm có số lượng XN năm 2018 trung bình_0301-0310\0310.BVL&BP Vĩnh Long\Old"
local folder3 "C:\Users\DELL\Google Drive\GxAlert\Data GxAlert\IV.Nhóm có số lượng XN năm 2018 thấp_0401-0410\0404.TTKSBT Hòa Bình\File ảnh"
local folder4 "C:\Users\DELL\Google Drive\GxAlert\Data GxAlert\IV.Nhóm có số lượng XN năm 2018 thấp_0401-0410\0406.BVĐHYD HCM\Scan"
shell rd "`folder1'" /s /q
shell rd "`folder2'" /s /q
shell rd "`folder3'" /s /q
shell rd "`folder4'" /s /q
drop if inlist(dirname5,"File ảnh","OLd","Old","Scan")

cd "C:\Users\DELL\Google Drive\GxAlert\Data GxAlert\IV.Nhóm có số lượng XN năm 2018 thấp_0401-0410\0409.TTYT Ba Tri - Bến Tre"
shell erase *.jpg
cd "C:\Users\DELL\Google Drive\GxAlert\Data GxAlert\III.Nhóm có số lượng XN năm 2018 trung bình_0301-0310\0301.BVĐK Ý Yên Nam Định"
shell erase *.jpg
cd "$garaw_date"
drop if dirname=="./Data GxAlert/III.Nhóm có số lượng XN năm 2018 trung bình_0301-0310/0301.BVĐK Ý Yên Nam Định"
br if regexm(filename,"[0-9][0-9].jpg")
drop if regexm(filename,"[0-9][0-9].jpg") 
drop if duoifile==".jpg"
*/

/* ------------------------------------------------ Chạy trước khi đổi tên files
cd "$garaw_date"
gen filename1=regexr(filename,"^[0-9][.]","")

br madieutra filename1 filename if !regexm(filename1,"^LAB|^LaB|^lab")
* thay filename1 bang lab03 o bv 30-4 tinh soc trang
replace filename1="LAB03."+ filename1 if !regexm(filename1,"^LAB|^LaB|^lab") & madieutra==208
replace filename1="LAB04."+ filename1 if filename1=="danh sach TXHN GxAlert.xlsx" & madieutra==408
tab filename1 madieutra if regexm(filename1, "^LaB|^lab")
replace filename1=regexr(filename1, "^LaB|^lab","LAB")
tab filename1 if madieutra==408
tab filename1 if madieutra==402
cap	 drop phieu
gen phieu=""
replace phieu=ustrleft(filename1,6) if regexm(filename1,"^LAB|^LaB|^lab")
replace phieu=subinstr(phieu,".","",.)
replace phieu=subinstr(phieu," ","",.)
replace phieu=subinstr(phieu,"_","",.)
replace phieu=subinstr(phieu,"-","",.)
replace phieu=strupper(phieu)
--------------------------------------------------- Chạy trước khi đổi tên files */
cap drop phieu
gen phieu=regexs(2) if regexm(filename,"^([0-9][0-9][0-9])(LAB[0-9][0-9])")
tab filename if mi(phieu)
replace phieu="LAB03" if mi(phieu) & strpos(filename,"LAB 03")>0
replace phieu="LAB04" if mi(phieu) & strpos(filename,"LAB 04")>0

tab duoifile if !mi(phieu)
tab madieutra if !mi(phieu) & duoifile==".jpg"
tab duoifile if mi(phieu)

tab madieutra phieu
drop if madieutra==301 & duoifile==".jpg"
drop if mi(phieu)

****************************************
* Đổi tên files bằng lệnh rename
****************************************
cap drop fulldir
gen fulldir = "$garaw_date" + subinstr(subinstr(dirname,".","",1),"/","\",.)
gen fullname =fulldir + "\" + filename
replace dirname=subinstr(dirname,"/","\",.)

/* ------------------------------------------------Chạy đổi tên 1 lần duy nhất
qui count 
foreach v of numlist 1/`r(N)' {
	cd "$garaw_date"
	local path=dirname[`v']
	local i=filename[`v']
	local j=filename1[`v']
	cd "`path'"
	shell rename "`i'" "`j'"
	cd "$garaw_date"
}
* Source read: https://www.statalist.org/forums/forum/general-stata-discussion/general/1309261-renaming-files-in-different-directories
--------------------------------------------------Chạy đổi tên 1 lần duy nhất */

/* Tao lenh copy: Chay 1 lan dau tien
qui tab phieu, gen(phieuso)

foreach i of numlist 1/4 {
	gsort -phieuso`i'
	qui count if phieuso`i'==1
	foreach v of numlist 1/`r(N)' {
		local a=fullname[`v']
		copy "`a'" "${form`i'}\", replace
	}
}
*/
compress
save "$resultdata"


