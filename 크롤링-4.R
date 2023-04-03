#WICS 기준 섹터 정보 크롤링
# [Index → WISE SECTOR INDEX → WICS → 에너지]를 클릭
# 그 후 [Components] 탭을 클릭하면 해당 섹터의 구성종목을 확인

## json 형식이므로 jsonlite 패키지 사용
library(jsonlite)

url = 'http://www.wiseindex.com/Index/GetIndexComponets?ceil_yn=0&dt=20190607&sec_cd=G10'
data = fromJSON(url)

lapply(data, head)

## $list 항목에는 해당 섹터의 구성종목 정보가 있음.
## $sector 함옥을 통해 다른 섹터의 코드 확인 가능.
## for loop 구문을 통해 URL의 sec_cd= 에 해당하는 부분만 변경하면 모든 섹터의 구성 종목을 얻을 수 있음.

sector_code = c('G25', 'G35', 'G50', 'G40', 'G10',
                'G20', 'G55', 'G30', 'G15', 'G45')
data_sector = list()

for (i in sector_code) {
  
  url = paste0(
    'http://www.wiseindex.com/Index/GetIndexComponets',
    '?ceil_yn=0&dt=',biz_day,'&sec_cd=',i)
  data = fromJSON(url)
  data = data$list
  
  data_sector[[i]] = data
  
  Sys.sleep(1)
}

data_sector = do.call(rbind, data_sector)
