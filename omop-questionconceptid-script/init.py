# Reading an excel file using Python

import pandas as pd
import numpy as np
import psycopg2
from psycopg2 import connect, DatabaseError
import psycopg2.extras as extras
from configparser import ConfigParser
from datetime import datetime

vocab = "vocab"
viewer = "viewer"
name_of_table = "{}.concept".format(vocab)
# column_name_map = {'Element OMOP Concept ID': 'concept_id',
#                    'Element OMOP Concept Name': 'concept_name',
#                    'Vocabulary': 'vocabulary',
#                    'Element OMOP Concept Code': 'concept_code'}

parser = ConfigParser(interpolation=None)


def config(filename='config.ini'):
    parser.read(filename)


def getConfig(section, inverse=False):

    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            if inverse:
                db[param[1]] = param[0]
            else:
                db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the file'.format(section))

    return db


def connectdb():

    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = getConfig('postgresql')

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = connect(**params)

        # create a cursor
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        # execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)

        # close the communication with the PostgreSQL
        cur.close()
    except (Exception, DatabaseError) as error:
        print(error)
    return conn

# def connectdb1():
#
#     """ Connect to the PostgreSQL database server """
#     conn = None
#     try:
#         # read connection parameters
#         params = getConfig('postgresql1')
#
#         # connect to the PostgreSQL server
#         print('Connecting to the PostgreSQL database...')
#         conn = connect(**params)
#
#         # create a cursor
#         cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
#
# 	    # execute a statement
#         print('PostgreSQL database version:')
#         cur.execute('SELECT version()')
#
#         # display the PostgreSQL database server version
#         db_version = cur.fetchone()
#         print(db_version)
#
# 	    # close the communication with the PostgreSQL
#         cur.close()
#     except (Exception, DatabaseError) as error:
#         print(error)
#     return conn


def getNextConcept(cur):
    cur.execute("SELECT MAX(concept_id) FROM %s;" % name_of_table)
    max_val = cur.fetchone()[0]
    return max_val + 1


def insertConcept(conceptid) :
    # insert into database
    sql = "INSERT INTO %s (" % name_of_table


def insertConcept1(conceptid) :
    # insert into database
    sql = "INSERT INTO category ("


def getById(cur, id):
    cur.execute("SELECT * FROM %s WHERE concept_id = %s;" % (name_of_table, id))
    concept_table = cur.fetchone()
    print('Found: {}'.format(concept_table))
    return concept_table


def getById1(cur, id):
    cur.execute("SELECT * FROM %s.category WHERE concept_id = %s;" % (viewer, id))
    category_table = cur.fetchone()
    print('Found: {}'.format(category_table))
    return category_table


def updateConcept(conn, row):
    sql = "UPDATE %s.concept SET concept_name = '%s', domain_id = '%s', concept_code = '%s', concept_class_id = '%s', " \
          "vocabulary_id = '%s'  WHERE concept_id = %s" % (vocab, str(row['concept_name']).replace("'", "''"),
                                                           str(row['domain_id']).replace("'", "''"), str(row['concept_code']),
                                                           str(row['concept_class_id']), str(row['vocabulary_id']),
                                                           row['concept_id'])
    cur.execute(sql)
    conn.commit()


def updateConcept1(conn, row):

    sql = "UPDATE %s.category SET section = '%s', category = '%s', question = '%s' WHERE concept_id = %s" % (viewer, row['section'],
    row['category'], row['concept_name'].replace("'", "''"), row['concept_id'])
    cur.execute(sql)
    conn.commit()


def insertConcept(conn, row):
    cur = conn.cursor()

     # Get next available concept id
    conceptid = row['concept_id']

    start_index = int(getConfig('database')['start_index'])

    if conceptid < start_index or np.isnan(row['concept_id']):
        print('concept_id {0} is less than user space id. Selecting a concept_code.'.format(conceptid))
        conceptid = getNextConcept(cur)

    print('Next concept id: %s' % conceptid)
    
    # Retreive default table update
    concept = getConfig('default')
    concept['concept_id'] = conceptid
    concept['concept_name'] = row['concept_name'].replace("'", r"''")
    concept['vocabulary_id'] = row['vocabulary_id']
    concept['concept_class_id'] = row['concept_class_id']
    concept['concept_code'] = str(conceptid)
    concept['domain_id'] = row['domain_id']

    # execute_batch(cur, insert_str, default_params)
    columns = ", ".join(list(concept.keys()))
    values = list(concept.values())

    sql = "INSERT INTO %s.concept (%s) VALUES (%s, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (vocab, str(columns), values[0], str(values[1]), str(values[2]), str(values[3]), str(values[4]), str(values[5]), str(values[6]), str(values[7]), str(values[8]), str(values[9]))

    cur.execute(sql)
    conn.commit()

    return concept


def insertCategory(conn, row):
    cur = conn.cursor()
    sql = "INSERT INTO %s.category (concept_id, section, category, question) VALUES(%s, '%s', '%s', '%s')" % (viewer, row['concept_id'], row['section'], row['category'], row['concept_name'].replace("'", r"''"))
    cur.execute(sql)
    conn.commit()


def needChange(row, concept):
    if concept is None:
        return False
    elif row['concept_id'] == concept[0]:
        return True
    else:
        return False


config()

# Create db connection
conn = connectdb()
cur = conn.cursor()

# conn1 = connectdb()
# cur1 = conn.cursor()
#
#get excel config
e = getConfig('excel')

# Read excel 
wb = pd.read_excel(e['name'], sheet_name=e['sheet'])

# Update columns base on column mapping
cwb = wb.rename(columns=getConfig('mapping', True))

inversecolumn = getConfig('mapping', False)

for index, row in cwb.iterrows():
    if row['category'] != row['category']:
        row['category'] = ""

    #Create mapping frame 
    print(row['concept_id'], row['concept_name'], row['vocabulary_id'], row['domain_id'], str(row['concept_code']), row['section'], row['category'])

    modified = False
    concept = {}
    if np.isnan(row['concept_id']):
        concept = insertConcept(conn, row)
        modified = True
    else:
        row['concept_id'] = int(row['concept_id'])
        # row['concept_code'] = int(row['concept_code'])
        # if type(row['concept_code']) is float:
        #     row['concept_code'] = int(row['concept_code'])
        # else:
        #     row['concept_code'] = str(row['concept_code'])

        searched = getById(cur, row['concept_id'])
        change = needChange(row, searched)
        if change:
            updateConcept(conn, row)
        else:
            concept = insertConcept(conn, row)

    if modified:
        print (concept)
        print (index)
        print (inversecolumn['concept_id'])
        wb.loc[index, inversecolumn['concept_id']] = concept['concept_id']
        # wb.loc[index, inversecolumn['concept_name']] = str(concept[1])
        wb.loc[index, inversecolumn['concept_code']] = int(concept['concept_code'])
        # wb.loc[index, inversecolumn['vocabulary_id']] = str(concept[3])
        # wb.loc[index, inversecolumn['concept_class_id']] = str(concept[4])
        row['concept_id'] = concept['concept_id']

# Viewer table. Skip this if section is empty.
    if row['section'] != row['section']:
        continue

    searched = getById1(cur, row['concept_id'])
    change = needChange(row, searched)
    if change:
        updateConcept1(conn, row)
    else:
        insertCategory(conn, row)


print(wb)
wb.to_excel(e['name'], sheet_name=e['sheet'], index=False)

if conn is not None:
    conn.close()
    print('Database connection closed.')

# if conn1 is not None:
#     conn1.close()
#     print('Database connection1 closed.')
