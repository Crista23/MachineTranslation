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

    nIter = 1

    while nIter<21:
       print 'Starting iteration', nIter
       nIter += 1
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
                      t[e][fs[i]] = new
               else:
                  print 'zero two'
                  del t[e][fs[i]]

   #    printBest(t)
    return t

def printBest(t):
    print 'the'
    print sorted(t['the'].items(), key = lambda x: x[1],reverse=True)[0:10]
    print 'is'
    print sorted(t['is'].items(), key = lambda x: x[1],reverse=True)[0:10]
    
def translationTable(t,tV, output):
    f = open(output, 'w')

    words = ['the', 'in', '.', 'all','should', 'public']
    for word in words:
        topT = sorted(t[word].items(), key = lambda x: x[1],reverse=True)

        f.write('\n'+ word+'\tTrained:\tViterbi:\n')
        for i in range(10):
            f.write(str(topT[i][0]))
            f.write('\t'+ str(topT[i][1]))
            f.write('\t'+ str(tV[word][topT[i][0]]))
#            f.write(str(topT[i])+'\t'+str(topTV[i])+'\n')

            f.write('\n')

    f.close()



def viterbiAlignment(sentencepairs, t, output):
    counts = defaultdict(lambda: defaultdict(int))
    total = defaultdict(int)
    f = open(output, 'w')
    i = 0
    for es, fs in sentencepairs:
        i += 1
        alignment = [0]*len(fs)
        for j in range(len(fs)):
            maxVal = 0
            choice = 0
            for aj in range(len(es)):
                val = t[es[aj]][fs[j]]
                  #*a(aj|j,m,l), which is uniform in model 1
                if val> maxVal:
                   maxVal = val
                   choice = aj
            alignment[j] = choice
            counts[es[choice]][fs[j]] += 1
            total[es[choice]] += 1

        f.write('Sentence pair ('+str(i)+
                ') source length '+str(len(fs))+
                ' target length '+ str(len(es)-1)+
                ' score ??' #??
                +'\n')
        f.write(str(alignment)+'\n')
        # print es,fs, alignment
    f.close()
    
    # Create the table of translation probabilities
    # from the Viterbi alignments:
    tV = defaultdict(lambda: defaultdict(int))
    for eWord, trans in counts.iteritems():
        for fWord, value in trans.iteritems():
            tV[eWord][fWord] = value/ total[eWord]
    return tV






def loadSentences(encorpus, forcorpus):
    fen = open(encorpus,'r')
    ffor = open(forcorpus,'r')
    pairs = []
    for engSentence, forSentence in itertools.izip(fen,ffor):
        #remove unnecessary characters
        #engSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', engSentence)
        #forSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', forSentence)

        engSentence = engSentence.split()
        engSentence.insert(0, 'NULL')
        forSentence = forSentence.split()

        langpair = (engSentence,forSentence)
        pairs.append(langpair)
    return pairs


def main():
    test = False

    if test:
       englishCorpus = "corpusmini.en"
       foreignCorpus = "corpusmini.nl"
       viterbi = "corpusmini_viterbi.txt"
       table = "corpusmini_table.txt"
    else:
       englishCorpus = "corpus_1000.en"
       foreignCorpus = "corpus_1000.nl"
       viterbi = "corpus_1000_viterbi.txt"
       table = "corpus_1000_table.txt"

    pairedSentences = loadSentences(englishCorpus,foreignCorpus)

    t = ibm1(pairedSentences)
    tV = viterbiAlignment(pairedSentences, t, viterbi)

    translationTable(t,tV, table)
#    printBest(t)
#    printBest(tV)

if __name__ == '__main__':
    main()







