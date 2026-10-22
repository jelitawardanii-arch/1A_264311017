SELECT
    m.nama_menu,
    COUNT(f.id_masukan) AS total_feedback
FROM menu_harian AS m
JOIN feedback_menu AS f
    ON m.id_menu = f.id_menu
WHERE f.tanggal >= '2026-10-22'
  AND f.tanggal < '2026-10-25'
GROUP BY m.id_menu, m.nama_menu;

Hasilnya

+------------------+----------------+
| nama_menu        | total_feedback |
+------------------+----------------+
| Nasi Ayam Sayur  | 1              |
| Nasi Ikan Tumis  | 1              |
| Nasi Telur Bayam | 1              |
+------------------+----------------+
