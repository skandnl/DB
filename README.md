# SQLite DB 실습: 카페 주문 관리

## 주제

카페 주문 관리 데이터베이스를 SQLite로 설계했다.

고객, 메뉴, 주문, 주문상세 데이터를 테이블로 나누고 PK/FK 관계를 연결해서 `SELECT`, `JOIN`, `GROUP BY`, 서브쿼리, `UPDATE`, `DELETE`, 인덱스를 실습할 수 있도록 구성했다.

## ERD 다이어그램

![Cafe Order Database ERD](outputs/db_diagram.png)

## 제출 파일

| 파일 | 설명 |
| --- | --- |
| `outputs/01_schema.sql` | 테이블 생성, PK/FK/NOT NULL/UNIQUE/CHECK 제약조건 |
| `outputs/02_insert_sample_data.sql` | 샘플 데이터 입력 |
| `outputs/03_queries.sql` | 핵심 SQL 쿼리 15개 |
| `outputs/query_results/queries_result.txt` | 15개 쿼리 실행 결과 텍스트 |
| `outputs/query_results/screenshots/` | 쿼리별 실행 결과 캡처 이미지 15개 |
| `outputs/db_diagram.png` | ERD 다이어그램 이미지 |
| `outputs/cafe_order.sqlite` | SQL 실행이 반영된 SQLite DB 파일 |
| `outputs/README.md` | 상세 설명 문서 |

## 실행 방법

SQLite에 들어가서 순서대로 실행한다.

```bash
sqlite3 outputs/cafe_order.sqlite
```

```sql
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
| 결과 확인 자료 | `outputs/query_results/queries_result.txt`와 `outputs/query_results/screenshots/`에 저장 |
| ERD 이미지 | `outputs/db_diagram.png` 생성 및 README에 표시 |

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
