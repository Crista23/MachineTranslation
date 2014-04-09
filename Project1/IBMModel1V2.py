from __future__ import division
import copy, itertools, operator, re
from collections import defaultdict

def ibm1(sentencePairs):

    # Step 1 - Initialize vocabulary.
    # Assume uniform initial probabilities t(e|f)

    print 'initializing vocabulary'
    foreignSentences, englishSentences = zip(*sentencePairs)
    foreignVocabulary = set(itertools.chain.from_iterable(foreignSentences))
    englishVocabulary = set(itertools.chain.from_iterable(englishSentences))

    translationDictionary = dict()
    for e in englishVocabulary:
        translationDictionary[e] = defaultdict(lambda: 1.0/len(foreignVocabulary))


    nrIter = 0
    while nrIter < 5:
       nrIter += 1
       print 'starting iteration', nrIter
       counts = defaultdict(lambda: defaultdict(int))
       total = defaultdict(int)

       for fs, es in sentencePairs:
           totals = [0] * len(fs)
           for i in range(len(fs)):
               for e in es:
           #        print e, fs[i]
           #        print translationDictionary[e][fs[i]]

                   totals[i] += translationDictionary[e][fs[i]]
           for i in range(len(fs)):
               if totals[i] > 0.0:
                  for e in es:

                   print translationDictionary[e][fs[i]], totals[i]
                   counts[e][i] += translationDictionary[e][fs[i]] / totals[i]
                   total[e] += translationDictionary[e][fs[i]]/totals[i]
               else:
                    print 'zero'

       for i in range(len(fs)):
           if total[e] > 0.0:
              for e in es:
                  translationDictionary[e][fs[i]] = counts[e][fs[i]]/total[e]


def loadSentences(encorpus, forcorpus):
    fen = open(encorpus,'r')
    ffor = open(forcorpus,'r')
    pairs = []
    maxM = 0
    maxL = 0
    for engSentence, forSentence in itertools.izip(fen,ffor):
        #remove unnecessary characters
        engSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', engSentence).split()
        forSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', forSentence).split()

        langpair = (engSentence,forSentence)
        pairs.append(langpair)
    return pairs


def main():
    """
    pairedSentences = [('mi casa verde'.split(), 'my green house'.split()),
                        ('casa verde'.split(), 'green house'.split()),
                        ('la casa'.split(), 'the house'.split())]

    """
    EnglishCorpus = "corpusmini.en"
    ForeignCorpus = "corpusmini.nl"
    # pairedSentences looks like: [(['mi', 'casa', 'verde'], ['my', 'green', 'house']), (['casa', 'verde'], ['green', 'house']), (['la', 'casa'], ['the', 'house'])]
    pairedSentences = loadSentences(ForeignCorpus, EnglishCorpus)

    print ibm1(pairedSentences)


if __name__ == '__main__':
    main()







