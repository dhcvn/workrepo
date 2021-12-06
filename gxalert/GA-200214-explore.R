path <- "D:/NTP/GA-191231-GxAlert project/1. Data/Data GxAlert/"
setwd(path) # this path donot contain VNmeses characterss

basename(path)
dirname(path)

dirdetail <- list.dirs()
filesdetail <- basename(list.files(recursive = T))
# Check xem du subfolders trong folder tong chua
dirdetail %>% st
list.files(recursive = T)
list.files(recursive = T, pattern=".xlsx|.xls")
list.files(recursive = T, pattern=".docx")
list.files(recursive = T, pattern=".pdf")
data <- as.data.frame(filesdetail)
# Su dung file list trong stata nhung consider chuyen sang R hoac python