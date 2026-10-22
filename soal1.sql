CREATE TABLE menu_harian (
    id_menu INT AUTO_INCREMENT PRIMARY KEY,
    nama_menu VARCHAR(100) NOT NULL,
    tanggal_menu DATE NOT NULL,
    id_pengguna_penyusun INT NOT NULL,
    id_pengguna_penginput INT NOT NULL
);

CREATE TABLE sekolah (
    id_sekolah INT AUTO_INCREMENT PRIMARY KEY,
    nama_sekolah VARCHAR(100) NOT NULL
);

CREATE TABLE feedback_menu (
    id_masukan INT PRIMARY KEY,
    id_menu INT NOT NULL,
    id_sekolah INT NOT NULL,
    isi_masukan TEXT NOT NULL,
    tanggal DATETIME NOT NULL,

    FOREIGN KEY (id_menu)
        REFERENCES menu_harian(id_menu),

    FOREIGN KEY (id_sekolah)
        REFERENCES sekolah(id_sekolah)
);
