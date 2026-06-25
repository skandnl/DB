-- Cafe order core queries for SQLite
-- Run after 01_schema.sql and 02_insert_sample_data.sql.

PRAGMA foreign_keys = ON;

-- Q01. 기본 조회: 2026-03-01 이후 가입한 고객을 최근 가입순으로 확인한다.
SELECT customer_id, name, email, joined_date
FROM customer
WHERE joined_date >= '2026-03-01'
ORDER BY joined_date DESC;

-- Q02. 기본 조회: 가격이 6000원 이상인 메뉴를 비싼 순서로 최대 5개 확인한다.
SELECT menu_item_id, item_name, price
FROM menu_item
WHERE price >= 6000
ORDER BY price DESC
LIMIT 5;

-- Q03. 기본 조회: 완료된 주문을 최신순으로 확인한다.
SELECT order_id, customer_id, order_datetime, order_status
FROM cafe_order
WHERE order_status = 'COMPLETED'
ORDER BY order_datetime DESC;

-- Q04. 기본 조회: 이름에 'Lee'가 들어간 고객을 검색한다.
SELECT customer_id, name, email
FROM customer
WHERE name LIKE '%Lee%'
ORDER BY name;

-- Q05. INNER JOIN: 주문에 고객 이름을 붙여서 확인한다.
SELECT cafe_order.order_id,
       customer.name,
       cafe_order.order_datetime,
       cafe_order.order_status
FROM cafe_order
INNER JOIN customer
ON cafe_order.customer_id = customer.customer_id
ORDER BY cafe_order.order_datetime;

-- Q06. INNER JOIN: 주문상세에 메뉴 이름을 붙여서 확인한다.
SELECT order_item.order_id,
       menu_item.item_name,
       order_item.quantity,
       order_item.unit_price
FROM order_item
INNER JOIN menu_item
ON order_item.menu_item_id = menu_item.menu_item_id
ORDER BY order_item.order_id, order_item.order_item_id;

-- Q07. INNER JOIN: 메뉴가 어떤 카테고리에 속하는지 확인한다.
SELECT menu_category.category_name,
       menu_item.item_name,
       menu_item.price
FROM menu_item
INNER JOIN menu_category
ON menu_item.category_id = menu_category.category_id
ORDER BY menu_category.category_name, menu_item.item_name;

-- Q08. LEFT JOIN: 주문이 없는 고객도 포함해 고객별 주문 횟수를 확인한다.
SELECT customer.customer_id,
       customer.name,
       COUNT(cafe_order.order_id) AS order_count
FROM customer
LEFT JOIN cafe_order
ON customer.customer_id = cafe_order.customer_id
GROUP BY customer.customer_id, customer.name
ORDER BY order_count DESC, customer.customer_id;

-- Q09. 집계: 주문별 총금액을 계산한다.
SELECT order_id, SUM(quantity * unit_price) AS order_total
FROM order_item
GROUP BY order_id
ORDER BY order_total DESC;

-- Q10. 집계: 메뉴별로 몇 개 팔렸는지 계산한다.
SELECT menu_item.item_name,
       SUM(order_item.quantity) AS sold_quantity
FROM order_item
INNER JOIN menu_item
ON order_item.menu_item_id = menu_item.menu_item_id
GROUP BY menu_item.menu_item_id, menu_item.item_name
ORDER BY sold_quantity DESC;

-- Q11. 집계: 메뉴별 매출을 계산한다.
SELECT menu_item.item_name,
       SUM(order_item.quantity * order_item.unit_price) AS sales_amount
FROM order_item
INNER JOIN menu_item
ON order_item.menu_item_id = menu_item.menu_item_id
GROUP BY menu_item.menu_item_id, menu_item.item_name
ORDER BY sales_amount DESC;

-- Q12. 서브쿼리: 평균 메뉴 가격보다 비싼 메뉴를 찾는다.
SELECT item_name, price
FROM menu_item
WHERE price > (
    SELECT AVG(price)
    FROM menu_item
)
ORDER BY price DESC;

-- Q13. 인덱스: 주문 일시 검색과 정렬이 자주 발생하므로 order_datetime에 인덱스를 만든다.
CREATE INDEX IF NOT EXISTS idx_cafe_order_order_datetime
ON cafe_order(order_datetime);

-- Q13 확인: SQLite 전용 EXPLAIN QUERY PLAN으로 인덱스 사용 가능성을 확인한다.
EXPLAIN QUERY PLAN
SELECT order_id, customer_id, order_datetime
FROM cafe_order
WHERE order_datetime >= '2026-06-03 00:00:00'
ORDER BY order_datetime;

-- Q14. UPDATE: 6번 주문의 상태를 완료로 바꾸고 확인한다.
BEGIN;
UPDATE cafe_order
SET order_status = 'COMPLETED'
WHERE order_id = 6;
SELECT order_id, order_status
FROM cafe_order
WHERE order_id = 6;
ROLLBACK;

-- Q15. DELETE: 취소 주문을 삭제하면 주문 상세도 함께 삭제되는지 확인한다.
BEGIN;
SELECT 'before_delete' AS phase, COUNT(*) AS canceled_order_items
FROM order_item
WHERE order_id = 10;
DELETE FROM cafe_order
WHERE order_id = 10 AND order_status = 'CANCELED';
SELECT 'after_delete' AS phase, COUNT(*) AS canceled_order_items
FROM order_item
WHERE order_id = 10;
ROLLBACK;
