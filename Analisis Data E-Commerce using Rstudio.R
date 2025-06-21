install.packages("openxlsx")  # hanya sekali saja
library(openxlsx)
# order-details
data <- read.csv2("D:/SQL/data e-commerce/order_details.csv")
library(writexl)
write_xlsx(data, "D:/SQL/data e-commerce/order_details_xl.xlsx")
library(readxl)
order_details_xl <- read_excel("D:/SQL/data e-commerce/order_details_xl.xlsx")
View(order_details_xl)
#=============================================================================================
# orders
data2 <- read.csv2("D:/SQL/data e-commerce/orders.csv")
library(writexl)
write_xlsx(data2, "D:/SQL/data e-commerce/orders_xl.xlsx")
library(readxl)
orders_xl <- read_excel("D:/SQL/data e-commerce/orders_xl.xlsx")
View(orders_xl)
##memastikan koom created_at dalam format tanggal
orders_xl$created_at <- as.Date(orders_xl$created_at)
#kolom baru tahun-bulan
orders_xl$year_month <- format(orders_xl$created_at, "%Y-%m")
#menghitung total penjualan tiap bulan
monthly_summary <- aggregate(total ~ year_month, data = orders_xl, sum)
print(monthly_summary)
#menghitung jumlah transaksi perbulan
monthly_count <- aggregate(order_id ~ year_month, data = orders_xl, length)
print(monthly_count)
#mengecek status pembayaran
orders_xl$created_at <- as.Date(orders_xl$created_at)
orders_xl$paid_at <- as.Date(orders_xl$paid_at)
orders_xl$delivery_at <- as.Date(orders_xl$delivery_at)
#transaksi yang tidak dibayar
sum(is.na(orders_xl$paid_at))
#transaksi dibayar tapi belum terkirim
sum(!is.na(orders_xl$paid_at) & is.na(orders_xl$delivery_at))
#transaksi yang tidak dikirim
sum(is.na(orders_xl$delivery_at))
#transaksi yang dikirim di hari yang sama dengan dibayar
sum(orders_xl$paid_at == orders_xl$delivery_at, na.rm = TRUE)

#=====================================================================================================
# products
data3 <- read.csv2("D:/SQL/data e-commerce/products.csv")
library(writexl)
write_xlsx(data3, "D:/SQL/data e-commerce/products_xl.xlsx")
library(readxl)
products_xl <- read_excel("D:/SQL/data e-commerce/products_xl.xlsx")
View(products_xl)
any(is.na(products_xl)) #Mengecek apakah ada null

#=====================================================================================================
# users
data4 <- read.csv2("D:/SQL/data e-commerce/users.csv")
library(writexl)
write_xlsx(data4, "D:/SQL/data e-commerce/users_xl.xlsx")
library(readxl)
users_xl <- read_excel("D:/SQL/data e-commerce/users_xl.xlsx")
View(users_xl)

#mencari total pengguna
nrow(users_xl)

#total pembeli
pengguna_pembeli <- unique(orders_xl$buyer_id)
jumlah_pembeli <- sum(users_xl$user_id %in% pengguna_pembeli)
print(jumlah_pembeli)

#total penjual
pengguna_penjual <- unique(orders_xl$seller_id)
jumlah_penjual <- sum(users_xl$user_id %in% pengguna_penjual)
print(jumlah_penjual)

#jumlah yang menjadi pembeli dan penjual
pembeli_dan_penjual <- intersect(pengguna_pembeli, pengguna_penjual)
jumlah_keduanya <- sum(users_xl$user_id %in% pembeli_dan_penjual)
jumlah_keduanya

#tidak pernah jadi pembeli maupun penjual
tidak_transaksi <- users_xl[!(users_xl$user_id %in% c(pengguna_pembeli, pengguna_penjual)), ]
jumlah_tidak_transaksi <- nrow(tidak_transaksi)
jumlah_tidak_transaksi

#=======================================================================
#pembelian terbesar
library(dplyr)

top_buyer <- orders_xl %>%
  group_by(buyer_id) %>%
  summarise(total_belanja = sum(total, na.rm = TRUE)) %>%
  arrange(desc(total_belanja)) %>%
  slice_head(n = 5)
print(top_buyer)

#jika diurutkan bersadar nama user_id
top_buyer_info <- top_buyer %>%
  left_join(users_xl, by = c("buyer_id" = "user_id")) %>%
  select(user_id = buyer_id, nama_user, total_belanja)
print(top_buyer_info)

#============================================================================
#yang tidak pernah diskon
library(dplyr)
top_no_disc <- orders_xl %>%
  filter(discount==0) %>%
  group_by(buyer_id) %>%
  summarise(jumlah_transaksi = n()) %>%
  arrange(desc(jumlah_transaksi))%>%
  slice_head(n=5)
top_no_disc

#jika diurutkan bersadar nama user_id
top_nodisc_info <- top_no_disc %>%
  left_join(users_xl, by = c("buyer_id" = "user_id")) %>%
  select(user_id = buyer_id, nama_user, jumlah_transaksi)
print(top_nodisc_info)

#========================================================================
library(dplyr)
library(lubridate)  # untuk tahun dan bulan lebih mudah
# 1. Filter transaksi tahun 2020
data_2020 <- orders_xl %>%
  mutate(created_at = as.Date(created_at)) %>%
  filter(year(created_at) == 2020) %>%
  mutate(year_month = format(created_at, "%Y-%m"))
data_2020

#=======================================================================
# mencari domain penjual
penjual_id <- unique(orders_xl$seller_id)
penjual_email <- users_xl%>%
  filter(user_id %in% penjual_id) %>%
  select (email)
penjual_email$domain <- sub(".*@", "", penjual_email$email)
unique_domains <- unique(penjual_email$domain)
print(unique_domains)
#===================================================
#top 5 product Desember 2019
#Gabungkan order_details dengan tanggal transaksi
detail_with_date <- order_details_xl %>%
  left_join(orders_xl %>% 
              select(order_id, created_at), by = "order_id")
#Filter hanya bulan Desember 2019
dec_details <- detail_with_date %>%
  filter(format(created_at, "%Y-%m") == "2019-12")
#Gabungkan dengan data produk
dec_product_detail <- dec_details %>%
  left_join(products_xl, by = "product_id")

# 5. Hitung total quantity per produk
top5_produk <- dec_product_detail %>%
  group_by(desc_product) %>%
  summarise(total_qty = sum(quantity, na.rm = TRUE)) %>%
  arrange(desc(total_qty)) %>%
  slice_head(n = 5)
top5_produk
#=====================================================================
#10 transaksi terbesar user 12476
top10_transaksi_12476 <- orders_xl %>%
  filter(buyer_id == 12476) %>%
  arrange(desc(total))
top10_transaksi_12476
#======================================================================
#transaksi per bulan
library(dplyr)
library(lubridate)  # untuk tahun dan bulan lebih mudah
# 1. Filter transaksi tahun 2020
library(dplyr)
library(lubridate)

data_2020 <- orders_xl %>%
  mutate(created_at = as.Date(created_at)) %>%
  filter(year(created_at) == 2020) %>%
  mutate(year_month = format(created_at, "%Y-%m"))

total_per_bulan_2020 <- data_2020 %>%
  group_by(year_month) %>%
  summarise(
    jumlah_transaksi = n(),
    total_nilai_transaksi = sum(total, na.rm = TRUE)
  ) %>%
  arrange(year_month)

print(total_per_bulan_2020)
================================================================
# Pengguna dengan rata-rata transaksi terbesar di Januari 2020
library(dplyr)
library(lubridate)

# Filter data Januari 2020
data_jan2020 <- orders_xl %>%
  mutate(created_at = as.Date(created_at)) %>%
  filter(format(created_at, "%Y-%m") == "2020-01")

# Hitung rata-rata per buyer
rata_rata_trans_jan20 <- data_jan2020 %>%
  group_by(buyer_id) %>%
  summarise(
    jumlah_transaksi = n(),
    avg_nilai_transaksi = mean(total, na.rm = TRUE)
  ) %>%
  filter(jumlah_transaksi >= 2) %>%
  arrange(desc(avg_nilai_transaksi))   # Urutkan dari terbesar

print(rata_rata_trans_jan20)
#===================================================================
#Transaksi besar di Desember 2019
# Filter data desember 2019
data_des19 <- orders_xl %>%
  mutate(created_at = as.Date(created_at)) %>%
  filter(format(created_at, "%Y-%m") == "2019-12")

trans_des19 <- data_des19 %>%
  left_join(users_xl, by = c("buyer_id" = "user_id")) %>%
  select(nama_pembeli = nama_user, nilai_transaksi = total, tanggal_transaksi = created_at) %>%
  filter(nilai_transaksi >= 20000000) %>%
  arrange(nama_pembeli)
print(trans_des19)
#=====================================================================
#Kategori Produk Terlaris di 2020
data_delivery_2020 <- orders_xl %>%
  mutate(created_at = as.Date(created_at),
         delivery_at = as.Date(delivery_at)) %>%
  filter(created_at >= as.Date("2020-01-01"),
           !is.na(delivery_at)) 

produk_terlaris_2020 <- data_delivery_2020 %>%
  inner_join(order_details_xl, by = c("order_id" )) %>%
  inner_join(products_xl, by = c("product_id" )) %>%
  group_by(category) %>%
  summarise(
  total_quantity = sum(quantity, na.rm =TRUE),
  total_price = sum(price, na.rm = TRUE)) %>%
  arrange(desc(total_quantity))
print(produk_terlaris_2020)
#===========================================================================
#Pembeli High Value
pembeli_lebih_dari_5 <- orders_xl%>%
  group_by(buyer_id) %>%
  summarise(jumlah_transaksi = n(),
            total_nilai_transaksi = sum(total, na.rm =TRUE),
            min_nilai_transaksi = min(total, na.rm = TRUE)) %>%
  filter(jumlah_transaksi >5,
         min_nilai_transaksi > 2000000)%>%
  inner_join(users_xl, by = c("buyer_id" = "user_id" )) %>%
  select(nama_user, jumlah_transaksi, total_nilai_transaksi, min_nilai_transaksi)%>%
  arrange(desc(total_nilai_transaksi))
pembeli_lebih_dari_5

#===============================================================================================
#Mencari Dropshipper
#mencari pembeli dengan 10 kali transaksi atau lebih yang alamat pengiriman transaksi 
#selalu berbeda setiap transaksi.
dropshipper <- orders_xl %>%
  group_by(buyer_id) %>%
  summarise(jumlah_transaksi = n(),
            distinct_kodepos = n_distinct(kodepos),
            total_nilai_transaksi = sum(total,na.rm = TRUE),
            avg_nilai_transaksi = mean(total, na.rm = TRUE))%>%
  filter(jumlah_transaksi >=10, jumlah_transaksi == distinct_kodepos) %>%
  inner_join(users_xl, by = c("buyer_id" = "user_id" )) %>%
  select(nama_user, jumlah_transaksi, distinct_kodepos, total_nilai_transaksi, avg_nilai_transaksi)%>%
  arrange(desc(jumlah_transaksi))
dropshipper
#===================================================================================================================
#Mencari Reseller Offline : pembeli yang sering sekali membeli barang dan seringnya dikirimkan ke alamat yang sama. Pembelian juga dengan quantity produk yang banyak. Sehingga kemungkinan barang ini akan dijual lagi.
#mencari pembeli yang punya 8 tau lebih transaksi yang alamat pengiriman transaksi sama dengan alamat pengiriman utama, dan rata-rata total quantity per transaksi lebih dari 10.
#kandidat reseller

library(dplyr)

# 1. Hitung total_quantity per order
summary_order <- order_details_xl %>%
  group_by(order_id) %>%
  summarise(total_quantity = sum(quantity, na.rm = TRUE), .groups = "drop")

# 2. Gabungkan orders dengan summary_order
orders_summary <- orders_xl %>%
  inner_join(summary_order, by = "order_id") %>%
  inner_join(users_xl, by = c("buyer_id" = "user_id")) %>%
  # Filter hanya yang alamat kodepos sama
  filter(kodepos.x == kodepos.y)  # pastikan dari orders dan users

# 3. Agregasi per pembeli
reseller_offline <- orders_summary %>%
  group_by(buyer_id, nama_user) %>%
  summarise(
    jumlah_transaksi = n(),
    total_nilai_transaksi = sum(total, na.rm = TRUE),
    avg_nilai_transaksi = mean(total, na.rm = TRUE),
    avg_quantity_per_transaksi = mean(total_quantity, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(jumlah_transaksi >= 8, avg_quantity_per_transaksi > 10) %>%
  arrange(desc(total_nilai_transaksi))

print(reseller_offline)
#=========================================================
#Pembeli sekaligus penjual
#mencari penjual yang juga pernah bertransaksi sebagai pembeli minimal 7 kali.
library(dplyr)

# 1. Hitung jumlah transaksi sebagai pembeli
buyer_summary <- orders_xl %>%
  group_by(buyer_id) %>%
  summarise(jumlah_transaksi_beli = n(), .groups = "drop")

# 2. Hitung jumlah transaksi sebagai penjual
seller_summary <- orders_xl %>%
  group_by(seller_id) %>%
  summarise(jumlah_transaksi_jual = n(), .groups = "drop")

# 3. Gabungkan dengan users
transaksi_user <- users_xl %>%
  inner_join(buyer_summary, by = c("user_id" = "buyer_id")) %>%
  inner_join(seller_summary, by = c("user_id" = "seller_id")) %>%
  filter(jumlah_transaksi_beli >= 7) %>%
  transmute(
    nama_pengguna = nama_user,
    jumlah_transaksi_beli,
    jumlah_transaksi_jual
  ) %>%
  arrange(nama_pengguna)

print(transaksi_user)
#Lama dibayar
library(dplyr)
library(lubridate)

# Pastikan kolom tanggal dalam format Date
orders_xl <- orders_xl %>%
  mutate(
    created_at = as.Date(created_at),
    paid_at = as.Date(paid_at)
  )

# Filter transaksi yang sudah dibayar
orders_dibayar <- orders_xl %>%
  filter(!is.na(paid_at)) %>%
  mutate(
    tahun_bulan = format(created_at, "%Y-%m"),
    lama_dibayar = as.numeric(difftime(paid_at, created_at, units = "days"))
  )

# Agregasi
summary_pembayaran <- orders_dibayar %>%
  group_by(tahun_bulan) %>%
  summarise(
    jumlah_transaksi = n(),
    avg_lama_dibayar = mean(lama_dibayar, na.rm = TRUE),
    min_lama_dibayar = min(lama_dibayar, na.rm = TRUE),
    max_lama_dibayar = max(lama_dibayar, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(tahun_bulan)

print(summary_pembayaran)

