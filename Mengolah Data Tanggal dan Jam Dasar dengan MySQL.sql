-- Mengolah Data Tanggal dan Jam Dasar dengan MySQL
-- Menampilkan data semua transaksi dari tabel dqlab_retail
SELECT * FROM dqlab_retail;
-- Menampilkan data semua transaksi dan menghitung subtotal
SELECT *, (Jumlah * Harga) AS subtotal
FROM dqlab_retail;
-- Menampilkan data transaksi, mulai dari: 1 April 2020 – 30 April 2020
SELECT * FROM dqlab_retail
WHERE tanggal BETWEEN '2020-04-01' AND '2020-04-30';
-- Menampilkan data total semua transaksi
SELECT SUM(Jumlah * Harga) as total
FROM dqlab_retail;
-- Menampilkan data tanggal, total (group per tanggal)
SELECT Tanggal, SUM(jumlah * harga) as total
FROM dqlab_retail
GROUP BY Tanggal;
-- Menampilkan data tahun, total (group per tahun)
SELECT YEAR(tanggal) as tahun, SUM(Harga * Jumlah) as total
FROM dqlab_retail
Group by Year(tanggal);
-- Membuat data tahun, bulan, total (group per tahun, bulan)
SELECT YEAR(tanggal) as tahun, MONTH(tanggal) as bulan, 
SUM(jumlah * harga) as total
FROM dqlab_retail
GROUP BY YEAR(tanggal), MONTH(tanggal);
-- Menampilkan data kodeproduk, namaproduk, total (group per kode produk)
SELECT kode_produk, nama_produk, SUM( Jumlah*Harga) as total
FROM dqlab_retail
GROUP BY kode_produk,nama_produk;
-- Menampilkan data tanggal, kodeproduk, namaproduk, totaljumlah, harga, total (group per tanggal, kode_produk, nama_produk, harga)!"
SELECT Tanggal, kode_produk, nama_produk,
SUM(jumlah) AS totaljumlah, harga, SUM(jumlah*harga) AS total
FROM dqlab_retail
GROUP BY Tanggal, kode_produk, nama_produk, harga;
--  Menampilkan data tahun, kodeproduk, namaproduk, totaljumlah, harga, total (group per tahun, kodeproduk)!
SELECT YEAR(Tanggal) AS tahun, kode_produk, nama_produk,
SUM(jumlah) AS totaljumlah, harga, SUM(jumlah*harga) AS total
FROM dqlab_retail
GROUP BY YEAR(Tanggal),kode_produk, nama_produk, harga;
-- Menampilkan data tahun, bulan, kodeproduk, namaproduk, totaljumlah, harga, total (group per tahun, bulan, kodeproduk)
SELECT YEAR(Tanggal) AS tahun, MONTH(Tanggal) AS bulan, kode_produk, nama_produk,
SUM(jumlah) AS totaljumlah, harga, SUM(jumlah*harga) AS total
FROM dqlab_retail
GROUP BY YEAR(Tanggal), Month(tanggal),kode_produk, nama_produk, harga;