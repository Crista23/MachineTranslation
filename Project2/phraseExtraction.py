#class Phrasepair:
#      def __init__(self,englishPhrase,foreignPhrase):
#          self.enPhrase = englishPhrase
#          self.forPhrase = foreignPhrase
#          self.lexicalProb =
#             #Use the lexical translation probabilities
              # to determine the lexical weight 
              # for the phrase pair

# Extract phrases of maximum length size
# An open question: do we want phrases from length 1 or 2?

def extractPairs(e,f,A,size):
    BP = set()
    if size <1:
       size = len(e)
    # - Establish an English window e_s...e_e
    #   with max length = size
    for e_s in range(len(e)):
        for e_e in range(e_s,min(e_s+size,len(e))):
#        for e_e in range(e_s+1,min(e_s+size,len(e))): ,if we don't want phrases of length 1
            print 'English window:',e_s,e_e
            #Find a corresponding foreign window f_s...f_e
            # initialize f_s and f_e the extreme values
            f_s = len(f)
            f_e = 0
            # - Check for each alignment point
            #   whether is is in the English window
            # - Use the f-coordinate as f_s or f_e
            #   if it is smaller resp. larger
            #   than the value so far
            for (f_a,e_a) in A:
                if e_s <= e_a and e_a <= e_e:
                    f_s = min(f_a, f_s)
                    f_e = max(f_a, f_e)
            print 'Foreign window:', f_s,f_e
            # Extract the phrase pairs in this window
            # and add them to the set of phrase pairs
            BP = BP.union(extractHelper(f_s,f_e,e_s,e_e,f,e,size))
    return BP

def extractHelper(f_s, f_e, e_s, e_e, f, e, size):
    E = set()
    fPrev = -1
    fNext = len(f)
    
    # If the English window was empty on the French side,
    # return an empty set
    if f_e < f_s:
    # if f_e == 0, if we don't want phrases of length 1
        return E
        print 'not a sensible French window'


    for (f_a,e_a) in A:
        #Inconsistent: outside of the english window
        #              but inside the foreign window
        if (e_a < e_s or e_a > e_e) and (f_a >= f_s and f_a <= f_e):
           print 'Not consistent'
           return E
        else:
        # Keep track of the right/left most foreign word
        # before resp. after the foreign window
           if f_a < f_s:
              fPrev = max(f_a,fPrev)
           if f_a > f_e:
              fNext = min(f_a,fNext)
    print 'Consistent'
    fs = f_s
    
    # Widen the foreign window until you hit 
    # the previous/ next foreign alignment point: fPrev or fNext
    while fs > fPrev: # until fs aligned
        fe = f_e
        while fe < fNext: # until fe aligned
            # If the foreign window does not violate the size constraint
            # Extract the phrases and add them to the set
            if fe-fs < size:
                E.add((getPhrase(e_s,e_e,e),getPhrase(fs,fe,f)))
            fe +=1
        fs -= 1
    return E

def getPhrase(start,end,sentence):
# Extract the words in the window start ... end
# from the sentence and concatenate them in a string
    print 'getPhrase',start,end,sentence
    phrase = ""
    for i in range(start,end+1):
        phrase+=sentence[i]+" "
    return phrase[0:-1]


A = [(0,0),(1,0),(1,1),(3,2),(2,3),(5,4),(6,5),(7,5),(6,6),(8,7),(9,8)]
e = ['finally',',','there','is','the','lack','of','transparency','.']
f = ['tot','slot','is','er','nog','het','gebrek','aan','transparantie','.']
BP = extractPairs(e,f,A,4)
print len(BP)#, BP
for (english, foreign) in BP:
    print english, ' ==> ', foreign
