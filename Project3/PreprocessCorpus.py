import glob, csv, sys

csv.field_size_limit(sys.maxsize)

engFile1 = "MTProject3/data/fr-en/europarl-v7.fr-en.en"
engFile2 = "MTProject3/data/nl-en/europarl-v7.nl-en.en"
engFile3 = "MTProject3/data/ro-en/europarl-v7.ro-en.en"

frFile = "MTProject3/data/fr-en/europarl-v7.fr-en.fr"
nlFile = "MTProject3/data/nl-en/europarl-v7.nl-en.nl"
roFile = "MTProject3/data/ro-en/europarl-v7.ro-en.ro"

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
    
def alignEuroparlCorpora(engFile1):
    #output files
    fAlignedFrenchFile = open("MTProject3/data/fr-en/europarl-v7-alignedFR.fr-en.fr", 'w')
    fAlignedDutchFile = open("MTProject3/data/nl-en/europarl-v7-alignedNL.nl-en.nl", 'w')
    fAlignedRomanianFile = open("MTProject3/data/ro-en/europarl-v7-alignedRO.ro-en.ro", 'w')

    with open(engFile1, 'rb') as engFile1:
        lines = csv.reader(engFile1, delimiter='\n')
        for i, line in enumerate(lines):
            print i
            print line
            #check if the very same line is found in the other two english files
            lineFound = lineLookup(line, engFile2, engFile3)
            if(lineFound == 1):
                print "found"
                #retrieve the line from file at the corresponding index
                fAlignedFrenchFile.write(getLine(i, "fr"))
                fAlignedDutchFile.write(getLine(i, "nl"))
                fAlignedRomanianFile.write(getLine(i, "ro"))
            else:
                print "not found"

    fAlignedFrenchFile.close()
    fAlignedDutchFile.close()
    fAlignedRomanianFile.close()

def main():
    alignEuroparlCorpora(engFile1)

if __name__ == '__main__':
    main()
