from __future__ import division
from collections import defaultdict
from weightEstimation import *
from coverage import *

"""
Compute quality of extraction
Param:
Return: coverage   - coverage of the training dictionary as compared to the heldout data
        precision  - precision of the training dictionary as compared to the Moses phrase table
        recall     - recall of the training dictionary as compared to the Moses phrase table
"""
def computeQuality():
    # Retrieve phrase tables from training data, heldout data, Moses
    enFile = "data/training/p2_training.en"
    forFile = "data/training/p2_training.nl"
    alignFile = "data/training/p2_training_symal.nlen"
    trainingDict, n = fileToPhrases(enFile, forFile, alignFile)

    enFile = "data/heldout/p2_heldout.en"
    forFile = "data/heldout/p2_heldout.nl"
    alignFile = "data/heldout/p2_heldout_symal.nlen"
    heldoutDict, n = fileToPhrases(enFile, forFile, alignFile)

    mosesFile = 'data/mosesOutput/model/phrase-table/phrase-table'
    mosesDict = getMosesPhrasetable(mosesFile)

    # Compute coverage and precision and recall
    precision, recall =  precisionRecall(mosesDict, trainingDict)
    coverage = computeCoverage(trainingDict, heldoutDict)
    coverage2 = computeCoverage(mosesDict,heldoutDict)


    print "Coverage of our phrase table as compared to the held-out corpus:", coverage
    print "Precision resp. recall of our phrase table as compared to the Moses phrase table:", precision, recall
    print "Coverage of the Moses phrase table as compared to the held-out corpus:", coverage2

    return coverage, precision, recall

"""
Extract phrases, estimate their weights and return the decoding dictionary
Param:
Return: decodingDict - a dictionary FOR-EN with weight estimates (conditional and joint)
"""
def getReady():
    enFile = "data/training/p2_training.en"
    forFile = "data/training/p2_training.nl"
    alignFile = "data/training/p2_training_symal.nlen"
    trainingDict, n = fileToPhrases(enFile, forFile, alignFile)
    decodingDict = getDecodingDict(trainingDict, n)
    return decodingDict


def main():
    coverage, precision, recall = computeQuality()
    #decodingDict = getReady()

if __name__ == '__main__':
    main()
