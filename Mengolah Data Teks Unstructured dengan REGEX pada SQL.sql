
-- Mengolah Data Teks Unstructured dengan REGEX pada SQL
-- menampilkan data pada tabel dqlabregex dengan kolom kota yang berakhiran 'ng'
SELECT * FROM dqlabregex WHERE kota REGEXP 'ng$'
-- menampilkan seluruh data dengan memfilter nama petugas pencatat pada kolom staf_pencatat di tabel dqlabregex dengan nama Senja atau Sendja.
SELECT * FROM dqlabregex WHERE staf_pencatat REGEXP 'Sen.?ja';
-- menampilkan semua data dengan kesalahan penulisan angka pada kolom jumlah_member.
SELECT * FROM dqlabregex WHERE jumlah_member REGEXP '[^0-9]';
-- mencari nama-nama staf_pencatat pada tabel yang diawali dengan 'an' dengan mengabaikan besar – kecilnya huruf.
SELECT * FROM dqlabregex WHERE REGEXP_LIKE(staf_pencatat, '^AN')
-- menampilkan semua data dengan memfilter nama petugas pencatat pada kolom staf_pencatat di tabel dqlabregex dengan nama SenDja atau Sen_ja. Namun kali ini abaikan besar-kecilnya huruf.
SELECT * FROM dqlabregex WHERE REGEXP_LIKE (staf_pencatat, 'Sen.?ja', 'i');
-- menampilkan kesalahan input data pada kolom jumlah_member lagi. Untungnya Andra juga memberiku tips untuk membuat sebuah query yang menampilkan semua data dengan kesalahan penulisan angka pada kolom jumlah_member dan abaikan kecil-besarnya huruf
SELECT * FROM dqlabregex WHERE REGEXP_LIKE( jumlah_member, '[^0-9]', 'i');
-- mengganti teks 'Sendja' menjadi 'Senja' pada kolom staf_pencatat. 
SELECT REGEXP_REPLACE(staf_pencatat, 'Sen.?ja', 'Senja') AS pencatat
FROM dqlabregex;
-- menghapus karakter non-numerik pada kolom jumlah_member
SELECT no_pencatatan, tanggal_catat, kota, REGEXP_REPLACE(jumlah_member, '[^0-9]', '') AS jumlah_member, staf_pencatat
FROM dqlabregex
-- merubah standarisasi penulisan tanggal DD-MM-YYYY (tanggal - bulan - tahun) menjadi MM/DD/YYYY (bulan / tanggal / tahun) 
SELECT tanggal_catat, REGEXP_REPLACE(tanggal_catat, '([0-9]{2})-([0-9]{2})-([0-9]{4})','$2/$1/$3') AS tanggal_pencatatan
FROM dqlabregex;
-- Pada kolom tanggal_catat ubah semua format tanggalnya menjadi format tanggal yang di-support oleh SQL salah satunya adalah format YYYY-MM-DD. 
-- Hapus setiap karakter non-numerik pada kolom jumlah_member.
-- Ubah record yang memuat Sendja maupun padanannya menjadi Senja.
-- Penamaan kolom dan urutannya tidak ada yang diubah.
SELECT no_pencatatan,
CASE
	WHEN REGEXP_LIKE(tanggal_catat, '([0-9]{2})-([0-9]{2})-([0-9]{4})')
		THEN REGEXP_REPLACE(tanggal_catat, '([0-9]{2})-([0-9]{2})-([0-9]{4})', '$3-$2-$1')
	ELSE
		REGEXP_REPLACE(tanggal_catat, '([0-9]{2})/([0-9]{2})/([0-9]{4})', '$3-$1-$2')
END AS tanggal_catat,
kota,
REGEXP_REPLACE(jumlah_member, '[^0-9]', '') AS jumlah_member,
REGEXP_REPLACE(staf_pencatat, 'Sen.?ja','Senja') AS staf_pencatat
FROM dqlabregex;
-- total dari kolom jumlah_member yang dikelompokkan berdasarkan staf_pencatat, lalu ingin mengurutkannya dari yang terkecil hingga yang terbesar.
SELECT 
	SUM(REGEXP_REPLACE(jumlah_member, '[^0-9]', '')) AS total_member, 
	REGEXP_REPLACE(staf_pencatat, 'Sen.?ja', 'Senja') AS staf_pencatat 
FROM dqlabregex 
GROUP BY 2 ORDER BY 1;