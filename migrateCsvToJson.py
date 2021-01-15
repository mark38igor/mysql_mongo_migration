# imports csv ,json,mysql connectivity,chardet for determine charset of file,getpass for password input
import csv
from csv import reader
import json

from getpass import getpass
from mysql.connector import connect, Error
import chardet

# function that recieves 3 args,csv file path ,json file path and the csvfile charset
#


def make_json(csvFilePath, jsonFilePath, charset):
    # encoding of csvfile set to the pass charset
    with open(csvFilePath, encoding=charset) as csvf:
        jsonArray = []
        # read csvfile with the delimiter that was used while creating csv file ,
        # quotechar is  used to specifiy the quoting character around the text,
        # escapechar is used to specifiy the escape sequnce character,that is used to
        # escape the special characters
        csvReader = reader(csvf, delimiter='~', quotechar='"', escapechar='\\')
        for rows in csvReader:
            # convert json string to json object using json.loads method
            row = json.loads(rows[0])
            jsonArray.append(row)
    # Open a json writer, and use the json.dumps()
    with open(jsonFilePath, 'w', encoding='utf-8') as jsonf:
        jsonString = json.dumps(jsonArray, indent=4)
        jsonf.write(jsonString)
# connect to database and call make_json function to create json files from csv files


def connect_database():
    try:
        with connect(host="localhost",
                     user=input("Enter username: "),
                     password=getpass("Enter password: "),
                     database="classicmodels",
                     autocommit=True) as connection:
            # select rows where migration table created as well as csv file
            queryMigratedTables = "SELECT migration_table FROM `migrate_tables` where is_migrated_table_created='1' and is_migrated_file_created='1'"
            with connection.cursor() as cursorTables:
                cursorTables.execute(queryMigratedTables)
                migratedTables = cursorTables.fetchall()
                # create csv and json filepath name based on the column migration_table value
                for table in migratedTables:
                    csvFilePath = r'/mysql-files/'+table[0]+'.csv'
                    jsonFilePath = r'/home/sbabukuttan/Documents/mysql to mongo migration/json/' + \
                        table[0]+'.json'
                    # get the character encoding of the csv file
                    charset = check_charset(csvFilePath)
                    make_json(csvFilePath, jsonFilePath, charset['encoding'])
                    queryJSONFileCreated = "UPDATE migrate_tables SET is_migrated_file_created=%s where migration_table=%s";
                    data=('2',table[0]);
                    with connection.cursor() as jsonCreated:
                        jsonCreated.execute(queryJSONFileCreated,data);
                        connection.commit();
                    print("JSON file created : " + table[0]);
    except Error as e:
        print(e)

# return the encoding of csv file
def check_charset(file):
    rawdata = open(file, 'rb').read()
    result = chardet.detect(rawdata)
    print(result)
    return result
# connect to database and convert csv files to json files.
connect_database()
