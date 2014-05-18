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

def getCorrespondingLines(engLine):
    engFile2Index = -1
    engFile3Index = -1
    
    with open(engFile2, 'rb') as enf2, open(engFile3, 'rb') as enf3:
        for i, line in enumerate(enf2):
            line = line.replace("\n", "")
            print "line"
            print line
            if(engLine == line):
                # get the index of the first occurence
                engFile2Index = i
                break
        for j, line in enumerate(enf3):
            line = line.replace("\n", "")
            if(engLine == line):
                # get the index of the first occurence
                engFile3Index = j
                break
    return engFile2Index, engFile3Index

def alignEuroparlCorpora(engFile1):
    #output files
    fAlignedEnglishFile = open("MTProject3/data/fr-en/europarl-v7-alignedEN.en-en.en", 'w')
    fAlignedFrenchFile = open("MTProject3/data/fr-en/europarl-v7-alignedFR.fr-en.fr", 'w')
    fAlignedDutchFile = open("MTProject3/data/nl-en/europarl-v7-alignedNL.nl-en.nl", 'w')
    fAlignedRomanianFile = open("MTProject3/data/ro-en/europarl-v7-alignedRO.ro-en.ro", 'w')

    with open(engFile1, 'rb') as engFile1:
        lines = csv.reader(engFile1, delimiter='\n')
        for i, line in enumerate(lines):            
            line = line[0]
            engFile2Index, engFile3Index = getCorrespondingLines(line)
            if(engFile2Index != -1 and engFile3Index != -1):
                print "RETRIEVE LINES"
                fAlignedEnglishFile.write(line + "\n")
                fAlignedFrenchFile.write(getLine(i, "fr"))
                fAlignedDutchFile.write(getLine(engFile2Index, "nl"))
                fAlignedRomanianFile.write(getLine(engFile3Index, "ro"))

    fAlignedFrenchFile.close()
    fAlignedDutchFile.close()
    fAlignedRomanianFile.close()

def main():
    alignEuroparlCorpora(engFile1)

if __name__ == '__main__':
    main()
