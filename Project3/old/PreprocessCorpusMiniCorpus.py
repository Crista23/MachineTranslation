import glob, csv, sys
from itertools import islice

csv.field_size_limit(sys.maxsize)

engFile1 = "EnFile1.txt"
engFile2 = "EnFile2.txt"
engFile3 = "EnFile3.txt"

frFile = "ForFile1.txt"
nlFile = "ForFile2.txt"
roFile = "ForFile3.txt"

engFile2LastRetrievedIndex = 0
engFile3LastRetrievedIndex = 0
noOfSkippedLines = 1

def lineLookup(engLineFile1, engFile2, engFile3):
    with open(engFile2, 'rb') as engFile2, open(engFile3, 'rb') as engFile3:
        lines2 = csv.reader(engFile2, delimiter='\n')
        lines3 = csv.reader(engFile3, delimiter='\n')
        if ((engLineFile1 in lines2) and (engLineFile1 in lines3)):
            return 1
    return 0

def getLine(lineIndex, fileType):
    if(fileType == "fr"):
        fileName = frFile
    elif (fileType == "nl"):
        fileName = nlFile
    elif (fileType == "ro"):
        fileName = roFile
    
    lines = open(fileName).read().splitlines()
    if(len(lines) < lineIndex):
        print "ERROR!!"
        return
    
    line = lines[lineIndex]
    return line

def getCorrespondingLines(engLine):
    engFile2Index = -1
    engFile3Index = -1
    global engFile2LastRetrievedIndex, engFile3LastRetrievedIndex
    global noOfSkippedLines
    
    with open(engFile2, 'rb') as enf2, open(engFile3, 'rb') as enf3:
        #for i, line in enumerate(islice(enf2, engFile2LastRetrievedIndex, engFile2LastRetrievedIndex + noOfSkippedLines * 3)):
        for i, line in enumerate(islice(enf2, engFile2LastRetrievedIndex, None)):
            line = line.replace("\n", "").strip()
            print "lines is: " + line
            if(engLine == line):
                print "engline is: " + engLine
                # get the index of the first occurence
                engFile2Index = engFile2LastRetrievedIndex + i
                engFile2LastRetrievedIndex = engFile2Index
                break
        
        #for j, line in enumerate(islice(enf3, engFile3LastRetrievedIndex, engFile3LastRetrievedIndex + noOfSkippedLines * 3)):
        for j, line in enumerate(islice(enf3, engFile3LastRetrievedIndex, None)):
            line = line.replace("\n", "").strip()
            if(engLine == line):
                # get the index of the first occurence
                engFile3Index = engFile3LastRetrievedIndex + j
                engFile3LastRetrievedIndex = engFile3Index
                break
    
    return engFile2Index, engFile3Index

def alignEuroparlCorpora(engFile1):
    global noOfSkippedLines
    #output files
    fAlignedEnglishFile = open("MTProject3/data/fr-en/europarl-v7-alignedEN.en-en.en", 'w')
    fAlignedFrenchFile = open("MTProject3/data/fr-en/europarl-v7-alignedFR.fr-en.fr", 'w')
    fAlignedDutchFile = open("MTProject3/data/nl-en/europarl-v7-alignedNL.nl-en.nl", 'w')
    fAlignedRomanianFile = open("MTProject3/data/ro-en/europarl-v7-alignedRO.ro-en.ro", 'w')

    with open(engFile1, 'rb') as engFile1:
        lines = csv.reader(engFile1, delimiter='\n')
        for i, line in enumerate(lines):
            if (line != []):
                line = line[0].strip()
                print line
                engFile2Index, engFile3Index = getCorrespondingLines(line)
                print engFile2Index, engFile3Index
                if(engFile2Index != -1 and engFile3Index != -1):
                    noOfSkippedLines = 1
                    print "|" + line + "|"
                    print "RETRIEVE LINES"
                    fAlignedEnglishFile.write(line + "\n")
                    print getLine(i, "fr")
                    fAlignedFrenchFile.write(getLine(i, "fr") + "\n")
                    print getLine(engFile2Index, "nl")
                    fAlignedDutchFile.write(getLine(engFile2Index, "nl") + "\n")
                    print getLine(engFile3Index, "ro")
                    fAlignedRomanianFile.write(getLine(engFile3Index, "ro") + "\n")
                else:
                    noOfSkippedLines += 1
                
    fAlignedEnglishFile.close()
    fAlignedFrenchFile.close()
    fAlignedDutchFile.close()
    fAlignedRomanianFile.close()

def main():
    alignEuroparlCorpora(engFile1)

if __name__ == '__main__':
    main()
