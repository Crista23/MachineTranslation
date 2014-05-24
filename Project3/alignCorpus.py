import glob, csv, sys
from itertools import islice

def getLine(lineIndex, language):
    fileName=corpus+language+"-en."+language

    lines = open(fileName).read().splitlines()
    if(len(lines) < lineIndex):
        print "ERROR!!"
        return

    line = lines[lineIndex]
    return line

def getCorrespondingLines(engLine, retrieved, noOfSkippedLines):
    indices = [-1]*len(retrieved)
    indices[0]=0
    for j in range(1,len(retrieved)):
        with open(engFiles[j], 'rb') as enf:
             for i, line in enumerate(islice(enf, retrieved[j], retrieved[j] + noOfSkippedLines * 3)):
                 line = line.replace("\n", "").strip()
                 if(engLine == line):
                     # get the index of the first occurence
                     indices[j] = retrieved[j] + i
#                     engFile2LastRetrievedIndex = engFile2Index
                     break
	if indices[j]<0:
	    break
    return indices

def alignEuroparlCorpora(fors, output):
    retrieved = [0] * len(fors)
    noOfSkippedLines = 1

    with open(engFiles[0], 'rb') as engFile1:
        lines = csv.reader(engFile1, delimiter='\n')
        for i, line in enumerate(lines):
            if (line != []):
                line = line[0].strip()
                indices = getCorrespondingLines(line, retrieved, noOfSkippedLines)

                if (-1 in indices):
		    print "NOT ALIGNED"
                    noOfSkippedLines += 1
                else:
		    print "RETRIEVED"
                    retrieved[0] = i
                    retrieved[1:] = indices[1:]
                    noOfSkippedLines = 1
 #                   print "|" + line + "|"
#                    print "RETRIEVE LINES"
                    with open(output+"en.en", 'a') as out:
		         out.write(line + "\n")
                    for f in fors:
                        outLine = getLine(i, f)
                        outFile = output+f+"-en."+f
                        with open(outFile, 'a') as out:
                             out.write(outLine + "\n")
#                             print outLine

def main():
    global corpus
    corpus = "/home/sveldhoen/MTProject3/data/corpusClean/"
    fors = ["da","de","es","fr","it","nl","pt"]
    global engFiles
    engFiles = [corpus+f+"-en.en" for f in fors]
    global ForFiles
    forFiles = [corpus+f+"-en."+f for f in fors]

    output = "/home/sveldhoen/MTProject3/data/corpusAligned3/"

    alignEuroparlCorpora(fors, output)

if __name__ == '__main__':
    main()
