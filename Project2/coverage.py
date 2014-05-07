from __future__ import division
from fileHandling import *

"""
Create a phrase table from Moses' output
Param: mosesPhrases  - the file with Moses' phrase table
Return: enPhrases    - a dictionary EN-FOR with value 1
"""
def getMosesPhrasetable(mosesPhrases):
    print 'Converting Moses output to phrase table...'
    engPhrases = defaultdict(lambda: defaultdict(int))
    with open(mosesPhrases) as fp:
        i = 0
        for line in fp:
            parts = line.split(' ||| ')
            forPhrase = parts[0]
            engPhrase = parts[1]
            engPhrases[engPhrase][forPhrase] = 1
    print 'Done'
    return engPhrases

"""
Compute precision and recall of a phrase table with respect to another
Param: reference   - a dictionary EN-FOR that is the reference
       phraseTable - a dictionary EN-FOR that is evaluated
Return: precision  - true positives / size of the phraseTable
        recall     - true positives / size of the reference
"""
def precisionRecall(reference, phraseTable):
    print 'Computing precision and recall...'
    truePos = 0
    falseNeg = 0
    size = sum(len(v) for v in reference.itervalues())
    retrieved = sum(len(v) for v in phraseTable.itervalues())

    for engPhrase, forPhrases in reference.iteritems():
        for forPhrase, est in forPhrases.iteritems():
            if forPhrase in phraseTable[engPhrase]:
               truePos += 1

    precision = truePos/ retrieved
    recall = truePos/ size
#    print 'Size of the reference table:',size
#    print 'Size of the evaluated table:',retrieved
#    print 'TP:',truePos,'FN:', falseNeg

    print 'Precision:', precision, 'Recall:', recall
    print 'Done'
    return precision, recall











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

def computeCoverage(trainingDict, heldoutDict):
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
                    print "Built ", engPhrase, '\t ==>\t', forPhrase
                    known += 1
    coverage = known/(known+unknown)
    print 'known', known
    print 'unknown', unknown
    print 'coverage', coverage
    print "Done"
    return coverage
