from collections import defaultdict
"""
Extract phrase pairs from a sentence pair
Param:  e          - the english sentence (a list of words)
        f          - the foreign sentence (a list of words)
        A          - the alignments (a list of alignment points (e,f))
        size       - the maximum phrase length (int, -1 for no limit)
        engPhrases - a dictionary of dictionaries of ints (counts)
Return: engPhrases - the updated dictionary
        n          - the total number of phrase pairs encountered (sum of counts)
"""
def extractPairs(e,f,A,size, engPhrases):
    n=0
    if size <1:
       size = len(e)
    # Establish an English window e_s...e_e with max length = size
    # Find a corresponding foreign window f_s...f_e;
    for e_s in range(len(e)):
        for e_e in range(e_s,min(e_s+size,len(e))):
            #initialize f_s and f_e the extreme values
            f_s = len(f)
            f_e = 0
            # Check for each alignment point whether is is in the English window
            # Use the f-coordinate as f_s or f_e if it is smaller/ larger than the value so far
            for (f_a,e_a) in A:
                if e_s <= e_a and e_a <= e_e:
                    f_s = min(f_a, f_s)
                    f_e = max(f_a, f_e)
            # Extract the phrase pairs in this window and update the dictionary and count
            engPhrasees, count = extractHelper(e_s, e_e, f_s, f_e, e, f, size, A, engPhrases)
            n += count
    return engPhrases,n

"""
Extract phrase pairs for a given pair of windows in sentences:
check for consistency, extend the foreign window as much as possible and extract the phrases
Param:  e_s        - the left index of the engish window
        e_e        - the right index of the engish window
        f_s        - the left index of the foreign window
        f_e        - the right index of the foreign window
        f          - the foreign sentence (a list of words)
        e          - the english sentence (a list of words)
        A          - the alignments (a list of alignment points (e,f))
        size       - the maximum phrase length (int, -1 for no limit)
        engPhrases - the dictionary to updates
Return: engPhrases - the updated dictionaries
        count      - the number of phrases encountered
"""
def extractHelper(e_s, e_e, f_s, f_e, e, f, size, A, engPhrases):
    count = 0
    # keep track of the limits:
    # the first foreign word left and right of the window
    # initialize the limits to the extreme values
    fPrev = -1
    fNext = len(f)

    # If the English window was empty on the French side, do nothing
    if f_e < f_s:
        return engPhrases, count

    # Check for consistency of the window pair:
    for (f_a,e_a) in A:
        #Inconsistent: an alignment point outside of the english window
        #              but inside the foreign window
        if (e_a < e_s or e_a > e_e) and (f_a >= f_s and f_a <= f_e):
            return engPhrases, count

        else: # update the limits
           if f_a < f_s:
              fPrev = max(f_a,fPrev)
           if f_a > f_e:
              fNext = min(f_a,fNext)

    fs = f_s
    # Widen the foreign window
    # until you hit the previous/ next foreign alignment point: fPrev or fNext
    while fs > fPrev:
        fe = f_e
        while fe < fNext:
            # If the foreign window does not violate the size constraint:
            # Extract the phrases and update the dictionary
            if fe-fs < size:
                engPhrases[getPhrase(e_s, e_e, e)][getPhrase(fs,fe,f)] += 1
                count += 1
            fe +=1
        fs -= 1
    return engPhrases, count

"""
Extract a phrase from a sentence
Param:  start      - the left border of the window
        end        - the right border of the window
        sentence   - the sentence (list of words) to extract from
Return: phrase     - the extracted phrase - a string
"""
def getPhrase(start,end,sentence):
    phrase = ""
    for i in range(start,end+1):
        phrase+=sentence[i]+" "
    return phrase[0:-1]  # Omit the last space (" ")
