import glob, csv, sys
from itertools import islice

#returns the line found at the spcified index lineIndex inside a language specific file
def getLine(lineIndex, language):
    fileName=corpus+language+"-en."+language
    lines = open(fileName).read().splitlines()
    if(len(lines) < lineIndex):
        print "ERROR!!"
        return
    #return the line with the given index
    line = lines[lineIndex]
    return line

def getCorrespondingLines(engLine, retrieved, noOfSkippedLines):
    indices = [-1]*len(retrieved)
    indices[0]=0
    for j in range(1,len(retrieved)):
        with open(engFiles[j], 'rb') as enf:
            #for computation efficiency reasons, we choose to look up the translated version of the English
            #sentence inside a window ranging between the last retrieved position i_l and 100 + n_s*2 (only set as a safe margin)
            for i, line in enumerate(islice(enf, retrieved[j], 100 + retrieved[j] + noOfSkippedLines * 2)):
                line = line.replace("\n", "").strip()
                if(engLine == line):
                    # get the index of the first occurence
                    indices[j] = retrieved[j] + i
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
            print "i = " + str(i)
            if (line != []):
                line = line[0].strip()
                #get the indices corresponding to the current line inside the other files
                indices = getCorrespondingLines(line, retrieved, noOfSkippedLines)

                if (-1 in indices):
                    noOfSkippedLines += 1
                else:
                    retrieved[0] = i
                    retrieved[1:] = indices[1:]
                    noOfSkippedLines = 1
                    with open(output+"en.en", 'a') as out:
                        out.write(line + "\n")
                    for f in fors:
                        languageIndex = fors.index(f)
                        #get the line at the retrived index and append it to the output file
                        outLine = getLine(retrieved[languageIndex], f)
                        outFile = output+f+"-en."+f
                        with open(outFile, 'a') as out:
                             out.write(outLine + "\n")

def main():
    global corpus
    corpus = "data/corpusClean/"
    fors = ["da","de","es","fr","it","nl","pt"]
    global engFiles
    engFiles = [corpus+f+"-en.en" for f in fors]
    global ForFiles
    forFiles = [corpus+f+"-en."+f for f in fors]
    output = "data/corpusAligned4/"
    alignEuroparlCorpora(fors, output)

if __name__ == '__main__':
    main()
