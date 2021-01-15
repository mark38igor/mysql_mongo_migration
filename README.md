# mysql_mongo_migration
Migrate your custom sql queries data to mongo database


    1. create_migration_tables.sql  procedure that iterates over a table, that contains sql queries for our custom data and the procedure stores the data  in a csv format file in our local machine.
    2. migrateCsvToJson.py python script that  transform these csv to json data file.
    3. mongo_import_json.sh shell script that imports all the json file to mongo database.

# How to use
First import the database using the mysqlsampledatabase.sql file to mysql database.
Then create  a table using below query 

CREATE TABLE `migrate_tables` ( `id` int(10) NOT NULL AUTO_INCREMENT, `table_to_migrate` varchar(500) NOT NULL, `migration_table` varchar(500) NOT NULL, `query` text NOT NULL, `is_migrated_table_created` enum('0','1','2','3') NOT NULL DEFAULT '0', `is_migrated_file_created` enum('0','1','2','3') NOT NULL DEFAULT '0', PRIMARY KEY (`id`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1

Now add your tables which needs to be migrated with its custom query using the json_obejct method 
Sample format of the query 
select json_object('_id',customerNumber,'customerName',customerName,'contactLastName',contactLastName,'contactFirstName',contactFirstName,'phone',phone,'address',json_object(    'address1',    addressLine1,    'address2',    addressLine2,    'city',    city,    'state',    state,    'postalCode',    postalCode,    'country',    country),'salesRepEmployeeNumber',salesRepEmployeeNumber,'creditLimit',creditLimit
    ) `rows` 
    from customers;

Now set the fields is_migrated_table and is_migrated_file_created to 0 

For  the above procedure  to work few things needs to be setup in our centos machine 
    • create a folder named mysql-files under root directory and change its owner ship to mysql using chown command.
    • Edit mysql cnf file ,in centos its situated in /etc/my.cnf , add this statement secure_file_priv = /mysql-files,which sets mysql outfiles and load data file from this specified folder ,here our case the folder is mysql-files.
    • Now set SELinux security to premissive by using this command on centos machine ,sudo setenforce 0 
    • Restart mysql service and apache service.

Now run the procedure named as create_migration_tables() and csv files will be created in mysql-files folder

The next step is to run the python script that converts the csv file to json data

Once the python script has been run successfully then run the shell script that migrates json files to mongo database.
Please note, change the path name to the location  where you want to store the json files in python script as well as the path name in shell script where the json files are located.

That is it ,your custom mysql query data imported to mongo database.

