#DQLab
-- Mengolah Data Teks Dasar pada MySQL
-- Membaca data
SELECT * FROM dqlabdatateks;
-- Mencari posisi ‘|||’ ke-1 di field isi dari tabel dqlabdatateks
SELECT LOCATE('|||', dqlabdatateks.isi ) as posisi_1
FROM dqlabdatateks;
--  Mencari posisi ‘|||’ ke-2 di field isi dari tabel dqlabdatateks
SELECT LOCATE('|||', isi , LOCATE('|||',isi) + 1) as posisi_2
FROM dqlabdatateks;
--  Mencari posisi ‘|||’ ke-3 di field isi dari tabel dqlabdatateks
SELECT LOCATE('|||', isi, LOCATE('|||', isi, LOCATE('|||', isi) + 1) + 1) as posisi_3
FROM dqlabdatateks;
