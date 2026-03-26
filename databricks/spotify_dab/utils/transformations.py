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
    
    # Create SCD Type 2 table
    def create_scd2_table(
    self,
    spark,
    catalog_name,
    source_schema,
    source_table,
    target_schema,
    target_table,
    adls_storage_container_name
    ):
        source_full = f"{catalog_name}.{source_schema}.{source_table}"
        target_full = f"{catalog_name}.{target_schema}.{target_table}"
        
        # Read source schema
        source_df = spark.table(source_full)
        
        # Generate column DDL dynamically
        columns_ddl = []
        
        for field in source_df.schema.fields:
            col_name = field.name
            col_type = field.dataType.simpleString().upper()
            columns_ddl.append(f"{col_name} {col_type}")
        
        # Surrogate key column
        sk_col = f"{target_table}_sk BIGINT GENERATED ALWAYS AS IDENTITY"
        
        # SCD2 columns
        scd_cols = [
            "is_current BOOLEAN",
            "active_start_date_time TIMESTAMP",
            "active_end_date_time TIMESTAMP"
        ]
        
        # Final DDL
        final_columns = ",\n  ".join([sk_col] + columns_ddl + scd_cols)
        
        create_stmt = f"""
        CREATE TABLE IF NOT EXISTS {target_full} (
        {final_columns}
        )
        USING DELTA
        LOCATION 'abfss://{target_schema}@{adls_storage_container_name}.dfs.core.windows.net/{target_table}/data'
        """

        print(f"{target_full} table creation statement is: {create_stmt}")
    
        spark.sql(create_stmt)

