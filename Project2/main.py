from __future__ import division
from collections import defaultdict
#from phraseExtraction import *
from weightEstimation import *
from fileHandling import *

def nGrams(wordList,n):
    l = len(wordList)
    if n == 0:
       return set()
    else:
       nGrams = nGrams(wordList, n-1)
    if n<=l:
       for i in range(l-n):
           nGrams.add(wordList[i:i+n-1])
    return nGrams

def construct(phrasepair,trainDict):
    enwords = phrasepair[0].split()
    fwords = phrasepair[1].split()

#    print enwords, nGrams(enWords,3)



    return False

def computeCoverage():
    enFile = "data/training/p2_training.en"
    forFile = "data/training/p2_training.nl"
    alignFile = "data/training/p2_training_symal.nlen"
    trainingDict, n = fileToPhrases(enFile, forFile, alignFile)

    enFile = "data/heldout/p2_heldout.en"
    forFile = "data/heldout/p2_heldout.nl"
    alignFile = "data/heldout/p2_heldout_symal.nlen"
    heldoutDict, n = fileToPhrases(enFile, forFile, alignFile)

    print "Computing coverage..."
    known = 0
    unknown = 0
    for engPhrase, forDict in heldoutDict.iteritems():
        if engPhrase in trainingDict.keys():
           compareTo = trainingDict[engPhrase]
        else:
           compareTo = dict()
        for forPhrase in forDict:
            if forPhrase in compareTo:
                known += 1
            else:
                buildable = construct((engPhrase,forPhrase),trainingDict)
                if not buildable:
                    unknown += 1
                else:
                    known += 1
    print 'known', known
    print 'unknown', unknown
    print "Done"
    return known/unknown

def getReady():
    return



def main():
    print computeCoverage()


#    for engPhrase, forDict in engPhrases.iteritems():
#        print "key", engPhrase
 #       for forPhrase, count in forDict.iteritems():
  #          print "\t", forPhrase, count
    #a = getDecodingDict(engPhrases)
    #print len(a)
    #print a

if __name__ == '__main__':
    main()
