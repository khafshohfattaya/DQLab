-- AKTIFKAN LOAD DATA LOKAL
SET GLOBAL local_infile = 1;

-- PAKAI DATABASE YANG KAMU BUAT
USE ecommerce;

-- BUAT TABEL JIKA BELUM ADA
CREATE TABLE order_details_ (
    order_detail_id INT,
    order_id INT,
    product_id INT,
    price INT,
    quantity INT
);

-- IMPORT DATA CSV-NYA
LOAD DATA LOCAL INFILE 'D:/SQL/data/order_details.csv'
INTO TABLE order_details_
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from order_details_;
SHOW WARNINGS;

CREATE TABLE orders (
    order_id INT,
    seller_id INT,
    buyer_id INT,
    kodepos INT,
    subtotal INT,
    discount INT,
    total INT,
    created_at DATE,
    paid_at DATE,
    delivery_at DATE
);
LOAD DATA LOCAL INFILE 'D:/SQL/data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM orders;

CREATE TABLE products(
    product_id INT,
    desc_product VARCHAR(255),
    category VARCHAR(100),
    best_price INT);

LOAD DATA LOCAL INFILE 'D:/SQL/data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM products;

CREATE TABLE users(
    user_id INT,
    nama_user VARCHAR(255),
    kodepos INT,
    email VARCHAR(255));

LOAD DATA LOCAL INFILE 'D:/SQL/data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM users;

-- ------------------------------------------------------ ANALISIS DATA -------
-- 10 Transaksi terbesar user 12476 --

SELECT seller_id, buyer_id, total AS nilai_transaksi,
created_at as tanggal_transaksi
from orders
where buyer_id = 12476
order by 3 DESC
limit 10;

-- summary perbulan 2020

select EXTRACT(YEAR_MONTH FROM created_at) as tahun_bulan, count(1) as jumlah_transaksi, sum(total) as total_nilai_transaksi
from orders
where created_at >='2020-01-01'
group by 1
order by 1;

-- Pengguna dengan rata-rata transaksi terbesar di Januari 2020

select buyer_id, count(1) as jumlah_transaksi, avg(total) as avg_total_transaksi
from orders
where created_at>='2020-01-01' and created_at<'2020-02-01'
group by 1
having count(1)>= 2 
order by 3 desc
limit 10;

-- Transaksi besar di Desember 2019 dengan nilai transaksi minimal 20,000,000
select nama_user as nama_pembeli, total as nilai_transaksi, created_at as tanggal_transaksi
from orders
inner join users on buyer_id = user_id
where created_at>='2019-12-01' and created_at<'2020-01-01'
and total >= 20000000
order by 1;

-- Kategori Produk Terlaris di 2020, hanya untuk transaksi yang sudah terkirim ke pembeli. 
select category, sum(quantity) as total_quantity, sum(price) as total_price
from orders
inner join order_details_ using(order_id)
inner join products using(product_id)
where created_at>='2020-01-01'
and delivery_at is not null
group by 1;

-- pembeli high value
select nama_user as nama_pembeli, count(1) as jumlah_transaksi, sum(total) as total_nilai_transaksi, min(total) as min_nilai_transaksi
from orders
inner join users on buyer_id = user_id
group by user_id, nama_user
having count(1) > 5 and min(total)>2000000
order by 3 desc;
-- Mencari Dropshipper
#mencari pembeli dengan 10 kali transaksi atau lebih yang alamat pengiriman transaksi 
#selalu berbeda setiap transaksi.
select nama_user as nama_pembeli, count(1) as jumlah_transaksi, count(distinct orders.kodepos) as distinct_kodepos, sum(total) as total_nilai_transaksi, avg(total) as avg_nilai_transaksi
from orders
inner join users on buyer_id = user_id
group by user_id, nama_user
having count(1) >= 10 and count(1) = count(distinct orders.kodepos)
order by 2 desc;
-- #Mencari Reseller Offline : pembeli yang sering sekali membeli barang dan seringnya dikirimkan ke alamat yang sama. Pembelian juga dengan quantity produk yang banyak. Sehingga kemungkinan barang ini akan dijual lagi.
#mencari pembeli yang punya 8 tau lebih transaksi yang alamat pengiriman transaksi sama dengan alamat pengiriman utama, dan rata-rata total quantity per transaksi lebih dari 10.
#kandidat reseller
select nama_user as nama_pembeli, count(1) as jumlah_transaksi, sum(total) as total_nilai_transaksi, avg(total) as avg_nilai_transaksi, avg(total_quantity) as avg_quantity_per_transaksi
from orders
inner join users on buyer_id = user_id
inner join (select order_id, sum(quantity) as total_quantity from order_details_ group by 1) as summary_order using(order_id) 
where orders.kodepos = users.kodepos
group by user_id, nama_user
having count(1)>=8  and avg(total_quantity)>10
order by 3 desc;
-- #Pembeli sekaligus penjual
#mencari penjual yang juga pernah bertransaksi sebagai pembeli minimal 7 kali.
select nama_user as nama_pengguna, jumlah_transaksi_beli, jumlah_transaksi_jual
from users
inner join (select buyer_id, count(1) as jumlah_transaksi_beli from orders group by 1) as buyer on buyer_id = user_id
inner join (select seller_id, count(1) as jumlah_transaksi_jual from orders group by 1) as seller on seller_id = user_id
where jumlah_transaksi_beli>=7
order by 1;
-- Lama waktu dibayar
SELECT
    EXTRACT(
        YEAR_MONTH
        FROM
            created_at
    ) AS tahun_bulan,
    COUNT(1) AS jumlah_transaksi,
    AVG(DATEDIFF(paid_at, created_at)) AS avg_lama_dibayar,
    MIN(DATEDIFF(paid_at, created_at)) min_lama_dibayar,
    MAX(DATEDIFF(paid_at, created_at)) max_lama_dibayar
FROM
    orders
WHERE
    paid_at IS NOT NULL
GROUP BY
    1
ORDER BY
    1;
