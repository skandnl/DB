# SQLite DB 실습 제출물

## 주제

카페 주문 관리 데이터베이스

## 실행 순서

```bash
sqlite3 outputs/cafe_order.sqlite
.read outputs/01_schema.sql
.read outputs/02_insert_sample_data.sql
.read outputs/03_queries.sql
```

터미널에서 한 번에 실행하려면 아래처럼 실행한다.

```bash
sqlite3 outputs/cafe_order.sqlite < outputs/01_schema.sql
sqlite3 outputs/cafe_order.sqlite < outputs/02_insert_sample_data.sql
sqlite3 outputs/cafe_order.sqlite < outputs/03_queries.sql
```

## 제출 파일

- `01_schema.sql`: 테이블 생성, PK/FK/NOT NULL/UNIQUE/CHECK 제약조건 포함
- `02_insert_sample_data.sql`: 샘플 데이터 입력
- `03_queries.sql`: 핵심 SQL 쿼리 15개
- `query_results/queries_result.txt`: 15개 쿼리 실행 결과 텍스트
- `cafe_order.sqlite`: 위 SQL을 실행해 만든 SQLite DB 파일
- `db_diagram.png`: 테이블 관계를 보여주는 ERD 이미지

## 테이블 관계

- `customer(1) -> cafe_order(N)`
- `cafe_order(1) -> order_item(N)`
- `menu_category(1) -> menu_item(N)`
- `menu_item(1) -> order_item(N)`

## 테이블 세부 내용

### `customer`

고객 정보를 저장한다.

| 컬럼 | 의미 | 제약 |
| --- | --- | --- |
| `customer_id` | 고객 고유 번호 | PK |
| `name` | 고객 이름 | NOT NULL |
| `email` | 고객 이메일 | NOT NULL, UNIQUE |
| `joined_date` | 가입일 | NOT NULL |

### `menu_category`

메뉴 분류를 저장한다.

| 컬럼 | 의미 | 제약 |
| --- | --- | --- |
| `category_id` | 카테고리 고유 번호 | PK |
| `category_name` | 카테고리 이름 | NOT NULL, UNIQUE |

### `menu_item`

실제 판매 메뉴를 저장한다.

| 컬럼 | 의미 | 제약 |
| --- | --- | --- |
| `menu_item_id` | 메뉴 고유 번호 | PK |
| `category_id` | 메뉴가 속한 카테고리 번호 | FK |
| `item_name` | 메뉴 이름 | NOT NULL, UNIQUE |
| `price` | 메뉴 가격 | NOT NULL, 0보다 커야 함 |

### `cafe_order`

주문 한 건을 저장한다. 주문 한 건은 영수증 한 장이라고 볼 수 있다.

| 컬럼 | 의미 | 제약 |
| --- | --- | --- |
| `order_id` | 주문 고유 번호 | PK |
| `customer_id` | 주문한 고객 번호 | FK |
| `order_datetime` | 주문 시간 | NOT NULL |
| `order_status` | 주문 상태 | `PAID`, `COMPLETED`, `CANCELED`만 허용 |

### `order_item`

주문 안에 들어간 메뉴 한 줄을 저장한다. 예를 들어 한 주문에 아메리카노 2개와 크루아상 1개가 있으면 `order_item`에는 2행이 들어간다.

| 컬럼 | 의미 | 제약 |
| --- | --- | --- |
| `order_item_id` | 주문상세 고유 번호 | PK |
| `order_id` | 어떤 주문에 속하는지 | FK |
| `menu_item_id` | 어떤 메뉴인지 | FK |
| `quantity` | 수량 | NOT NULL, 0보다 커야 함 |
| `unit_price` | 주문 당시 메뉴 가격 | NOT NULL, 0보다 커야 함 |

## 관계 분석

### `customer(1) -> cafe_order(N)`

고객 한 명은 여러 번 주문할 수 있다. 하지만 주문 한 건은 반드시 한 명의 고객에게 속한다.

예를 들어 `Kim Minjun` 고객이 1번 주문과 11번 주문을 했다면, `cafe_order`에는 같은 `customer_id`를 가진 주문이 여러 행 생길 수 있다.

### `cafe_order(1) -> order_item(N)`

주문 한 건에는 여러 메뉴가 들어갈 수 있다. 그래서 주문 자체는 `cafe_order`에 저장하고, 주문 안의 메뉴 목록은 `order_item`에 따로 저장한다.

예를 들어 1번 주문이 아래와 같다면:

```text
1번 주문
- Americano 2개
- Butter Croissant 1개
```

`cafe_order`에는 주문 1행만 저장되고, `order_item`에는 메뉴별로 2행이 저장된다.

### `menu_category(1) -> menu_item(N)`

카테고리 하나에는 여러 메뉴가 들어갈 수 있다.

예를 들어 `Coffee` 카테고리에는 `Americano`, `Cold Brew` 같은 여러 메뉴가 들어갈 수 있다.

### `menu_item(1) -> order_item(N)`

메뉴 하나는 여러 주문에서 반복해서 팔릴 수 있다.

예를 들어 `Americano`는 1번 주문에도 들어가고, 5번 주문에도 들어가고, 11번 주문에도 들어갈 수 있다. 그래서 `menu_item` 하나가 여러 `order_item` 행과 연결된다.

### `order_item`이 필요한 이유

`cafe_order`와 `menu_item`은 실제로는 다대다 관계에 가깝다.

```text
주문 하나에는 메뉴가 여러 개 들어갈 수 있고
메뉴 하나는 여러 주문에 들어갈 수 있다
```

이 관계를 바로 표현하지 않고 중간에 `order_item`을 둔다.

```text
cafe_order -> order_item -> menu_item
```

`order_item`은 단순 연결만 하는 테이블이 아니라, 수량(`quantity`)과 주문 당시 가격(`unit_price`)도 함께 저장한다. 그래서 주문상세라고 부른다.

## 단순화한 설계 기준

실습에 꼭 필요한 관계 중심으로만 설계했다.

- 고객은 이름, 이메일, 가입일만 저장한다.
- 카테고리는 카테고리 이름만 저장한다.
- 메뉴는 카테고리, 메뉴명, 가격만 저장한다.
- 주문은 고객, 주문 시간, 주문 상태만 저장한다.
- 주문 상세는 주문, 메뉴, 수량, 주문 당시 가격만 저장한다.

## 테이블별 샘플 데이터 수

- `customer`: 10행
- `menu_category`: 10행
- `menu_item`: 12행
- `cafe_order`: 12행
- `order_item`: 20행

## 요구사항 만족 방식

| 요구사항 | 만족 방식 |
| --- | --- |
| 로컬 DB 사용 | SQLite 사용 |
| 최소 4개 테이블 | 5개 테이블 생성: `customer`, `menu_category`, `menu_item`, `cafe_order`, `order_item` |
| 각 테이블 PK | 모든 테이블에 `INTEGER PRIMARY KEY AUTOINCREMENT` 적용 |
| 최소 2개 이상 1:N 관계 | 총 4개 1:N 관계 구성 |
| FK 사용 | `menu_item.category_id`, `cafe_order.customer_id`, `order_item.order_id`, `order_item.menu_item_id` |
| NOT NULL | 이름, 이메일, 가입일, 가격, 주문 시간, 주문 상태 등 주요 컬럼에 적용 |
| UNIQUE | `customer.email`, `menu_category.category_name`, `menu_item.item_name` |
| CHECK | `price > 0`, `quantity > 0`, `unit_price > 0`, 주문 상태 값 제한 |
| 각 테이블 10행 이상 | 모든 테이블에 10행 이상 샘플 데이터 입력 |
| 기본 조회 4개 이상 | Q01~Q04 |
| JOIN 4개 이상 | Q05~Q08 |
| 집계 3개 이상 | Q09~Q11 |
| 서브쿼리 1개 이상 | Q12 |
| UPDATE, DELETE | Q14, Q15 |
| 인덱스 1개 이상 | Q13에서 `idx_cafe_order_order_datetime` 생성 |
| 실행 결과 자료 | `query_results/queries_result.txt`에 쿼리별 결과 저장 |
| ERD 이미지 | `db_diagram.png` 생성 |

## 인덱스 적용 이유

`cafe_order.order_datetime`은 주문 기간 검색과 최신순 정렬에 자주 사용되므로 `idx_cafe_order_order_datetime` 인덱스를 생성했다.
