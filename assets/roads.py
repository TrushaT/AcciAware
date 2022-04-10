import csv
from csv import writer

filename = 'assets/road_records.csv'
to_be_added = []

# with open(filename, 'r') as csvfile:
#     datareader = csv.reader(csvfile)
#     for row in datareader:
#         if('Road' in row[0]):
#             to_be_added.append([row[0].replace('Road','Rd'),row[1],row[2]])

# with open(filename, 'a') as f_object:
#     writer_object = writer(f_object)
#     for item in to_be_added:
#         writer_object.writerow(item)
#     f_object.close()

avg_shape_length = 0
c = 0
s = 0
with open(filename, 'r') as csvfile:
    datareader = csv.reader(csvfile)
    i = 0
    for row in datareader:
        if i == 0:
            i = 1
            continue
        s += float(row[2])
        c += 1 
avg_shape_length = s/c
print(avg_shape_length)
