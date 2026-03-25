from pyspark.sql import functions as F

class reusable_transformations:
    
    def dropColumns(self, df, columns):
        df = df.drop(*columns)
        return df
    
    # Used to calculate hash_diff value from non-primary and non-metadata columns
    def add_hash_diff_column(self, df, pk_list):
        # Example: columns to exclude (primary keys)
        exclude_columns = pk_list + ['_rescued_data']
        # Get columns to include in hash
        cols_to_hash = [column for column in df.columns if column not in exclude_columns]
        # Build expression: COALESCE(col, ",")
        coalesced_cols = [F.coalesce(F.col(column).cast("string"), F.lit('')) for column in cols_to_hash]
        # Concatenate with "~"
        concat_ws = F.concat_ws('~', *coalesced_cols)
        # Calculate hash value and add a column
        df = df.withColumn("hash_diff",  F.sha2(concat_ws, 256))
        return df
    
    # Add metadata columns - calculate hash_diff, record ingestion date, capture pipeline run id etc
    def add_metadata_cols(self, df, pk_list):
        df = self.add_hash_diff_column(df, pk_list)
        df = df.withColumn("ingested_at", F.current_timestamp())
        return df

