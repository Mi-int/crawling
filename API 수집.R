#먼저 quantmod 패키지를 설치한다.

#퀀트 투자에 유용한 패키지이며, 볼린저, 이동평균선, RSI 등의 차트를 그릴 수 있다.

install.packages("quantmod")
library(quantmod)

## API 확인.
url.aapl = "https://www.quandl.com/api/v3/datasets/WIKI/AAPL/data.csv?api_key=xw3NU3xLUZ7vZgrz5QnG"

data.aapl = read.csv(url.aapl)

head(data.aapl)
#야후 파이낸스에서 API를 수집하려고 한다.

## 애플 종목 확인
getSymbols('AAPL')
head(AAPL)

## 시계열 그래프 작성
chart_Series(Ad(AAPL))

#quantmod에 내장되어있는 getSymbols() 함수를 통해 API 데이터를 다운로드 할 수 있다.

## from ~ to 데이터 기간 설정 가능
##  auto.assign = false로 변수 저장

data = getSymbols('AAPL', from = '2000-01-01', to = '2022-12-31', auto.assign = FALSE)

## 두 종목 순차 다운로드

fbnvda = c('META','NVDA')

getSymbols(fbnvda)
#국내 주가 또한 다운로드 가능하다. 단, 종목 코드를 입력하고, 코스피는 KS, 코스닥은 KQ를 뒤에 붙여야 한다. 

## 국내 주가 다운로드 (코스피 - 삼전)

getSymbols('005930.KS')

## Ad()로 수정주가 확인 ` 붙여야함

tail(Ad(`005930.KS`))

## 종가데이터 활용

tail(Cl(`005930.KS`))
### 배당고려는 불가하나 Ad() 비헤 오류가 없음.


## 국내 주가 다운로드 (코스닥 - 셀트리온)

getSymbols('068760.KQ')

tail(Cl(`068760.KQ`))
#FRED 데이터는 미국 및 각국 중요 경제 지표이다.

getSymbols('DGS10', src='FRED')
### 국채 10년물 금리 - DGS10
### FRED 에서 티커 확인 가능.

## 그래프 작성
chart_Series(DGS10)

## DEXKOUS 목록 추출 및 그래프 작성
getSymbols('DEXKOUS', src = 'FRED')

tail(DEXKOUS)

chart_Series(DEXKOUS)
