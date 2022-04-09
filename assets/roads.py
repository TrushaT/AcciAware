import csv
from csv import writer

filename = 'assets/road_records.csv'
to_be_added = []

with open(filename, 'r') as csvfile:
    datareader = csv.reader(csvfile)
    for row in datareader:
        if('Road' in row[0]):
            to_be_added.append([row[0].replace('Road','Rd'),row[1],row[2]])

with open(filename, 'a') as f_object:
    writer_object = writer(f_object)
    for item in to_be_added:
        writer_object.writerow(item)
    f_object.close()
