from __future__ import division
import copy, itertools, operator, re
from collections import defaultdict

def ibm1(sentencePairs):

    # Step 1 - Initialize vocabulary.
    # Assume uniform initial probabilities t(e|f)

    print 'initializing vocabulary'
    englishSentences, foreignSentences = zip(*sentencePairs)
    foreignVocabulary = set(itertools.chain.from_iterable(foreignSentences))
    englishVocabulary = set(itertools.chain.from_iterable(englishSentences))

    t = dict()
    for e in englishVocabulary:
        t[e] = defaultdict(lambda: 1.0/len(foreignVocabulary))

    threshold = 0.01
    maxDiff = 1

    while maxDiff>threshold:
       print 'Starting iteration'
       counts = defaultdict(lambda: defaultdict(int))
       total = defaultdict(int)
       maxDiff = 0 # convergence criterion

       for es, fs in sentencePairs:

           # Compute normalization
           sTotal = [0] * len(fs)
           for i in range(len(fs)):
               for e in es:
                   sTotal[i] += t[e][fs[i]]

           # Collect (normalized) counts
           for i in range(len(fs)):
               if sTotal[i] > 0.0:
                  for e in es:
           #           print t[e][fs[i]], totals[i]
                      counts[e][fs[i]] += t[e][fs[i]] / sTotal[i]
                      total[e] += t[e][fs[i]]/sTotal[i]
               else:
                    print 'zero'
           # Estimate probabilities
           for i in range(len(fs)):
               if total[e] > 0.0:
                  for e in es:
                      old = t[e][fs[i]]
                      new = counts[e][fs[i]]/total[e]
                      difference = abs(old - new)
                      maxDiff = max(difference, maxDiff)
   #                   print old, new
                      t[e][fs[i]] = new
               else:
                  print 'zero two'
                  del t[e][fs[i]]

       printBest(t)
    return t

def printBest(t):
    print sorted(t['the'].items(), key = lambda x: x[1],reverse=True)[0:10]
    print sorted(t['is'].items(), key = lambda x: x[1],reverse=True)[0:10]



def loadSentences(encorpus, forcorpus):
    fen = open(encorpus,'r')
    ffor = open(forcorpus,'r')
    pairs = []
    for engSentence, forSentence in itertools.izip(fen,ffor):
        #remove unnecessary characters
        engSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', engSentence).split()
        forSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', forSentence).split()

        langpair = (engSentence,forSentence)
        pairs.append(langpair)
    return pairs


def main():
    englishCorpus = "corpus.en"
    foreignCorpus = "corpus.nl"
    pairedSentences = loadSentences(englishCorpus,foreignCorpus)

    t = ibm1(pairedSentences)


if __name__ == '__main__':
    main()







