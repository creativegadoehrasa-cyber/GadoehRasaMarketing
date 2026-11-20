# Gadoeh Rasa Marketing Workspace — GitHub + Supabase

## Isi folder
- `index.html` — aplikasi website
- `supabase-config.js` — tempat memasukkan Supabase Project URL dan anon/publishable key
- `supabase-setup.sql` — skema database, akses anggota, dan Row Level Security

## A. Setup Supabase
1. Buat project di https://supabase.com/
2. Buka SQL Editor, tempel seluruh isi `supabase-setup.sql`, lalu Run.
3. Buka Project Settings → API (atau Data API / API Keys, sesuai tampilan dashboard).
4. Salin Project URL dan anon/public/publishable key.
5. Isi kedua nilai tersebut ke `supabase-config.js`.
   - Boleh dipakai di frontend: anon/publishable key.
   - JANGAN gunakan `service_role` atau secret key di website.
6. Authentication → Providers → Email: aktifkan Email.

## B. Publish di GitHub Pages
1. Buat repository GitHub bernama `gadoeh-rasa-marketing`.
2. Upload `index.html` dan `supabase-config.js` ke root repository.
3. Settings → Pages → Deploy from a branch → `main` → `/ (root)` → Save.
4. Tunggu URL GitHub Pages aktif, misalnya `https://USERNAME.github.io/gadoeh-rasa-marketing/`.
5. Di Supabase Authentication → URL Configuration:
   - Site URL: URL GitHub Pages kamu.
   - Redirect URLs: tambahkan URL GitHub Pages tersebut.

## C. Buat akun dan izinkan anggota tim
1. Buka website online, klik "Buat akun tim", lalu daftar dengan email.
2. Jika konfirmasi email aktif, buka inbox dan verifikasi.
3. Login dengan akun tersebut.
4. Untuk memberi akses, buka Supabase → SQL Editor dan jalankan query ini (ganti email):
   `insert into public.workspace_members(email) values ('email-kamu@domain.com') on conflict (email) do nothing;`
5. Refresh website atau login ulang.
6. Ulangi langkah allowlist untuk setiap anggota tim. Akun yang belum dimasukkan ke `workspace_members` tidak bisa membaca atau mengubah data workspace.

## D. Cara kerja
- Login menggunakan email/password Supabase.
- Seluruh data workspace disimpan sebagai satu dokumen JSONB di `workspace_state`.
- Browser menyimpan cache lokal, tetapi Supabase menjadi sumber data bersama.
- Perubahan pengguna lain dikirim melalui Supabase Realtime.

## E. Migrasi data lama
Jika data penting masih tersimpan di browser versi HTML sebelumnya:
1. Buka versi lama di browser/perangkat yang menyimpan data.
2. Gunakan fitur Export Data / Backup pada Template Setup.
3. Simpan file JSON backup.
4. Setelah versi Supabase online aktif dan login, gunakan fitur Import Data pada Template Setup.
5. Pastikan data sudah tampil di workspace sebelum menghapus backup lokal.

## Catatan
Versi awal ini menyimpan seluruh workspace dalam satu dokumen bersama. Cocok untuk tim kecil dan tahap awal. Jika dua orang mengedit dan menyimpan pada saat bersamaan, perubahan terakhir bisa menimpa perubahan lainnya. Tahap berikutnya dapat memecah setiap plan menjadi record tersendiri.

Jangan bagikan password atau service_role key. Gunakan akun masing-masing untuk setiap anggota tim.
