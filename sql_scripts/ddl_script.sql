/*
Parameter name: table_list
Datatype: array
Value:
[
  {
    "tableName": "DimUser",
    "tableSchemaName": "dbo",
    "Watermark_Column": "updated_at"
  },
  {
    "tableName": "DimArtist",
    "tableSchemaName": "dbo",
    "Watermark_Column": "updated_at"
  },
  {
    "tableName": "DimTrack",
    "tableSchemaName": "dbo",
    "Watermark_Column": "updated_at"
  },
  {
    "tableName": "DimDate",
    "tableSchemaName": "dbo",
    "Watermark_Column": "date"
  },
  {
    "tableName": "FactStream",
    "tableSchemaName": "dbo",
    "Watermark_Column": "stream_timestamp"
  }
]
*/

DROP TABLE IF EXISTS dbo.DimUser;
DROP TABLE IF EXISTS dbo.DimArtist;
DROP TABLE IF EXISTS dbo.DimTrack;
DROP TABLE IF EXISTS dbo.DimDate;
DROP TABLE IF EXISTS dbo.FactStream;

-- DDL for Spotify Warehouse
CREATE TABLE dbo.DimUser (
  user_id INT PRIMARY KEY,
  user_name VARCHAR(255),
  country VARCHAR(255),
  subscription_type VARCHAR(50),
  start_date DATE,
  end_date DATE,
  updated_at DATETIME
);

CREATE TABLE dbo.DimArtist (
  artist_id INT PRIMARY KEY,
  artist_name VARCHAR(255),
  genre VARCHAR(100),
  country VARCHAR(100),
  updated_at DATETIME
);

CREATE TABLE dbo.DimTrack (
  track_id INT PRIMARY KEY,
  track_name VARCHAR(255),
  artist_id INT,
  album_name VARCHAR(255),
  duration_sec INT,
  release_date DATE,
  updated_at DATETIME
);

CREATE TABLE dbo.DimDate (
  date_key INT PRIMARY KEY,
  date DATE,
  day INT,
  month INT,
  year INT,
  weekday VARCHAR(20)
);

CREATE TABLE dbo.FactStream (
  stream_id BIGINT PRIMARY KEY,
  user_id INT,
  track_id INT,
  date_key INT,
  listen_duration INT,
  device_type VARCHAR(50),
  stream_timestamp DATETIME
);
