import glob, csv, sys
from itertools import islice

#retrive the line from a specific language file found at index lineIndex
def getLine(lineIndex, language):
    fileName=corpus+language+"-en."+language

    lines = open(fileName).read().splitlines()
    if(len(lines) < lineIndex):
        print "ERROR!!"
        return

    line = lines[lineIndex]
    return line

# returns a list of indices of the lines from foreign files that are aligned with a given English line
def getCorrespondingLines(engLine, retrieved, noOfSkippedLines):
    indices = [-1]*len(retrieved)
    indices[0]=0
    for j in range(1,len(retrieved)):
        with open(engFiles[j], 'rb') as enf:
            # for memory efficiency resons, we only look at the lines found between the last retrieved line and the last retrieved line plus
            # the no of lines that were skipped until that lines was retrieved * 3,
            # where 3 is only a safe margin to avoid looping until the end of the file
             for i, line in enumerate(islice(enf, retrieved[j], retrieved[j] + noOfSkippedLines * 3)):
                 line = line.replace("\n", "").strip()
                 if(engLine == line):
                     # get the index of the first occurence
                     indices[j] = retrieved[j] + i
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
                # get the indices from the foreign files of the lines that are translations of the current line
                indices = getCorrespondingLines(line, retrieved, noOfSkippedLines)

                if (-1 in indices):
                    # keep track of the number of skipped lines since the last retrieved position inside the English file
                    noOfSkippedLines += 1
                else:
                    retrieved[0] = i
                    retrieved[1:] = indices[1:]
                    noOfSkippedLines = 1
                    print "|" + line + "|"
                    print "RETRIEVE LINES"
                    # append line to the English aligned file
                    with open(output+"en.en", 'a') as out:
		         out.write(line + "\n")  
                    for f in fors:
                        outLine = getLine(i, f)
                        outFile = output+f+"-en."+f
                        # append the line to each corresponding foreign aligned file
                        with open(outFile, 'a') as out:
                             out.write(outLine + "\n")
                             print outLine

def main():
    global corpus
    corpus = "/home/sveldhoen/MTProject3/data/corpusClean/"
    # we use 7 foreign languages - Danish, Deutsch, Spanish, French, Italian, Netherlands, Portugese
    fors = ["da","de","es","fr","it","nl","pt"]
    global engFiles
    # retrieve the English files for each language pair
    engFiles = [corpus+f+"-en.en" for f in fors]
    global ForFiles
    # retrieve the foreign files for each language pair
    forFiles = [corpus+f+"-en."+f for f in fors]

    output = "/home/sveldhoen/MTProject3/data/corpusAligned/"

    alignEuroparlCorpora(fors, output)

if __name__ == '__main__':
    main()
