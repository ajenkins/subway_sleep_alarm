# This is a function designed to take a csv file and convert it
# into an arff file with a sliding n-size window. First column should be
# the nom-attribute

import sys, csv, fileinput
from collections import deque

# Constants for file IO
input_filename = 'red_pure.csv'
output_filename = 'red_window10.arff'

# Contains entire converted data set
alldata = []

# Size of window (number of instances / window)
window_size = 2

# Number of attribute types
numAttributes = 5

# Reads the csv file
with open(input_filename, 'rU') as f:
    
    reader = csv.reader(f)
    
    # A single row in the output file
    instance = deque()
    
    # This loop makes sure first window fills up before moving on to next instance
    i = 0
    for row in reader:
        if i < window_size:
            print "window_size times?"
            instance.extend(row[1:])
            i += 1
        else:
            print "More than once?"
            break
            
    instance.appendleft(row[0])
    alldata.append(instance)
    
    for row in reader:  
        # Updates instance / slides window
        for i in range(numAttributes + 1):
            instance.popleft()
        instance.extend(row[1:])
        
        # Gets next attribute
        instance.appendleft(row[0])
        print instance
        alldata.append(instance)
        
f.close()

# Writes the csv file
with open(output_filename, 'wb') as g:

    # Create arff format header
    g.write('@RELATION window\n\n')
    g.write('@ATTRIBUTE movement {moving, stopped}\n')
    for i in range(window_size):
        g.write('@ATTRIBUTE time' + str(i) + ' NUMERIC\n')
        g.write('@ATTRIBUTE r' + str(i) + ' NUMERIC\n')
        g.write('@ATTRIBUTE x' + str(i) + ' NUMERIC\n')
        g.write('@ATTRIBUTE y' + str(i) + ' NUMERIC\n')
        g.write('@ATTRIBUTE z' + str(i) + ' NUMERIC\n')
    g.write('\n@DATA\n')
    
    # Write the data
    writer = csv.writer(g, lineterminator='\n')
    
    for instance in alldata:
        writer.writerow(instance)
        
g.close()