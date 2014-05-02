from __future__ import division
from fileHandling import *


def breakPhrase(phrase):
    i = phrase.find(' ')     # find the first ' '
    if i<0:                  # if there is none:
       return[[phrase]]      # entire phrase is the only possibility
    else:
        possibilities = []
        # compute the possibilities from the space
        rest = breakPhrase(phrase[i+1:])
        for poss in rest:
# 2 ways: 1: add the word
#         to the first phrase in the possibility.
#      or 2: add it as a new phrase in the possibility
            way1=poss[:]
            way1[0]=phrase[0:i+1]+way1[0]
            poss.insert(0,phrase[0:i])
            possibilities.extend([poss,way1])
    return possibilities


def construct(enBroken, forBroken, trainDict):
#    print "constructing"
    if len(enBroken)<1:
       return False
#    print "English sentence broken:"
    for posE in enBroken:
#        print posE
        translations = trainDict[posE[0]]
        for posF in forBroken:
            for j in range(len(posF)):
                if posF[j] in translations:
#                   print 'match'
                   foreignToDo = posF[:j]+posF[j+1:]
                   if len(posE[1:])==0:
                      if len(foreignToDo)==0:
                         return True
                      else:
                         return False
                   else:  #See if we can construct the rest:
                       if construct([posE[1:]],foreignToDo,trainDict):
                           return True
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
        broken = breakPhrase(engPhrase)
        if engPhrase in trainingDict.keys():
           compareTo = trainingDict[engPhrase]
        else:
           compareTo = dict()
        for forPhrase in forDict:
            if forPhrase in compareTo:
                known += 1
            else:
                buildable = construct(broken,breakPhrase(forPhrase),trainingDict)
                if not buildable:
                    unknown += 1
                else:
                    print "Built ", engPhrase,forPhrase
                    known += 1
    print 'known', known
    print 'unknown', unknown
    print "Done"
    return known/(known+unknown)
