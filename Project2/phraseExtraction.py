

def extractPairs(e,f,A):
    BP = set()
    for e_s in range(len(e)):
        for e_e in range(e_s,len(e)):
            f_s = len(f)
            f_e = 0
            for (e_a,f_a) in A:
                if e_s <= e_a and e_a <= e_e:
                    f_s = min(f_a, f_s)
                    f_e = max(f_a, f_e)
            BP = BP.union(extract(f_s,f_e,e_s,e_e,f,e))
    return BP

def extract(f_s,f_e,e_s,e_e,f,e):
    print 'extracting..',f_s,f_e,e_s,e_e
    E = set()
    fPrev = 0
    fNext = len(f)
    if f_e == 0:
        return E
    for (e_a,f_a) in A:
        print f_a,e_a
        #Inconsistent: outside of the english window
        #              but inside the foreign window
        if (e_a < e_s or e_a > e_e) and (f_a >= f_s and f_a <= f_e):
           print 'Not consistent'
           return E
        else:
           if f_a < f_s:
              fPrev = max(f_a,fPrev)
           if f_a > f_e:
              fNext = min(f_a,fNext)
    fs = f_s
    while fs > fPrev: #fs aligned
    #    print 'in a while'
        fe = f_e
        while fe < fNext: #fe aligned
   #         print 'extract a phrase'
            E.add((getPhrase(e_s,e_e,e),getPhrase(fs,fe,f)))
            fe +=1
        fs -= 1
    return E

def getPhrase(start,end,sentence):
    phrase = ""
    for i in range(start,end+1):
  #      print sentence[i]
        phrase+=sentence[i]+" "
 #   print sentence, start, end, phrase
    return phrase[0:-1]



# There seems to be a problem:
# To me, it appears like the foreign words are shifted one place to the left
A = [(0,0),(1,0),(1,1),(3,2),(2,3),(5,4),(6,5),(7,5),(6,6),(8,7),(9,8)]
e = ['finally',',','there','is','the','lack','of','transparency','.']
f = ['tot','slot','is','er','nog','het','gebrek','aan','transparantie','.']
BP = extractPairs(e,f,A)
print len(BP), BP