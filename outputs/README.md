# SQLite DB 실습: 카페 주문 관리

## 주제

카페 주문 관리 데이터베이스를 SQLite로 설계했다.

고객, 메뉴, 주문, 주문상세 데이터를 테이블로 나누고 PK/FK 관계를 연결해서 `SELECT`, `JOIN`, `GROUP BY`, 서브쿼리, `UPDATE`, `DELETE`, 인덱스를 실습할 수 있도록 구성했다.

## ERD 다이어그램

![Cafe Order Database ERD](db_diagram.png)

## 제출 파일

| 파일 | 설명 |
| --- | --- |
| `01_schema.sql` | 테이블 생성, PK/FK/NOT NULL/UNIQUE/CHECK 제약조건 |
| `02_insert_sample_data.sql` | 샘플 데이터 입력 |
| `03_queries.sql` | 핵심 SQL 쿼리 15개 |
| `query_results/queries_result.txt` | 15개 쿼리 실행 결과 텍스트 |
| `query_results/screenshots/` | 쿼리별 실행 결과 캡처 이미지 15개 |
| `db_diagram.png` | ERD 다이어그램 이미지 |
| `cafe_order.sqlite` | SQL 실행이 반영된 SQLite DB 파일 |
| `README.md` | 상세 설명 문서 |

## 실행 방법

SQLite에 들어가서 순서대로 실행한다.

```bash
sqlite3 cafe_order.sqlite
```

```sql
.read 01_schema.sql
.read 02_insert_sample_data.sql
.read 03_queries.sql
```

터미널에서 한 번에 실행하려면 아래처럼 실행한다.

```bash
sqlite3 cafe_order.sqlite < outputs/01_schema.sql
sqlite3 cafe_order.sqlite < outputs/02_insert_sample_data.sql
sqlite3 cafe_order.sqlite < outputs/03_queries.sql
```

## 테이블 구성

| 테이블 | 역할 |
| --- | --- |
| `customer` | 고객 정보 저장 |
| `menu_category` | 메뉴 카테고리 저장 |
| `menu_item` | 실제 판매 메뉴 저장 |
| `cafe_order` | 주문 한 건 저장 |
| `order_item` | 주문 안에 들어간 메뉴 상세 저장 |

## 테이블 관계

| 관계 | 설명 |
| --- | --- |
| `customer(1) -> cafe_order(N)` | 고객 한 명은 여러 번 주문할 수 있다. |
| `cafe_order(1) -> order_item(N)` | 주문 한 건에는 여러 메뉴가 들어갈 수 있다. |
| `menu_category(1) -> menu_item(N)` | 카테고리 하나에는 여러 메뉴가 들어갈 수 있다. |
| `menu_item(1) -> order_item(N)` | 메뉴 하나는 여러 주문상세에 반복해서 등장할 수 있다. |

## `order_item`이 필요한 이유

주문 하나에는 여러 메뉴가 들어갈 수 있고, 메뉴 하나는 여러 주문에서 팔릴 수 있다.

즉 `cafe_order`와 `menu_item`은 실제로는 다대다 관계에 가깝다.

```text
cafe_order -> order_item -> menu_item
```

이 다대다 관계를 풀기 위해 중간에 `order_item` 테이블을 두었다. `order_item`은 단순 연결뿐 아니라 수량(`quantity`)과 주문 당시 가격(`unit_price`)도 저장하므로 주문상세 테이블이라고 볼 수 있다.

## 요구사항 반영 방식

| 요구사항 | 반영 방식 |
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
| 결과 확인 자료 | `query_results/queries_result.txt`와 `query_results/screenshots/`에 저장 |
| ERD 이미지 | `db_diagram.png` 생성 및 README에 표시 |

## 요구사항별 상세 설명

### 1. 최소 4개 테이블 생성

과제는 최소 4개 테이블을 요구한다. 이 프로젝트에서는 카페 주문 흐름을 표현하기 위해 5개 테이블을 만들었다.

| 테이블 | 왜 필요한가 |
| --- | --- |
| `customer` | 누가 주문했는지 저장하기 위해 필요하다. |
| `menu_category` | 메뉴를 커피, 라떼, 케이크처럼 분류하기 위해 필요하다. |
| `menu_item` | 실제 판매 메뉴 이름과 가격을 저장하기 위해 필요하다. |
| `cafe_order` | 고객이 주문한 주문 한 건을 저장하기 위해 필요하다. |
| `order_item` | 주문 한 건 안에 들어간 메뉴 목록을 저장하기 위해 필요하다. |

예를 들어 주문 한 건에 아메리카노 2개와 크루아상 1개가 들어갈 수 있으므로, 주문 자체는 `cafe_order`에 저장하고 주문 안의 메뉴들은 `order_item`에 따로 저장했다.

### 2. PK 적용

PK는 각 행을 구분하는 고유 번호다. 사람으로 치면 주민등록번호처럼 한 행을 정확히 찾기 위한 값이다.

`01_schema.sql`에서 모든 테이블에 PK를 넣었다.

```sql
customer_id INTEGER PRIMARY KEY AUTOINCREMENT
category_id INTEGER PRIMARY KEY AUTOINCREMENT
menu_item_id INTEGER PRIMARY KEY AUTOINCREMENT
order_id INTEGER PRIMARY KEY AUTOINCREMENT
order_item_id INTEGER PRIMARY KEY AUTOINCREMENT
```

`AUTOINCREMENT`를 사용했기 때문에 데이터를 넣을 때 번호를 직접 정하지 않아도 SQLite가 1, 2, 3처럼 자동으로 번호를 붙인다.

### 3. FK와 1:N 관계 적용

FK는 다른 테이블의 PK를 참조해서 테이블 사이의 관계를 만드는 값이다.

이 프로젝트에는 4개의 1:N 관계가 있다.

| 1:N 관계 | SQL에서 사용한 FK | 의미 |
| --- | --- | --- |
| `customer(1) -> cafe_order(N)` | `cafe_order.customer_id` | 고객 한 명은 여러 번 주문할 수 있다. |
| `cafe_order(1) -> order_item(N)` | `order_item.order_id` | 주문 한 건에는 여러 메뉴가 들어갈 수 있다. |
| `menu_category(1) -> menu_item(N)` | `menu_item.category_id` | 카테고리 하나에는 여러 메뉴가 들어갈 수 있다. |
| `menu_item(1) -> order_item(N)` | `order_item.menu_item_id` | 메뉴 하나는 여러 주문상세에 등장할 수 있다. |

스키마에서는 아래처럼 FK를 선언했다.

```sql
FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
FOREIGN KEY (category_id) REFERENCES menu_category(category_id)
FOREIGN KEY (order_id) REFERENCES cafe_order(order_id) ON DELETE CASCADE
FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id)
```

이 덕분에 존재하지 않는 고객 번호로 주문을 만들거나, 존재하지 않는 메뉴 번호로 주문상세를 만드는 일을 막을 수 있다.

### 4. NOT NULL, UNIQUE, CHECK 제약조건 적용

제약조건은 잘못된 데이터가 들어가지 않게 막는 규칙이다.

| 제약조건 | 적용한 곳 | 의미 |
| --- | --- | --- |
| `NOT NULL` | `customer.name`, `menu_item.price`, `cafe_order.order_datetime` 등 | 반드시 값이 있어야 한다. |
| `UNIQUE` | `customer.email`, `menu_category.category_name`, `menu_item.item_name` | 같은 값이 중복되면 안 된다. |
| `CHECK` | `price > 0`, `quantity > 0`, `unit_price > 0` | 가격과 수량은 0보다 커야 한다. |
| `CHECK` | `order_status IN ('PAID', 'COMPLETED', 'CANCELED')` | 주문 상태는 정해진 값만 허용한다. |

예를 들어 메뉴 가격이 0원이거나 음수면 실제 주문 데이터로 맞지 않기 때문에 아래 조건으로 막았다.

```sql
price INTEGER NOT NULL CHECK (price > 0)
```

### 5. 샘플 데이터 10행 이상 입력

`02_insert_sample_data.sql`에 샘플 데이터를 넣었다.

| 테이블 | 입력한 행 수 |
| --- | --- |
| `customer` | 10행 |
| `menu_category` | 10행 |
| `menu_item` | 12행 |
| `cafe_order` | 12행 |
| `order_item` | 20행 |

FK가 있는 테이블은 부모 데이터가 먼저 있어야 하므로 아래 순서로 데이터를 넣었다.

```text
customer, menu_category
-> menu_item
-> cafe_order
-> order_item
```

예를 들어 `order_item`은 주문 번호와 메뉴 번호를 참조하므로, 먼저 `cafe_order`와 `menu_item` 데이터가 있어야 한다.

## 핵심 쿼리 요구사항 상세 설명

### 기본 조회 4개 이상: Q01~Q04

기본 조회는 한 테이블에서 원하는 조건의 데이터를 찾는 쿼리다.

| 쿼리 | 만족한 조건 | 사용한 SQL 부분 | 설명 |
| --- | --- | --- | --- |
| Q01 | `WHERE`, `ORDER BY` | `WHERE joined_date >= '2026-03-01'`, `ORDER BY joined_date DESC` | 2026-03-01 이후 가입한 고객만 찾고, 최근 가입순으로 정렬한다. |
| Q02 | `WHERE`, `ORDER BY`, `LIMIT` | `WHERE price >= 6000`, `ORDER BY price DESC`, `LIMIT 5` | 6000원 이상 메뉴 중 비싼 메뉴 5개만 조회한다. |
| Q03 | `WHERE`, `ORDER BY` | `WHERE order_status = 'COMPLETED'`, `ORDER BY order_datetime DESC` | 완료된 주문만 최근순으로 조회한다. |
| Q04 | 검색 조건 | `WHERE name LIKE '%Lee%'` | 이름에 `Lee`가 들어간 고객을 검색한다. |

Q02는 과제에서 요구한 `LIMIT` 사용을 보여준다.

```sql
LIMIT 5
```

이 부분은 결과를 5개까지만 보여달라는 뜻이다.

### JOIN 4개 이상: Q05~Q08

JOIN은 나뉘어 저장된 테이블을 다시 연결해서 보는 기능이다.

| 쿼리 | JOIN 종류 | 연결한 테이블 | 연결 조건 | 설명 |
| --- | --- | --- | --- | --- |
| Q05 | `INNER JOIN` | `cafe_order` + `customer` | `cafe_order.customer_id = customer.customer_id` | 주문 정보에 고객 이름을 붙인다. |
| Q06 | `INNER JOIN` | `order_item` + `menu_item` | `order_item.menu_item_id = menu_item.menu_item_id` | 주문상세에 메뉴 이름을 붙인다. |
| Q07 | `INNER JOIN` | `menu_item` + `menu_category` | `menu_item.category_id = menu_category.category_id` | 메뉴가 어떤 카테고리에 속하는지 보여준다. |
| Q08 | `LEFT JOIN` | `customer` + `cafe_order` | `customer.customer_id = cafe_order.customer_id` | 고객별 주문 횟수를 구하되 주문이 없는 고객도 포함할 수 있다. |

Q05~Q07은 `INNER JOIN`이다. `INNER JOIN`은 양쪽 테이블에 연결되는 데이터가 있을 때만 결과에 나온다.

Q08은 `LEFT JOIN`이다.

```sql
FROM customer
LEFT JOIN cafe_order
ON customer.customer_id = cafe_order.customer_id
```

이렇게 쓰면 주문이 없는 고객도 고객 목록에는 남길 수 있다. 그래서 “고객별 주문 횟수”처럼 기준이 고객인 조회에 적합하다.

### 집계 3개 이상: Q09~Q11

집계는 여러 행을 묶어서 합계나 개수를 구하는 기능이다. 이 프로젝트에서는 `SUM`, `COUNT`, `GROUP BY`를 사용했다.

| 쿼리 | 사용한 집계 | 사용한 SQL 부분 | 설명 |
| --- | --- | --- | --- |
| Q08 | `COUNT` | `COUNT(cafe_order.order_id)` | 고객별 주문 횟수를 센다. |
| Q09 | `SUM`, `GROUP BY` | `SUM(quantity * unit_price)`, `GROUP BY order_id` | 주문별 총금액을 계산한다. |
| Q10 | `SUM`, `GROUP BY` | `SUM(order_item.quantity)`, `GROUP BY menu_item.menu_item_id` | 메뉴별 판매 수량을 계산한다. |
| Q11 | `SUM`, `GROUP BY` | `SUM(order_item.quantity * order_item.unit_price)`, `GROUP BY menu_item.menu_item_id` | 메뉴별 매출을 계산한다. |

과제 요구사항은 집계 3개 이상이고, 핵심 집계 쿼리는 Q09~Q11이다. Q08에도 `COUNT`가 들어 있어 주문 횟수 집계까지 확인할 수 있다.

예를 들어 Q09의 핵심은 아래 부분이다.

```sql
SUM(quantity * unit_price) AS order_total
GROUP BY order_id
```

뜻은 “같은 주문 번호끼리 묶고, 수량과 가격을 곱한 값을 모두 더해서 주문 총금액을 구한다”이다.

### 서브쿼리 1개 이상: Q12

서브쿼리는 쿼리 안에 들어 있는 또 다른 쿼리다.

Q12는 평균 메뉴 가격보다 비싼 메뉴를 찾는다.

```sql
WHERE price > (
    SELECT AVG(price)
    FROM menu_item
)
```

안쪽 쿼리:

```sql
SELECT AVG(price)
FROM menu_item
```

전체 메뉴의 평균 가격을 구한다.

바깥 쿼리:

```sql
SELECT item_name, price
FROM menu_item
WHERE price > ...
```

평균 가격보다 비싼 메뉴만 조회한다.

즉 Q12는 “먼저 평균 가격을 계산하고, 그 평균보다 비싼 메뉴를 찾는” 구조다.

### 인덱스 1개 이상: Q13

인덱스는 검색과 정렬을 빠르게 하기 위한 장치다.

Q13에서는 주문 시간을 기준으로 인덱스를 만들었다.

```sql
CREATE INDEX IF NOT EXISTS idx_cafe_order_order_datetime
ON cafe_order(order_datetime);
```

`order_datetime`은 “특정 날짜 이후 주문 찾기”나 “최근 주문순 정렬”에 자주 사용되므로 인덱스를 적용했다.

아래 쿼리로 SQLite가 인덱스를 사용할 수 있는지도 확인했다.

```sql
EXPLAIN QUERY PLAN
SELECT order_id, customer_id, order_datetime
FROM cafe_order
WHERE order_datetime >= '2026-06-03 00:00:00'
ORDER BY order_datetime;
```

실행 결과에 아래처럼 나오면 인덱스를 사용하는 것이다.

```text
SEARCH cafe_order USING INDEX idx_cafe_order_order_datetime
```

### UPDATE와 DELETE: Q14~Q15

데이터 수정과 삭제 요구사항은 Q14와 Q15에서 만족한다.

| 쿼리 | 사용한 명령 | 설명 |
| --- | --- | --- |
| Q14 | `UPDATE` | 6번 주문의 상태를 `COMPLETED`로 바꿔본다. |
| Q15 | `DELETE` | 취소된 10번 주문을 삭제해본다. |

Q14의 핵심은 아래 부분이다.

```sql
UPDATE cafe_order
SET order_status = 'COMPLETED'
WHERE order_id = 6;
```

뜻은 “6번 주문의 상태를 완료로 바꾼다”이다.

Q15의 핵심은 아래 부분이다.

```sql
DELETE FROM cafe_order
WHERE order_id = 10 AND order_status = 'CANCELED';
```

뜻은 “10번 주문이 취소 상태라면 삭제한다”이다.

Q14와 Q15에는 `BEGIN`과 `ROLLBACK`을 넣었다.

```sql
BEGIN;
...
ROLLBACK;
```

이렇게 하면 수정과 삭제 결과를 확인할 수 있지만, 마지막에 원래 상태로 되돌아간다. 실습용 데이터가 실제로 망가지지 않도록 하기 위한 처리다.

Q15에서는 `ON DELETE CASCADE`도 확인한다. `cafe_order`에서 주문이 삭제되면 그 주문에 연결된 `order_item`도 함께 삭제된다.

```sql
FOREIGN KEY (order_id) REFERENCES cafe_order(order_id) ON DELETE CASCADE
```

그래서 Q15는 삭제 전후의 주문상세 개수를 비교한다.

```text
before_delete: 1
after_delete: 0
```

이 결과는 주문이 삭제될 때 주문상세도 같이 삭제된다는 뜻이다.

## 핵심 쿼리 구성

| 구분 | 쿼리 |
| --- | --- |
| 기본 조회 | Q01~Q04 |
| JOIN | Q05~Q08 |
| GROUP BY 집계 | Q09~Q11 |
| 서브쿼리 | Q12 |
| 인덱스 | Q13 |
| UPDATE | Q14 |
| DELETE | Q15 |

## 인덱스 적용 이유

`cafe_order.order_datetime`은 주문 기간 검색과 최신순 정렬에 자주 사용되므로 `idx_cafe_order_order_datetime` 인덱스를 생성했다.
