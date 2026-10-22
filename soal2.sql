[OPERASI CREATE TABLE]

-- 1. Data tabel menu_harian
INSERT INTO menu_harian
    (id_menu, nama_menu, tanggal_menu,
     id_pengguna_penyusun, id_pengguna_penginput)
VALUES
    (1, 'Nasi Ayam Sayur', '2026-10-22', 1, 2),
    (2, 'Nasi Ikan Tumis', '2026-10-23', 1, 2),
    (3, 'Nasi Telur Bayam', '2026-10-24', 1, 2);

-- 2. Data tabel sekolah
INSERT INTO sekolah
    (id_sekolah, nama_sekolah)
VALUES
    (1, 'SD Negeri Melati'),
    (2, 'SMP Negeri Harapan'),
    (3, 'SD Negeri Mawar');

-- 3. Data tabel feedback_menu
INSERT INTO feedback_menu
    (id_masukan, id_menu, id_sekolah,
     isi_masukan, tanggal)
VALUES
    (1, 1, 1, 'Porsi makanan cukup',
     '2026-10-22 11:00:00'),
    (2, 2, 2, 'Menu cukup bervariasi',
     '2026-10-23 11:00:00'),
    (3, 3, 3, 'Sayuran perlu ditambah',
     '2026-10-24 11:00:00');


[OPERASI READ TABLE]
SELECT * FROM sekolah

[OPERASI UPDATE TABLE]
UPDATE feedback_menu
SET isi_masukan = 'Menu lebih bervariasi dan bergizi'
WHERE id_masukan = 2;

[OPERASI DELETE DENGAN KLAUSA WHERE]
DELETE FROM feedback_menu
WHERE id_masukan = 3;
