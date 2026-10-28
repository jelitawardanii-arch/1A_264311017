CREATE DATABASE db_sisfor_mbg CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_sisfor_mbg;

-- ---------------------------------------------------------------------

-- A. DATA MASTER
-- ---------------------------------------------------------------------

CREATE TABLE sekolah (
  id_sekolah    INT          NOT NULL AUTO_INCREMENT,
  nama_sekolah  VARCHAR(100) NOT NULL,
  CONSTRAINT pk_sekolah PRIMARY KEY (id_sekolah),
  CONSTRAINT ck_sekolah_nama CHECK (CHAR_LENGTH(TRIM(nama_sekolah)) > 0)
) ENGINE=InnoDB;

CREATE TABLE kelompok_sasaran (
  id_kelompok   INT          NOT NULL AUTO_INCREMENT,
  jenjang       VARCHAR(30)  NOT NULL,
  ukuran_porsi  INT          NOT NULL,
  CONSTRAINT pk_kelompok_sasaran PRIMARY KEY (id_kelompok),
  CONSTRAINT uq_kelompok_jenjang UNIQUE (jenjang),
  CONSTRAINT ck_kelompok_porsi   CHECK (ukuran_porsi > 0)
) ENGINE=InnoDB;

CREATE TABLE siswa (
  id_siswa      INT          NOT NULL AUTO_INCREMENT,
  nama_siswa    VARCHAR(100) NOT NULL,
  kelas         VARCHAR(30)  NOT NULL,
  id_sekolah    INT          NOT NULL,
  id_kelompok   INT          NOT NULL,
  CONSTRAINT pk_siswa PRIMARY KEY (id_siswa),
  CONSTRAINT fk_siswa_sekolah  FOREIGN KEY (id_sekolah)
      REFERENCES sekolah (id_sekolah)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_siswa_kelompok FOREIGN KEY (id_kelompok)
      REFERENCES kelompok_sasaran (id_kelompok)
      ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE bahan_pangan (
  id_bahan      INT          NOT NULL AUTO_INCREMENT,
  nama_bahan    VARCHAR(100) NOT NULL,
  satuan        VARCHAR(30)  NOT NULL,
  CONSTRAINT pk_bahan_pangan PRIMARY KEY (id_bahan),
  CONSTRAINT uq_bahan_nama   UNIQUE (nama_bahan)
) ENGINE=InnoDB;

CREATE TABLE pengguna (
  id_pengguna    INT          NOT NULL AUTO_INCREMENT,
  nama_pengguna  VARCHAR(100) NOT NULL,
  peran          ENUM('Admin','Ahli Gizi','Konsumen') NOT NULL,
  CONSTRAINT pk_pengguna PRIMARY KEY (id_pengguna)
) ENGINE=InnoDB;

CREATE TABLE riwayat_alergi (
  id_siswa          INT         NOT NULL,
  id_bahan          INT         NOT NULL,
  tingkat_keparahan VARCHAR(30) NOT NULL,
  tanggal_dicatat   DATE        NOT NULL DEFAULT (CURRENT_DATE),
  CONSTRAINT pk_riwayat_alergi PRIMARY KEY (id_siswa, id_bahan),
  CONSTRAINT fk_alergi_siswa FOREIGN KEY (id_siswa)
      REFERENCES siswa (id_siswa)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_alergi_bahan FOREIGN KEY (id_bahan)
      REFERENCES bahan_pangan (id_bahan)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_alergi_tingkat
      CHECK (tingkat_keparahan IN ('Ringan','Sedang','Berat'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------

-- B. PERENCANAAN MENU DAN NILAI GIZI
-- ---------------------------------------------------------------------

CREATE TABLE menu_harian (
  id_menu                INT          NOT NULL AUTO_INCREMENT,
  nama_menu              VARCHAR(100) NOT NULL,
  tanggal_menu           DATE         NOT NULL,
  id_pengguna_penyusun   INT          NOT NULL,
  id_pengguna_penginput  INT          NOT NULL,
  CONSTRAINT pk_menu_harian PRIMARY KEY (id_menu),
  CONSTRAINT fk_menu_penyusun FOREIGN KEY (id_pengguna_penyusun)
      REFERENCES pengguna (id_pengguna)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_menu_penginput FOREIGN KEY (id_pengguna_penginput)
      REFERENCES pengguna (id_pengguna)
      ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE komponen_menu (
  id_menu        INT          NOT NULL,
  kategori       VARCHAR(50)  NOT NULL,
  nama_hidangan  VARCHAR(100) NOT NULL,
  CONSTRAINT pk_komponen_menu PRIMARY KEY (id_menu, kategori),
  CONSTRAINT fk_komponen_menu FOREIGN KEY (id_menu)
      REFERENCES menu_harian (id_menu)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_komponen_kategori CHECK (kategori IN
      ('Makanan Pokok','Lauk Hewani','Lauk Nabati','Sayur','Buah','Susu'))
) ENGINE=InnoDB;

CREATE TABLE komposisi_bahan (
  id_menu       INT           NOT NULL,
  kategori      VARCHAR(50)   NOT NULL,
  id_bahan      INT           NOT NULL,
  takaran_gram  DECIMAL(8,2)  NOT NULL,
  CONSTRAINT pk_komposisi_bahan PRIMARY KEY (id_menu, kategori, id_bahan),
  CONSTRAINT fk_komposisi_komponen FOREIGN KEY (id_menu, kategori)
      REFERENCES komponen_menu (id_menu, kategori)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_komposisi_bahan FOREIGN KEY (id_bahan)
      REFERENCES bahan_pangan (id_bahan)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_komposisi_takaran CHECK (takaran_gram > 0)
) ENGINE=InnoDB;

CREATE TABLE porsi_menu (
  id_menu        INT           NOT NULL,
  id_kelompok    INT           NOT NULL,
  takaran_porsi  DECIMAL(8,2)  NOT NULL,
  energi_kkal    DECIMAL(8,2)  NOT NULL,
  protein_g      DECIMAL(8,2)  NOT NULL,
  lemak_g        DECIMAL(8,2)  NOT NULL,
  karbohidrat_g  DECIMAL(8,2)  NOT NULL,
  CONSTRAINT pk_porsi_menu PRIMARY KEY (id_menu, id_kelompok),
  CONSTRAINT fk_porsi_menu FOREIGN KEY (id_menu)
      REFERENCES menu_harian (id_menu)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_porsi_kelompok FOREIGN KEY (id_kelompok)
      REFERENCES kelompok_sasaran (id_kelompok)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_porsi_takaran CHECK (takaran_porsi > 0),
  CONSTRAINT ck_porsi_gizi CHECK (energi_kkal >= 0 AND protein_g >= 0
      AND lemak_g >= 0 AND karbohidrat_g >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------

-- C. EVALUASI: SUPERTYPE masukan_evaluasi + 2 SUBTYPE (disjoint)
-- ---------------------------------------------------------------------

CREATE TABLE masukan_evaluasi (
  id_masukan            INT          NOT NULL AUTO_INCREMENT,
  jenis_masukan         VARCHAR(20)  NOT NULL,
  id_pengguna_pencatat  INT          NOT NULL,
  tanggal               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  uraian                TEXT         NOT NULL,
  CONSTRAINT pk_masukan_evaluasi PRIMARY KEY (id_masukan),
  CONSTRAINT uq_masukan_jenis UNIQUE (id_masukan, jenis_masukan),
  CONSTRAINT fk_masukan_pencatat FOREIGN KEY (id_pengguna_pencatat)
      REFERENCES pengguna (id_pengguna)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_masukan_jenis
      CHECK (jenis_masukan IN ('Feedback','Ketidaksesuaian'))
) ENGINE=InnoDB;

CREATE TABLE feedback_menu (
  id_masukan     INT          NOT NULL,
  jenis_masukan  VARCHAR(20)  NOT NULL DEFAULT 'Feedback',
  id_menu        INT          NOT NULL,
  id_sekolah     INT          NOT NULL,
  isi_masukan    TEXT         NOT NULL,
  CONSTRAINT pk_feedback_menu PRIMARY KEY (id_masukan),
  CONSTRAINT fk_feedback_masukan FOREIGN KEY (id_masukan, jenis_masukan)
      REFERENCES masukan_evaluasi (id_masukan, jenis_masukan)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_feedback_menu FOREIGN KEY (id_menu)
      REFERENCES menu_harian (id_menu)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_feedback_sekolah FOREIGN KEY (id_sekolah)
      REFERENCES sekolah (id_sekolah)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_feedback_jenis CHECK (jenis_masukan = 'Feedback')
) ENGINE=InnoDB;

CREATE TABLE aspek_feedback (
  id_masukan  INT          NOT NULL,
  aspek       VARCHAR(30)  NOT NULL,
  CONSTRAINT pk_aspek_feedback PRIMARY KEY (id_masukan, aspek),
  CONSTRAINT fk_aspek_feedback FOREIGN KEY (id_masukan)
      REFERENCES feedback_menu (id_masukan)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_aspek_nilai CHECK (aspek IN ('Rasa','Porsi','Kebersihan',
      'Tampilan','Kandungan Gizi','Ketepatan Waktu'))
) ENGINE=InnoDB;

CREATE TABLE laporan_ketidaksesuaian (
  id_masukan            INT          NOT NULL,
  jenis_masukan         VARCHAR(20)  NOT NULL DEFAULT 'Ketidaksesuaian',
  id_sekolah            INT          NOT NULL,
  id_menu               INT          NULL,
  id_bahan              INT          NULL,
  jenis_ketidaksesuaian VARCHAR(100) NOT NULL,
  hasil_pemeriksaan     TEXT         NULL,
  status_tindak_lanjut  VARCHAR(30)  NOT NULL DEFAULT 'Belum Ditindak',
  CONSTRAINT pk_laporan_ketidaksesuaian PRIMARY KEY (id_masukan),
  CONSTRAINT fk_laporan_masukan FOREIGN KEY (id_masukan, jenis_masukan)
      REFERENCES masukan_evaluasi (id_masukan, jenis_masukan)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_laporan_sekolah FOREIGN KEY (id_sekolah)
      REFERENCES sekolah (id_sekolah)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_laporan_menu FOREIGN KEY (id_menu)
      REFERENCES menu_harian (id_menu)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_laporan_bahan FOREIGN KEY (id_bahan)
      REFERENCES bahan_pangan (id_bahan)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_laporan_jenis  CHECK (jenis_masukan = 'Ketidaksesuaian'),
  CONSTRAINT ck_laporan_target CHECK (id_menu IS NOT NULL OR id_bahan IS NOT NULL),
  CONSTRAINT ck_laporan_status CHECK (status_tindak_lanjut IN
      ('Belum Ditindak','Sedang Diproses','Selesai'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------

-- D. DASHBOARD: data turunan -> VIEW (bukan tabel)
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW rekap_dashboard_sekolah AS
SELECT s.id_sekolah,
       s.nama_sekolah,
       COALESCE(sw.total, 0) AS total_siswa,
       COALESCE(fb.total, 0) AS total_feedback,
       COALESCE(lp.total, 0) AS total_kasus_ketidaksesuaian
FROM sekolah s
LEFT JOIN (SELECT id_sekolah, COUNT(*) AS total
           FROM siswa GROUP BY id_sekolah) sw ON sw.id_sekolah = s.id_sekolah
LEFT JOIN (SELECT id_sekolah, COUNT(*) AS total
           FROM feedback_menu GROUP BY id_sekolah) fb ON fb.id_sekolah = s.id_sekolah
LEFT JOIN (SELECT id_sekolah, COUNT(*) AS total
           FROM laporan_ketidaksesuaian GROUP BY id_sekolah) lp ON lp.id_sekolah = s.id_sekolah;
