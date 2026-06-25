-- Cafe order sample data for SQLite
-- Run after 01_schema.sql.

PRAGMA foreign_keys = ON;

INSERT INTO customer (name, email, joined_date) VALUES
('Kim Minjun', 'minjun.kim@example.com', '2026-01-05'),
('Lee Seoyeon', 'seoyeon.lee@example.com', '2026-01-12'),
('Park Jiho', 'jiho.park@example.com', '2026-02-03'),
('Choi Hana', 'hana.choi@example.com', '2026-02-18'),
('Jung Doyeon', 'doyeon.jung@example.com', '2026-03-01'),
('Kang Yujin', 'yujin.kang@example.com', '2026-03-09'),
('Yoon Taemin', 'taemin.yoon@example.com', '2026-04-11'),
('Han Sora', 'sora.han@example.com', '2026-04-24'),
('Oh Jisoo', 'jisoo.oh@example.com', '2026-05-02'),
('Seo Jun', 'jun.seo@example.com', '2026-05-15');

INSERT INTO menu_category (category_name) VALUES
('Coffee'),
('Latte'),
('Tea'),
('Ade'),
('Smoothie'),
('Bread'),
('Cake'),
('Sandwich'),
('Seasonal Drink'),
('Goods');

INSERT INTO menu_item (category_id, item_name, price) VALUES
(1, 'Americano', 4500),
(1, 'Cold Brew', 5000),
(2, 'Cafe Latte', 5200),
(2, 'Vanilla Latte', 5800),
(3, 'Earl Grey Tea', 4800),
(4, 'Lemon Ade', 6000),
(5, 'Strawberry Smoothie', 6500),
(6, 'Butter Croissant', 4200),
(7, 'Basque Cheesecake', 6800),
(8, 'Chicken Sandwich', 7900),
(9, 'Peach Iced Tea', 6200),
(10, 'Reusable Tumbler', 15000);

INSERT INTO cafe_order (customer_id, order_datetime, order_status) VALUES
(1, '2026-06-01 09:10:00', 'COMPLETED'),
(2, '2026-06-01 12:30:00', 'COMPLETED'),
(3, '2026-06-02 08:45:00', 'COMPLETED'),
(4, '2026-06-02 14:20:00', 'COMPLETED'),
(5, '2026-06-03 10:05:00', 'COMPLETED'),
(6, '2026-06-03 18:40:00', 'PAID'),
(7, '2026-06-04 11:15:00', 'PAID'),
(8, '2026-06-04 13:50:00', 'COMPLETED'),
(9, '2026-06-05 16:25:00', 'COMPLETED'),
(10, '2026-06-05 19:05:00', 'CANCELED'),
(1, '2026-06-06 08:20:00', 'COMPLETED'),
(2, '2026-06-06 15:35:00', 'COMPLETED');

INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price) VALUES
(1, 1, 2, 4500),
(1, 8, 1, 4200),
(2, 3, 1, 5200),
(2, 9, 2, 6800),
(3, 4, 1, 5800),
(3, 5, 1, 4800),
(4, 6, 2, 6000),
(5, 10, 1, 7900),
(5, 1, 1, 4500),
(6, 7, 2, 6500),
(7, 2, 1, 5000),
(7, 8, 2, 4200),
(8, 11, 1, 6200),
(8, 9, 1, 6800),
(9, 12, 1, 15000),
(9, 3, 2, 5200),
(10, 6, 1, 6000),
(11, 1, 1, 4500),
(11, 10, 1, 7900),
(12, 4, 2, 5800);
