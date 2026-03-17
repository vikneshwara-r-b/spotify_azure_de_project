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
    "Watermark_Column": "updated_at"
  },
  {
    "tableName": "FactStream",
    "tableSchemaName": "dbo",
    "Watermark_Column": "updated_at"
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

DROP TABLE IF EXISTS dbo.watermarktable;

/* Create the following watermark metadata table in source*/
CREATE TABLE dbo.watermarktable (
    SchemaName VARCHAR(100),
    TableName VARCHAR(100),
    PK_List VARCHAR(100),
    WatermarkValue DATETIME
);


INSERT INTO dbo.watermarktable (SchemaName, TableName, PK_List, WatermarkValue)
VALUES
('dbo' ,'DimUser', 'user_id', '1900-01-01 00:00:00'),
('dbo' ,'DimArtist', 'artist_id', '1900-01-01 00:00:00'),
('dbo' ,'DimTrack', 'track_id', '1900-01-01 00:00:00'),
('dbo' ,'DimDate', 'date_key', '1900-01-01 00:00:00'),
('dbo' ,'FactStream', 'stream_id', '1900-01-01 00:00:00');

SELECT * FROM dbo.watermarktable;

TRUNCATE TABLE dbo.watermarktable;

-- To update latest watermark value in target audit table
CREATE PROCEDURE [dbo].[usp_write_watermark]
    @SchemaName VARCHAR(100),
    @last_updated DATETIME,
    @tableName VARCHAR(100)
AS
BEGIN
    UPDATE watermarktable
    SET WatermarkValue = @last_updated
    WHERE TableName = @tableName
    AND SchemaName = @SchemaName;
END;

DROP PROCEDURE [dbo].[usp_write_watermark];