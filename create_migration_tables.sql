DROP PROCEDURE IF EXISTS create_migration_tables;
DELIMITER $$
CREATE PROCEDURE create_migration_tables() 
BEGIN
    DECLARE done int  DEFAULT 0;
    DECLARE table_name VARCHAR(100);
    DECLARE migration_table_name VARCHAR(100);
    DECLARE query_stmt TEXT;

    -- iterate over migrate_tables to create  migration tables and csv file
    DECLARE migrate_tables CURSOR FOR
     SELECT table_to_migrate ,query,migration_table
     FROM migrate_tables
     WHERE is_migrated_table_created = '0';

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := 1;

   OPEN migrate_tables;
   migrate_loop:LOOP
    FETCH migrate_tables INTO table_name,query_stmt,migration_table_name;
    IF !done THEN
      -- create migration table
      SET @query =CONCAT('CREATE TABLE IF NOT EXISTS ',migration_table_name, ' ', query_stmt ,' where  1=2');
      PREPARE stmt FROM  @query;
      EXECUTE stmt ;
      DEALLOCATE PREPARE stmt;

      SET @n:= 0;
      SET @query =CONCAT('INSERT INTO ',migration_table_name, ' ', query_stmt );
      PREPARE stmt FROM  @query;
      EXECUTE stmt ;
      DEALLOCATE PREPARE stmt;

      -- update the flag that indicates migrated table created
      UPDATE migrate_tables SET is_migrated_table_created='1' where table_to_migrate= table_name;
      SELECT  table_name 'json rows migrated';

      -- create csv file to the /mysql-files/ folder and folder own by mysql, csv field separated by $ and row terminated by newline (\n)
      SET @query =CONCAT('select * from  ',migration_table_name,  " into outfile '/mysql-files/",migration_table_name,".csv' fields terminated by '$' lines terminated by '\n'" );
      PREPARE stmt FROM  @query;
      EXECUTE stmt ;
      DEALLOCATE PREPARE stmt;
      
      -- update the flag that indicates migrated csv file created 
      UPDATE migrate_tables SET is_migrated_file_created='1' where table_to_migrate= table_name;
      SELECT table_name  'created csv file'; 
    ELSE
      LEAVE migrate_loop;
    END IF;
   END LOOP;
   CLOSE migrate_tables;
END$$

DELIMITER ;