# 한국 거래소 크롤링


## 패키지 구동

library(rvest)
library(httr)
library(readr)
http://data.krx.co.kr/contents/MDC/MDI/mdiLoader/index.cmd?menuId=MDC0201020506

 
## KRX 정보데이터시스템
## 증권·파생상품의 시장정보(Marketdata), 공매도정보, 투자분석정보(SMILE) 등 한국거래소의 정보데이터를 통합하여 제공 서비스

data.krx.co.kr

## KRX 정보데이터 시스템에서 개발자 도구로 쿼리 및 OTP 확인.

#POST 방식 데이터 요청


## OTP 생성 및 제출

gen_otp_url = 'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
gen_otp_data = list( ## mktId의 STK는 코스피. 코스닥은 KSQ
  mktId = 'STK',
  trdDd = '20210108',
  money = '1',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT03901'
)

otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()
## 첫번째 URL에서 OTP 받음 > 두번째에 제출 근데 OTP를 두번째에 바로 제출하면 데이터 반환 X 그래서 add_headers() 함수를 통해 과정을 흔적으로 남김.

down_url = 'https://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
down_sector_KS = POST(down_url, query = list(code = otp),
    add_headers(referer = gen_otp_url)) %>% 
    ## add_headers()를 통해 웹사이트로 방문할 때 남는 흔적인 리퍼러를 추가. 
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv()

print(down_sector_KS)

#코스닥도 동일 시행

## 코스닥 시장도 시행
get_otp_data = list(
  mktId = 'KSQ', #코스닥으로 변경
  trdDd = '20210108',
  money = '1',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT03901'
)
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()
  
down_sector_KQ = POST(down_url, query = list(code = otp),
                      add_headers(referer = gen_otp_url)) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_text() %>%
  read_csv
#섹터 합치기

down_sector = rbind(down_sector_KS, down_sector_KQ)
View(down_sector)
