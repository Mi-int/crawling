# 개별종목 지표 크롤링

# 기존과 쿼리값만 차이가 있음

# library
library(httr)
library(rvest)
library(readr)


gen_otp_url = 'https://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
gen_otp_data = list(
  searchType = '1',
  mktId = 'ALL',
  trdDd = '20210108',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT03501'
)
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

down_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
down_ind = POST(down_url, query = list(code = otp),
                  add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv()
print(down_ind)

write.csv(down_ind, 'data/krx_ind.csv')

# ======================================================== #

# 최근 영업일 기준 데이터 받기

# library
library(httr)
library(rvest)
library(readr)

## 네이버 금융의 "증시자금동향"에는 이전 2 영업일에 해당하는 날짜가 자동으로 업데이트된다. -> 크롤링해 쿼리에 사용 가능.

## Xpath 이용하면 효율적.

# 네이버 증시작므동향 고객 예탁금 Xpath 
//*[@id="type_0"]/div/ul[2]/li/span

# 크롤링
url = 'https://finance.naver.com/sise/sise_deposit.nhn'

biz_day = GET(url) %>%
  read_html(encoding = 'EUC-KR') %>%
  #Xpath입력으로 해당 지점의 데이터 추출
  html_nodes(xpath = '//*[@id="type_0"]/div/ul[2]/li/span') %>%
  #텍스트 데이터만 추출
  html_text() %>%
  #정규 표현식을 사용해 숫자.숫자.숫자 형태 데이터 추출
  str_match(('[0-9]+.[0-9]+.[0-9]+')) %>%
  #마침표 삭제
  str_replace_all('\\.', '')
  
print(biz_day)



## 코드 종합

#library
library(httr)
library(rvest)
library(stringr)
library(readr)


# 최근 영업일 구하기
url = 'https://finance.naver.com/sise/sise_deposit.nhn'


biz_day = GET(url) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes(xpath = '//*[@id="type_0"]/div/ul[2]/li/span') %>%
  html_text() %>%
  str_match(('[0-9]+.[0-9]+.[0-9]+')) %>%
  str_replace_all('\\.','')
  
# 코스피 업종 분류 OTP 발급
gen_otp_url = 'https://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
gen_otp_data = list(mktId = 'STK',
  trdDd = biz_day, #최근 영업일로 변경
  money = '1',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT03901')
otp+ POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

#코스피 업종분류 데이터 다운
down_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
down_sector_KS = POST(down_url, query = list(code = otp), add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv()
  
#코스닥 업종분류 OTP 발급

gen_otp_data=list(mktId = 'KSQ',
  trdDd = biz_day, #최근 영업일로 변경
  money = '1',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/NDCSTAT03901')
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()
  
#코스닥 업종분류 데이터 다운로드
down_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
down_sector_KQ = POST(down_url, query = list(code =otp),
  add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv()
  
down_sector = rbind(down_sector_KS, down_sector_KQ)

ifelse(dir.exist('data'), FALSE, dir.create('data'))
wirte.csv(down_sector, 'data/krx_sector.csv')

#개별 종목 지표 OTP 발급
gen_otp_url = 'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
gen_otp_data = list( searchType = '1',
mktId = 'ALL',
trdDd = biz_dat, # 최근영업일로 변경
csvxls_isNo = 'false',
name= 'fileDown',
url = 'dbms/MDC/STAT/standard/MDCSTAT03501'
)
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text() %>%

#개별 종목 지표 데이터 다운로드
down_url - 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
down_ind = POST(down_url, query = list(code = otp),
add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%  
  html_text() %>%
  read_csv()

write.csv(down_ind, 'data/krx_ind.csv')



# ======================================================== #

# 거래소 데이터 정리
down_sector = read.csv('data/krx_sector.csv', row.names = 1,
  stringsAsFactors = FALSE)
  
down_ind = read.csv('data/drx_ind.csv', row.names = 1, stringAsFactors = FALSE)

## intersect() 함수로 중복되는 열 이름 체크
intersect(names(down_sector), names(down_ind))

## setdiff() 함수로 두 데이터에 공통적으로 없는 종목명 추출
setdiff(down_sector[,'종목명'], down_ind[,'종목명'])

## merge() 함수로 by기준 두 데이터를 하나로 합참.
## all = TRUE면 합집합, FALSE 면 교집합 반환
## 해당에선 공통으로 존재하는 항목을 원하므로 FALSE
kor_ticker = merge(down_sector, down_ind,
                    by = intersect(names(down_sector),
                                    names(down_ind)),
                    all = False)


## order() 함수를 통해 상대적인 순서 파악
## 앞에 -를 붙여 내림차순으로 정렬
KOR_ticker = KOR_ticker[order(-KOR_ticker['시가총액']), ]
print(head(KOR_ticker))


## grepl() 함수로 '스팩'이 종목명에 들어가는 종목을 찾음.
## stringr 패키지의 str_sub() 함수로 종목코드 끝이 0이 아닌 우선주 종목 찾기
library(stringr)

KOR_ticker[grepl('스팩', KOR_ticker[,'종목명']),'종목명']

KOR_ticker[str_sub(KOR_ticker[, '종목코드'], -1, -1) !=0, '종목명']

## 행 이름 초기화 후 csv 파일 저장
rownames(KOR_ticker) = NULL
write.csv(KOR_ticker, 'data/KOR_ticker.csv')
