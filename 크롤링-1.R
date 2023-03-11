#크롤링에는 

#인터넷 주소를 기준으로 데이터나 파일을 요청하는 GET 방식이 있고

#사용자가 필요한 값을 추가해서 요청하는 방식인 POST 방식이 있다.

#GET 방식은 요청하는 쿼리를 & 혹은 ? 형식으로 결합하는 반면

#POST 방식은 body에 넣어서 전송해 요청 내역을 확인 할 수 없다.

#또한 POST 방식은 사용하려면 [F12]키로 개발자 도구 화면을 이용해야 한다.


#크롤링을 할때 무한 크롤링을 하게 되면 서버 속도의 저하로 IP 차단을 당할 가능성이 있으므로 1 ~ 2초가량의 텀을 두는게 좋다.


##패키지 설치 및 구동

install.packages("rvest")
install.packages("httr")

library(rvest)
library(httr)
##네이버 주식 속보 GET 방식 크롤링

url = paste0('https://finance.naver.com/news/news_list.naver?', 'mode=LSS2D&section_id=101&section_id2=258')

data = GET(url)
print(data)

##charset(인코딩) 이 EUC-KR로 되어 있는 것을 확인


## 실시간 속보 제목 추출

data_title = data %>% 
  read_html(encoding = 'EUC-KR') %>%
    ### 해당 페이지의 html을 읽어옴.
  html_nodes('dl') %>%
    ### html_nodes()로 태그를 추출. 해당 태그는 dl.
  html_nodes('.articleSubject') %>%
    ### html_nodes() 를 이용해 articleSubject 부분 추출
    ### 클래스 속성의 경우 이름 앞에 마침표 붙이기.
  html_nodes('a') %>%
    ### html_nodes() 를 이용해 a태그 추출
  html_attr('title')
    ### html_attr() 로 함수의 속성 추출. title에 해당.

print(data_title)


##기업 공시 채널에서 크롤링하기

Sys.setlocale("LC_ALL", 'English')
  ### 한글로 크롤링하면 오류가 일어날수 있어서 영문으로 변환

url = 'https://kind.krx.co.kr/disclosure/todaydisclosure.do' 
data = POST(url,body = 
  ### post 함수를 이용해 url 요청
                  list(
                    method = 'serchTodayDisclosureSub',
                    currentPageSize = '15',
                    pageIndex = '1',
                    orderMode = '0',
                    orderStat = 'D',
                    forward = 'todaydisclosure_sub',
                    chose = 'S',
                    todayFlag = 'Y',
                    selDate = '2020-12-28'
                  ))

data = read_html(data) %>% 
  ### html 내용 불러오기
  html_table(fill = TRUE) %>%
   ### 테이블 형태의 데이터 불러오기 > 셀 병합열이 있으므로 fill=TRUE 추가
  .[[1]]
    ### 리스트 선택
  
Sys.setlocale("LC_ALL", "Korean")
  ### 한글 읽기 위해 로케일 언어 korean으로 변환.
  
print(head(data))
##네이버 주식에서 크롤링


i = 0
ticker = list()
  ### 빈리스트 ticker 생성
url = paste0('https://finance.naver.com/sise/',
              'sise_market_sum.nhn?sosok=',i,'&page=1') 
                ### 시총액 페이지 url 생성
              down_table = GET(url)
                ### GET() 함수를 통해 down_table에 변수저장

navi.final = read_html(down_table, encoding = 'EUC-KR') %>%
  ### html을 읽고, EUC-KR로 불러옴
  html_nodes(., '.pgRR') %>%
    ### html_nodes() 함수로 pgRR 클래스 정보를 불러오며, 클래스 속성이므로 앞에 . 붙임
  html_nodes(., 'a') %>%
    ### html_nodes()로 a 태그 정보면 불러들임
  html_attr(., 'href')
    ### html_attr() 함수를 통해 href 속성을 불러들임
  
print(navi.final)
              
navi.final = navi.final %>%
  strsplit(., '=') %>%
    ### strsplit() 함수로 특정 글자 기준으로 전체 문장을 나눔. page = 뒷부분이 필요하니 = 를 기준으로 분류
  unlist() %>%
    ### unlist() 함수를 통해 결과를 벡터 형태로 변환
  tail(., 1) %>%
    ### tail() 함수를 통해 뒤에서 첫 번째 데이터만 선택
  as.numeric()
    ### 값을 숫자 형태로 바꿈.
    
print(navi.final)

i = 0 #코스피
j = 1 #첫 번째 페이지

url = paste0('https://finance.naver.com/sise/',
              'sise_market_sum.nhn?sosok=',i,"&page=",j)
down_table = GET(url)


Sys.setlocale('LC_ALL', 'English')
table = read_html(down_table, encoding = 'EUC-KR') %>%
  html_table(fill=TRUE)
table = table[[2]]
Sys.setlocale('LC_ALL', 'Korean')

print(head(table))

table[, ncol(table)] = NULL
table = na.omit(table)
print(head(table))

### 티커 추출 코드
symbol = read_html(down_table, encoding = 'EUC-KR') %>%
  html_nodes(., 'tbody') %>%
  html_nodes(., 'td') %>%
  html_nodes(.,  'a') %>%
  html_attr(., 'href')
  
  ### href에 해당하는 6자리 코드 추출
print(head(symbol, 10))

  ### sapply()를 통해 function() 적용, substr() 함수 내에 nchar() 함수로 마지막 6글자만 추출
symbol = sapply(symbol, function(x) {
        substr(x, nchar(x) -5, nchar(x))
})

print(head(symbol, 10))

  ### 중복되는 값을 unique()로 정리
symbol = unique(symbol)
print(head(symbol, 10))

table$N = symbol
  ### 티커를 N열에 입력
colnames(table)[1] = '종목코드'
  ### 열 이름을 종목 코드로 변경

rownames(table) = NULL
  ### na.omit()으로 특정행 삭제했으므로, 행 이름 초기화
ticker[[j]] = table
  ### ticker의 j번째 리스트에 데이터 입력
i 와 j 값을 for loop 구문을 이용해 전 종목 티커 테이블 구현

data = list()

# i = 0 은 코스피, i = 1 은 코스닥
for(i in 0:1) {

  ticker = list()
  url = paste0('https://finance.naver.com/sise/',
                'sise_market_sum.nhn?sosok=', i, '&page=1')
  down_table = GET(url)

# 최종 페이지 번호 찾아주기
  navi.final = read_html(down_table, encoding = 'EUC-KR') %>%
    html_nodes(., '.pgRR') %>%
    html_nodes(., 'a') %>%
    html_attr(., 'href') %>%
    strsplit(., '=') %>%
    unlist() %>%
    tail(., 1) %>%
    as.numeric()
    
# 첫번째 부터 마지막 페이지 까지 for loop 이용 테이블 추출

  for(j in 1:navi.final) {
  
  # 각 페이지에 해당하는 url 생성
    url = paste0('https://finance.naver.com/sise/',
                  'sise_market_sum.nhn?sosok=',i, '&page=',j)
    down_table = GET(url)
    Sys.setlocale('LC_ALL', 'English')
    
    table = read_html(down_table, encoding = 'EUC-KR') %>%
      html_table(fill = TRUE)
    table = table[[2]]

    Sys.setlocale('LC_ALL', 'Korean')
    
    table[, ncol(table)] = NULL # 토론실 부분 삭제
    table = na.omit(table) # 빈 행 삭제
    
    # 6자리 티커만 추출
    symbol = read_html(down_table, encoding = 'EUC-KR') %>%
      html_nodes(., 'tbody') %>%
      html_nodes(., 'td') %>%
      html_nodes(., 'a') %>%
      html_attr(., 'href')
      
    symbol = sapply(symbol, function(x) {
      substr(x,nchar(x) - 5, nchar(x))
    }) %>% unique
    
    # 테이블에 티커 넣어준 뒤 테이블 정리
    table$N = symbol
    colnames(table)[1] = '종목코드'
    
    rownames(table) = NULL
    ticker[[j]] = table
    
    Sys.sleep(0.5) # 페이지당 0.5초의 슬립 적용
    }

  # do.call을 통해 리스트를 데이터 프레임으로 묶기
  ticker = do.call(rbind, ticker)
  data[[i + 1]] = ticker
}

# 코스피 코스닥 테이블 묶기
data = do.call(rbind, data)
