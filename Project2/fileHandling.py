from collections import defaultdict
from phraseExtraction import *

"""
Read a line from the alignment file and convert it to a list of alignment pairs
Param:  sentence   - a line from the alignment file, looks like 0-0 1-0 1-1 3-2 2-3 5-4 6-5 7-5 6-6 8-7 9-8
Return: list       - a list of alignment points: pairs (tuples) of integers
"""
def getWordAlignments(sentence):
    A = set()
    sentence = sentence.split(" ")
    for alignment in sentence:
        e_pos, f_pos = alignment.split("-")
        A.add((int(e_pos), int(f_pos)))
    return list(A)

"""
Read sentences and alignments from files
Param:  enFile     - the file with English sentences
        forFile    - the file with foreign sentences
        alignFil   - the file with (symmetrized) alignments
Return: enSen      - a list of english sentences: lists of words
        forSen     - a list of foreign sentences: lists of words
        alignments - a list of lists of alignment points: pairs of ints
"""
def readFiles(enFile,forFile,alignFile):
    print "Reading data from files..."
    with open(enFile,"r") as f:
         enSen = f.read().splitlines()
         enSen = [line.split() for line in enSen]
    with open(forFile,"r") as f:
         forSen = f.read().splitlines()
         forSen = [line.split() for line in forSen]

    alignmentsRaw = list(open(alignFile,'r'))
    alignments = [getWordAlignments(al) for al in alignmentsRaw]

    if (len(enSen) != len(forSen) or len(enSen) != len(alignments)):
        print "File length mismatch!"
        return
    else:
        print "Done: ",len(enSen), "lines per file"
        return enSen, forSen, alignments


def fileToPhrases(enFile, forFile, alignFile):
    print "Extracting phrase pairs..."
    enSen, forSen, gialignments = readFiles(enFile,forFile,alignFile)
    engPhrases = defaultdict(lambda: defaultdict(int))
    n = 0
    for i in range(min(len(enSen),250)):
#    for i in range(len(enSen)):
        if i%50 == 0:
           print i
        engPhrases, ni = extractPairs(enSen[i],forSen[i],alignments[i],4, engPhrases)
        n += ni
    print "Done"
    return engPhrases, n
