-- ============================================================
-- DimUser - BULK UPDATES (15 rows)
-- ============================================================

UPDATE DimUser SET subscription_type = 'Premium', updated_at = '2025-10-08 08:10:00' WHERE user_id = 2;
UPDATE DimUser SET subscription_type = 'Family',  updated_at = '2025-10-08 08:15:00' WHERE user_id = 5;
UPDATE DimUser SET country = 'Canada',            updated_at = '2025-10-08 08:20:00' WHERE user_id = 9;
UPDATE DimUser SET user_name = 'Alex M Carter',   updated_at = '2025-10-08 08:25:00' WHERE user_id = 14;
UPDATE DimUser SET subscription_type = 'Free',    updated_at = '2025-10-08 08:30:00' WHERE user_id = 18;

UPDATE DimUser SET end_date = '2025-10-08',       updated_at = '2025-10-08 08:35:00' WHERE user_id = 22;
UPDATE DimUser SET subscription_type = 'Premium', updated_at = '2025-10-08 08:40:00' WHERE user_id = 27;
UPDATE DimUser SET country = 'Australia',         updated_at = '2025-10-08 08:45:00' WHERE user_id = 31;
UPDATE DimUser SET subscription_type = 'Family',  updated_at = '2025-10-08 08:50:00' WHERE user_id = 36;
UPDATE DimUser SET user_name = 'Nina R Shah',     updated_at = '2025-10-08 08:55:00' WHERE user_id = 40;

UPDATE DimUser SET subscription_type = 'Premium', updated_at = '2025-10-08 09:00:00' WHERE user_id = 48;
UPDATE DimUser SET end_date = NULL,               updated_at = '2025-10-08 09:05:00' WHERE user_id = 52;
UPDATE DimUser SET country = 'Singapore',         updated_at = '2025-10-08 09:10:00' WHERE user_id = 61;
UPDATE DimUser SET subscription_type = 'Free',    updated_at = '2025-10-08 09:15:00' WHERE user_id = 73;
UPDATE DimUser SET subscription_type = 'Family',  updated_at = '2025-10-08 09:20:00' WHERE user_id = 88;

-- ============================================================
-- DimArtist - BULK UPDATES (15 rows)
-- ============================================================

UPDATE DimArtist SET genre = 'Pop Rock',        updated_at = '2025-10-08 08:05:00' WHERE artist_id = 3;
UPDATE DimArtist SET country = 'South Korea',   updated_at = '2025-10-08 08:10:00' WHERE artist_id = 7;
UPDATE DimArtist SET artist_name = 'DJ Astro',  updated_at = '2025-10-08 08:15:00' WHERE artist_id = 11;
UPDATE DimArtist SET genre = 'Indie',           updated_at = '2025-10-08 08:20:00' WHERE artist_id = 15;
UPDATE DimArtist SET genre = 'Electronic',      updated_at = '2025-10-08 08:25:00' WHERE artist_id = 19;

UPDATE DimArtist SET country = 'Brazil',        updated_at = '2025-10-08 08:30:00' WHERE artist_id = 23;
UPDATE DimArtist SET genre = 'Jazz Fusion',     updated_at = '2025-10-08 08:35:00' WHERE artist_id = 28;
UPDATE DimArtist SET artist_name = 'Nova Beats',updated_at = '2025-10-08 08:40:00' WHERE artist_id = 32;
UPDATE DimArtist SET genre = 'Hip-Hop',         updated_at = '2025-10-08 08:45:00' WHERE artist_id = 37;
UPDATE DimArtist SET country = 'Spain',         updated_at = '2025-10-08 08:50:00' WHERE artist_id = 41;

UPDATE DimArtist SET genre = 'Rock',            updated_at = '2025-10-08 08:55:00' WHERE artist_id = 46;
UPDATE DimArtist SET artist_name = 'Luna Vox',  updated_at = '2025-10-08 09:00:00' WHERE artist_id = 50;
UPDATE DimArtist SET genre = 'Ambient',         updated_at = '2025-10-08 09:05:00' WHERE artist_id = 503;
UPDATE DimArtist SET country = 'Italy',         updated_at = '2025-10-08 09:10:00' WHERE artist_id = 504;
UPDATE DimArtist SET genre = 'Afrobeats',       updated_at = '2025-10-08 09:15:00' WHERE artist_id = 509;

-- ============================================================
-- DimTrack - BULK UPDATES (15 rows)
-- ============================================================

UPDATE DimTrack SET duration_sec = 210,              updated_at = '2025-10-08 08:05:00' WHERE track_id = 10;
UPDATE DimTrack SET album_name = 'Deluxe Edition',   updated_at = '2025-10-08 08:10:00' WHERE track_id = 25;
UPDATE DimTrack SET release_date = '2025-09-20',     updated_at = '2025-10-08 08:15:00' WHERE track_id = 39;
UPDATE DimTrack SET duration_sec = 180,              updated_at = '2025-10-08 08:20:00' WHERE track_id = 44;
UPDATE DimTrack SET album_name = 'Remastered',       updated_at = '2025-10-08 08:25:00' WHERE track_id = 52;

UPDATE DimTrack SET duration_sec = 260,              updated_at = '2025-10-08 08:30:00' WHERE track_id = 66;
UPDATE DimTrack SET release_date = '2025-10-01',     updated_at = '2025-10-08 08:35:00' WHERE track_id = 78;
UPDATE DimTrack SET duration_sec = 305,              updated_at = '2025-10-08 08:40:00' WHERE track_id = 88;
UPDATE DimTrack SET album_name = 'Acoustic Set',     updated_at = '2025-10-08 08:45:00' WHERE track_id = 101;
UPDATE DimTrack SET duration_sec = 199,              updated_at = '2025-10-08 08:50:00' WHERE track_id = 133;

UPDATE DimTrack SET artist_id = 505,                 updated_at = '2025-10-08 08:55:00' WHERE track_id = 150;
UPDATE DimTrack SET duration_sec = 275,              updated_at = '2025-10-08 09:00:00' WHERE track_id = 188;
UPDATE DimTrack SET album_name = 'Live Edition',     updated_at = '2025-10-08 09:05:00' WHERE track_id = 222;
UPDATE DimTrack SET duration_sec = 320,              updated_at = '2025-10-08 09:10:00' WHERE track_id = 244;
UPDATE DimTrack SET release_date = '2025-09-30',     updated_at = '2025-10-08 09:15:00' WHERE track_id = 512;

-- ============================================================
-- FactStream - BULK UPDATES (15 rows)
-- ============================================================

UPDATE FactStream SET listen_duration = 205, stream_timestamp = '2025-10-08 09:15:00' WHERE stream_id = 1001;
UPDATE FactStream SET device_type = 'Mobile', stream_timestamp = '2025-10-08 09:15:00' WHERE stream_id = 1002;
UPDATE FactStream SET listen_duration = 300, stream_timestamp = '2025-10-08 09:15:00' WHERE stream_id = 1003;
UPDATE FactStream SET device_type = 'Desktop', stream_timestamp = '2025-10-08 09:15:00' WHERE stream_id = 1004;
UPDATE FactStream SET device_type = 'Mobile', stream_timestamp = '2025-10-08 09:15:00' WHERE stream_id = 1000;

UPDATE FactStream SET listen_duration = 190, stream_timestamp = '2025-10-08 09:30:00' WHERE stream_id = 1006;
UPDATE FactStream SET device_type = 'Smart Speaker', stream_timestamp = '2025-10-08 09:30:00' WHERE stream_id = 1007;
UPDATE FactStream SET listen_duration = 120, stream_timestamp = '2025-10-08 09:30:00' WHERE stream_id = 1008;
UPDATE FactStream SET device_type = 'Mobile', stream_timestamp = '2025-10-08 09:30:00' WHERE stream_id = 1009;
UPDATE FactStream SET listen_duration = 840, stream_timestamp = '2025-10-07 02:30:00' WHERE stream_id = 1010;

UPDATE FactStream SET listen_duration = 215, stream_timestamp = '2025-10-07 03:45:00' WHERE stream_id = 1011;
UPDATE FactStream SET device_type = 'Desktop', stream_timestamp = '2025-10-07 03:45:00' WHERE stream_id = 1012;
UPDATE FactStream SET listen_duration = 260, stream_timestamp = '2025-10-07 03:45:00' WHERE stream_id = 1013;
UPDATE FactStream SET device_type = 'Mobile', stream_timestamp = '2025-10-07 03:45:00' WHERE stream_id = 1014;
UPDATE FactStream SET listen_duration = 1000, stream_timestamp = '2025-10-07 03:45:00' WHERE stream_id = 1015;

-- ============================================================
--  NEW ARTISTS (DimArtist)
-- ============================================================
 
INSERT INTO DimArtist (artist_id, artist_name, genre, country, updated_at)
VALUES
  (501, 'Marcus Chen',      'Pop',        'Taiwan',        '2025-10-09 08:00:00'),
  (502, 'Aisha Kamara',     'R&B',        'Sierra Leone',  '2025-10-09 08:00:00'),
  (503, 'Lena Hoffmann',    'Electronic', 'Germany',       '2025-10-09 08:00:00'),
  (504, 'Diego Fuentes',    'Latin',      'Colombia',      '2025-10-09 08:00:00'),
  (505, 'Priya Sharma',     'Classical',  'India',         '2025-10-09 08:00:00'),
  (506, 'Tyler Brooks',     'Hip-Hop',    'United States of America', '2025-10-09 08:00:00'),
  (507, 'Yuki Tanaka',      'Jazz',       'Japan',         '2025-10-09 08:00:00'),
  (508, 'Fatima Al-Rashid', 'Pop',        'Jordan',        '2025-10-09 08:00:00'),
  (509, 'Olumide Adeyemi',  'Afrobeats',  'Nigeria',       '2025-10-09 08:00:00'),
  (510, 'Camille Dupont',   'Rock',       'France',        '2025-10-09 08:00:00');

  -- ============================================================
--  NEW TRACKS (DimTrack)
-- ============================================================
 
INSERT INTO DimTrack (track_id, track_name, artist_id, album_name, duration_sec, release_date, updated_at)
VALUES
  (501, 'Neon Dreams',              501, 'Pulse Album',    198, '2025-10-01', '2025-10-09 08:00:00'),
  (502, 'Midnight Signal',          501, 'Pulse Album',    224, '2025-10-01', '2025-10-09 08:00:00'),
  (503, 'Rivers of Gold',           502, 'Soul Tide Album',312, '2025-09-15', '2025-10-09 08:00:00'),
  (504, 'Warm Static',              503, 'Voltage Album',  176, '2025-10-03', '2025-10-09 08:00:00'),
  (505, 'Baile Eterno',             504, 'Calor Album',    245, '2025-09-20', '2025-10-09 08:00:00'),
  (506, 'Raag Bhairavi Reimagined', 505, 'Fusion Album',   420, '2025-08-30', '2025-10-09 08:00:00'),
  (507, 'Block by Block',           506, 'Concrete Album', 193, '2025-10-05', '2025-10-09 08:00:00'),
  (508, 'Late Night Metro',         507, 'Tokyo After Album', 287, '2025-09-28', '2025-10-09 08:00:00'),
  (509, 'Habibi Groove',            508, 'Desert Pop Album', 210, '2025-10-02', '2025-10-09 08:00:00'),
  (510, 'Lagos Sunrise',            509, 'West Coast Album', 234, '2025-09-18', '2025-10-09 08:00:00'),
  (511, 'Broken Compass',           510, 'Gravel Album',   267, '2025-10-04', '2025-10-09 08:00:00'),
  (512, 'Colour Theory',            503, 'Voltage Album',  158, '2025-10-03', '2025-10-09 08:00:00'),
  (513, 'Thousand Lanterns',        507, 'Tokyo After Album', 304, '2025-09-28', '2025-10-09 08:00:00'),
  (514, 'Punchline',                506, 'Concrete Album', 181, '2025-10-05', '2025-10-09 08:00:00'),
  (515, 'Floating Above',           502, 'Soul Tide Album',  339, '2025-09-15', '2025-10-09 08:00:00');

  -- ============================================================
-- NEW USERS (DimUser)
-- ============================================================
 
INSERT INTO DimUser (user_id, user_name, country, subscription_type, start_date, end_date, updated_at)
VALUES
  (501, 'Elena Vasquez',     'Spain',              'Premium', '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (502, 'James Okafor',      'Nigeria',            'Free',    '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (503, 'Sofia Petrov',      'Russian Federation', 'Family',  '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (504, 'Raj Mehta',         'India',              'Premium', '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (505, 'Hannah Müller',     'Germany',            'Free',    '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (506, 'Carlos Lima',       'Brazil',             'Premium', '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (507, 'Mei Watanabe',      'Japan',              'Family',  '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (508, 'Kwame Asante',      'Ghana',              'Free',    '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (509, 'Isabelle Laurent',  'France',             'Premium', '2025-10-07', NULL, '2025-10-09 09:00:00'),
  (510, 'Ahmed Hassan',      'Egypt',              'Free',    '2025-10-07', NULL, '2025-10-09 09:00:00');