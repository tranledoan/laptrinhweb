-- 1. Truy vấn danh sách người dùng theo thứ tự tên Alphabet (A->Z)
SELECT * FROM users ORDER BY user_name ASC;

-- 2. Lấy ra 07 người dùng theo thứ tự tên Alphabet (A->Z)
SELECT * FROM users ORDER BY user_name ASC LIMIT 7;

--33. Lấy danh sách người dùng có chữ 'a' trong tên
SELECT * FROM users WHERE user_name LIKE '%a%' ORDER BY user_name ASC;

-- 4. Lấy danh sách người dùng có tên bắt đầu bằng 'm'
SELECT * FROM users WHERE user_name LIKE 'm%';

-- 5. Lấy danh sách người dùng có tên kết thúc bằng 'i'
SELECT * FROM users WHERE user_name LIKE '%i';

-- 6. Lấy danh sách người dùng có email là Gmail
SELECT * FROM users WHERE user_email LIKE '%@gmail.com';

-- 7. Lấy danh sách người dùng có email là Gmail và tên bắt đầu bằng 'm'
SELECT * FROM users WHERE user_email LIKE '%@gmail.com' AND user_name LIKE 'm%';

-- 8. Lấy danh sách người dùng có email là Gmail, tên có chữ 'i' và tên dài hơn 5 ký tự
SELECT * FROM users WHERE user_email LIKE '%@gmail.com' AND user_name LIKE '%i%' AND LENGTH(user_name) > 5;

-- 9. Lấy danh sách người dùng có chữ 'a' trong tên, chiều dài từ 5 đến 9, email Gmail, và trong tên email có chữ 'i'
SELECT * FROM users WHERE user_name LIKE '%a%' AND LENGTH(user_name) BETWEEN 5 AND 9 AND user_email LIKE '%@gmail.com' AND SUBSTRING_INDEX(user_email, '@', 1) LIKE '%i%';

-- 10. Lấy danh sách người dùng có chữ 'a' trong tên (5-9 ký tự) hoặc tên có chữ 'i' (dưới 9 ký tự) hoặc email Gmail có chữ 'i'
SELECT * FROM users WHERE (user_name LIKE '%a%' AND LENGTH(user_name) BETWEEN 5 AND 9) 
   OR (user_name LIKE '%i%' AND LENGTH(user_name) < 9) 
   OR (user_email LIKE '%@gmail.com' AND SUBSTRING_INDEX(user_email, '@', 1) LIKE '%i%');

--B. Truy vấn đơn hàng
-- 1. Liệt kê các hóa đơn của khách hàng
SELECT u.user_id, u.user_name, o.order_id
FROM users u
JOIN orders o ON u.user_id = o.user_id;

-- 2. Liệt kê số lượng các hóa đơn của khách hàng
SELECT u.user_id, u.user_name, COUNT(o.order_id) AS order_count
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name;

-- 3. Liệt kê thông tin hóa đơn: mã đơn hàng, số sản phẩm
SELECT o.order_id, COUNT(od.product_id) AS product_count
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id;

-- 4. Liệt kê thông tin mua hàng của người dùng (gom nhóm theo đơn hàng)
SELECT u.user_id, u.user_name, o.order_id, GROUP_CONCAT(p.product_name SEPARATOR ', ') AS products
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY o.order_id, u.user_id, u.user_name;

-- 5. Liệt kê 7 người dùng có số lượng đơn hàng nhiều nhất
SELECT u.user_id, u.user_name, COUNT(o.order_id) AS order_count
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name
ORDER BY order_count DESC
LIMIT 7;

-- 6. Liệt kê 7 người dùng mua sản phẩm có tên Samsung hoặc Apple
SELECT DISTINCT u.user_id, u.user_name, o.order_id, p.product_name
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE p.product_name LIKE '%Samsung%' OR p.product_name LIKE '%Apple%'
LIMIT 7;

-- 7. Liệt kê danh sách mua hàng của user bao gồm tổng tiền mỗi đơn hàng
SELECT u.user_id, u.user_name, o.order_id, SUM(p.product_price) AS total_price
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY o.order_id, u.user_id, u.user_name;

-- 8. Liệt kê danh sách mua hàng của user với đơn hàng có giá trị lớn nhất
SELECT user_id, user_name, order_id, total_price FROM (
    SELECT u.user_id, u.user_name, o.order_id, SUM(p.product_price) AS total_price,
           RANK() OVER (PARTITION BY u.user_id ORDER BY SUM(p.product_price) DESC) AS rnk
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY o.order_id, u.user_id, u.user_name
) ranked_orders WHERE rnk = 1;

-- 9. Liệt kê danh sách mua hàng của user với đơn hàng có giá trị nhỏ nhất
SELECT user_id, user_name, order_id, total_price, product_count FROM (
    SELECT u.user_id, u.user_name, o.order_id, SUM(p.product_price) AS total_price, COUNT(od.product_id) AS product_count,
           RANK() OVER (PARTITION BY u.user_id ORDER BY SUM(p.product_price) ASC) AS rnk
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY o.order_id, u.user_id, u.user_name
) ranked_orders WHERE rnk = 1;

-- 10. Liệt kê danh sách mua hàng của user với đơn hàng có số sản phẩm nhiều nhất
SELECT user_id, user_name, order_id, total_price, product_count FROM (
    SELECT u.user_id, u.user_name, o.order_id, SUM(p.product_price) AS total_price, COUNT(od.product_id) AS product_count,
           RANK() OVER (PARTITION BY u.user_id ORDER BY COUNT(od.product_id) DESC) AS rnk
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY o.order_id, u.user_id, u.user_name
) ranked_orders WHERE rnk = 1;