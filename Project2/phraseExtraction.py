from __future__ import division
from collections import defaultdict

# Extract phrases of maximum length size
# An open question: do we want phrases from length 1 or 2?
def extractPairs(e,f,A,size):
    BP = set()
    if size <1:
       size = len(e)
    # - Establish an English window e_s...e_e with max length = size
    for e_s in range(len(e)):
        for e_e in range(e_s,min(e_s+size,len(e))):
        #for e_e in range(e_s+1,min(e_s+size,len(e))): ,if we don't want phrases of length 1
            #Find a corresponding foreign window f_s...f_e; initialize f_s and f_e the extreme values
            f_s = len(f)
            f_e = 0
            # - Check for each alignment point whether is is in the English window
            # - Use the f-coordinate as f_s or f_e if it is smaller resp. larger than the value so far
            for (f_a,e_a) in A:
                if e_s <= e_a and e_a <= e_e:
                    f_s = min(f_a, f_s)
                    f_e = max(f_a, f_e)
            # print 'Foreign window:', f_s,f_e
            # Extract the phrase pairs in this window and add them to the set of phrase pairs
            # BP = BP.union(extractHelper(f_s,f_e,e_s,e_e,f,e,size, A))
            extractHelper(f_s,f_e,e_s,e_e,f,e,size, A)
#    return BP

# Given the English and foreign window, check for consistency, 
# extend the foreign window as much as possible and extract the phrases
def extractHelper(f_s, f_e, e_s, e_e, f, e, size, A):
    #E = set()
    global BP
    fPrev = -1
    fNext = len(f)
    
    # If the English window was empty on the French side, return an empty set
    if f_e < f_s:
    # if f_e == 0, if we don't want phrases of length 1
        return #E
        # print 'not a sensible French window'

    for (f_a,e_a) in A:
        #Inconsistent: outside of the english window
        #              but inside the foreign window
        if (e_a < e_s or e_a > e_e) and (f_a >= f_s and f_a <= f_e):
            return #E
            # print 'Not consistent'
        else:
        # Keep track of the right/left most foreign word before resp. after the foreign window
           if f_a < f_s:
              fPrev = max(f_a,fPrev)
           if f_a > f_e:
              fNext = min(f_a,fNext)
    # print 'Consistent'
    fs = f_s

    # Widen the foreign window until you hit the previous/ next foreign alignment point: fPrev or fNext
    while fs > fPrev: # until fs aligned
        fe = f_e
        while fe < fNext: # until fe aligned
            # If the foreign window does not violate the size constraint
            # Extract the phrases and add them to the set
            if fe-fs < size:
                #E.add((getPhrase(e_s,e_e,e),getPhrase(fs,fe,f)))
                BP[(getPhrase(e_s,e_e,e),getPhrase(fs,fe,f))] += 1
            fe +=1
        fs -= 1
    return #E

def getPhrase(start,end,sentence):
# Extract the words in the window start ... end
# from the sentence and concatenate them in a string
#    print 'getPhrase',start,end,sentence
    phrase = ""
    for i in range(start,end+1):
        phrase+=sentence[i]+" "
    return phrase[0:-1]

# sentence looks like 0-0 1-0 1-1 3-2 2-3 5-4 6-5 7-5 6-6 8-7 9-8
def getWordAlignments(sentence):
    A = set()
    sentence = sentence.split(" ")
    for alignment in sentence:
        e_pos, f_pos = alignment.split("-")
        A.add((int(e_pos), int(f_pos)))
    return list(A)

def readFiles(enFile,forFile,alignFile):
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
        return enSen, forSen, alignments

BP = defaultdict(int)

def getConditionalTranslationProbabilities(BP, phrasePair):
    engPhrase = phrasePair[0]
    forPhrase = phrasePair[1]
    phrasePairCount = 0
    sumEngPhraseOccurences = 0
    for (english, foreign), count in BP.iteritems():
        if (english == engPhrase):
            if (foreign == forPhrase):
                phrasePairCount = count
            sumEngPhraseOccurences += count
    
    if(sumEngPhraseOccurences != 0):
        return phrasePairCount / sumEngPhraseOccurences
    return 0     

def main():
    enFile = "data/training/p2_training.en"
    forFile = "data/training/p2_training.nl"
    alignFile = "data/training/p2_training_symal.nlen"
    enSen, forSen, alignments = readFiles(enFile,forFile,alignFile)
    
#    BP = set()

    for i in range(20):
#    for i in range(len(enSen)):
#        BP = BP.union(extractPairs(enSen[i],forSen[i],alignments[i],4))
        extractPairs(enSen[i],forSen[i],alignments[i],4)
 #        A = getWordAlignments(falignments[i])
#         e = fen[i].replace("\n", "").split(" ")
#         f = ffor[i].replace("\n", "").split(" ")
#         BP = extractPairs(e,f,A,4)
        print len(BP)#, BP
        
        #might be too many prints, so for now stop after the first iteration
     #   break
    for (english, foreign),count in BP.iteritems():
        print english, ' ==> ', foreign,'\t\t|| ', count
        print "conditional probability: " + str(getConditionalTranslationProbabilities(BP, (english, foreign)))

    """
    A = [(0,0),(1,0),(1,1),(3,2),(2,3),(5,4),(6,5),(7,5),(6,6),(8,7),(9,8)]
    e = ['finally',',','there','is','the','lack','of','transparency','.']
    f = ['tot','slot','is','er','nog','het','gebrek','aan','transparantie','.']
    BP = extractPairs(e,f,A,4)
    print len(BP)#, BP
    for (english, foreign) in BP:
        print english, ' ==> ', foreign
    """

if __name__ == '__main__':
    main()
