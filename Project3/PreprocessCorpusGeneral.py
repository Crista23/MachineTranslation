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
    indices = [-1]*len(fors)
    indices[0]=0
    for j in range(1,len(fors)):
        with open(engFiles[j], 'rb') as enf:
             for i, line in enumerate(islice(enf, retrieved[j], retrieved[j] + noOfSkippedLines * 3)):
                 line = line.replace("\n", "").strip()
                 if(engLine == line):
                     # get the index of the first occurence
                     indices[j] = retrieved[j] + i
#                     engFile2LastRetrievedIndex = engFile2Index
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
                indices = getCorrespondingLines(line)

                if (-1 in indices):
                    noOfSkippedLines += 1
                else:
                    retrieved[0] = i
                    retrieved[1:] = indices[1:]
                    noOfSkippedLines = 1
                    print "|" + line + "|"
                    print "RETRIEVE LINES"
                    for j in fors:
                        outLine = getLine(i, f)
                        outFile = output+f+"-en."+f
                        with open(outFile, 'a') as out:
                             out.write(outLine + "\n")
                             print outLine
                else:
                    noOfSkippedLines += 1

def main():
    corpus = "home/sveldhoen/MTProject3/data/corpusClean/"
    global engFiles
    engFiles = [corpus+f+"-en.en" for f in fors]
    global ForFiles
    forFiles = [corpus+f+"-en."+f for f in fors]

    output = "home/sveldhoen/MTProject3/data/corpusAligned/"
    fors = ["el","da","de","es","fr","it","nl","pt"]


    alignEuroparlCorpora(fors, output)

if __name__ == '__main__':
    main()
