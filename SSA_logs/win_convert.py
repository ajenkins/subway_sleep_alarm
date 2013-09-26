# Input: CSV file with attribute as first column
# Output: ARFF file with sliding window containing redundant data

import sys, fileinput, csv, copy
from collections import deque

# Constants
WINDOW_SIZE = 22
NUM_ATTRIBUTES = 5
INPUT_FILE = "red_pure.csv"
OUTPUT_FILE = "red_window" + str(WINDOW_SIZE) + ".arff"

# Functions used in __main__ 

def openFileForReading(filename):
    with open(filename, 'rU') as f:
        reader = csv.reader(f)
        return reader
        
def openFileForWriting(filename):
    with open(filename, 'wb') as f:
        return f
        
def writeToFile(string, file):
    file.write(string)
    
def createOutputFile(filename, data, window_size):
    with open(filename, 'wb') as g:
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
        
        writer = csv.writer(g, lineterminator='\n')
        
        for elements in data:
            writer.writerow(elements)
            
        g.close()

# Window is a list containing many instances            
def slideWindow(window, nextInstance, num_attributes):
    attribute = nextInstance.pop(0)
    window.popleft()
    for i in range(num_attributes):
        window.pop()
    window.extendleft(reversed(nextInstance))
    window.appendleft(attribute)
    return window
    
def convertDataFormat(filename, window_size):
    with open(filename, 'rU') as f:
        reader = csv.reader(f)
        
        window = deque()
        alldata = deque()
        
        i = 0
        for row in reader:
            if i < (window_size-1):
                window.extendleft(reversed(row[1:]))
                i+=1
            else:
                window.extendleft(reversed(row))
                break
                
#         alldata.append(window)
        
        for row in reader:
            window = slideWindow(window, row, NUM_ATTRIBUTES)
            cpy = copy.deepcopy(window)
            alldata.append(cpy)
#             print alldata
        
        f.close()
        return alldata
        
if __name__ == '__main__':
    data = convertDataFormat(INPUT_FILE, WINDOW_SIZE)
    createOutputFile(OUTPUT_FILE, data, WINDOW_SIZE)
            
        
        
                
                       
