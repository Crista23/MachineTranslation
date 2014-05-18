'''
mGiza alignments are in the following format, that has three lines per corpus line:
# <alignment information>
<source sentence>
<target word 1> ({<aligned words>}) <target word 2> ({<aligned words>}) ... <target word n> ({<aligned words>})

This script converts it to something that is easier to process: a list of alignment points on one line
<source-position>-<target-position> <source-position>-<target-position> ... <source-position>-<target-position>

'''



def main():
    inputFile = "mgizaAlignment.fr-en.fr"
    outputFile = "standardAlignment.fr-en.fr"
    convertAlignments(inputFile,outputFile)



def determineAlignment(foreignSentence, englishSentence):
    alignment = []
    foreignWords = foreignSentence.split(" ")
    englishWords = englishSentence.replace("({ ", "").split(" }) ")
    englishWords = [word for word in englishWords if word != '']
    for i in range(len(foreignWords)):
        index = i + 1
        for j in range(len(englishWords)):
            wordIndex = str(index)
            engValues = englishWords[j].split(" ")
            if (wordIndex in engValues):
                alignment.append(j)
    return alignment

def convertAlignments(inputFile, outputFile):

    alignmentInfo = ""
    foreignSentence = ""
    englishSentence = ""

    i=0
    with open(inputFile, 'r') as al, open(outputFile, 'w') as out:
        for line in al:
            line = line.replace("\n", "")
            if line.startswith("#"):
                alignmentInfo = line
            elif line.startswith("NULL"):
                englishSentence = line
            else:
                foreignSentence = line
            i += 1
            if(i % 3 == 0):
                out.write(determineAlignment(foreignSentence, englishSentence)+'\n')
