# This is a function designed to take a long format csv file and convert it
# into a wide format arff file. First column should be the nom-attribute.

import sys, csv, fileinput

# Constants for file IO
input_filename = 'green_pure.csv'
output_filename = 'green_wide.arff'

# Contains entire converted data set
alldata = []

# Keeps track of the longest instance encountered
longestInst = 0

# Reads the csv file
with open(input_filename, 'rU') as f:
    
    reader = csv.reader(f)
    
    row = reader.next()
    
    for row in reader:
       
        # A single row in the output file
        instance = []
        
        # Gets next attribute
        currAttr = row[0]
        instance.append(currAttr)
        
        # Steps through file adding everything to instance
        # until a new attribute is found
        for row in reader:
            if currAttr == row[0]:
                instance.extend(row[1:])
            else:
                break
            
        # Updates longest instance  
        currLength = len(instance)
        if currLength > longestInst:
            longestInst = currLength
            
        # Adds instance to list of instances
        alldata.append(instance)
        
f.close()

# Add ?s to the end of instance
for instance in alldata:
    instance.extend('?' * (longestInst - len(instance)))

# Writes the csv file
with open(output_filename, 'wb') as g:

    # Create arff format header
    g.write('@RELATION wide\n\n')
    g.write('@ATTRIBUTE movement {moving, stopped}\n')
    for i in range(longestInst/5):
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