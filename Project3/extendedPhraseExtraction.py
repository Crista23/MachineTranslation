import sys

def main():
# $ELINE $FLINES $ALLINES $OUTPUT
#    print str(sys.argv)
    size = 7
    eline = sys.argv[1].strip().split()
    print "eline is "+str(eline)
    flines = sys.argv[2].strip().split('@@')
#    print "flines is "+str(flines)
    flines = [fline.split() for fline in flines]
    allines = sys.argv[3].strip().split(',')
#    print "allines is "+str(allines)
    output = sys.argv[4]
#    print "output is "+output
    print "Going to extract phrases"
#    print eline, flines, allines
    extractPhrases(eline, flines, allines, size, output)


def getForeignWindow(e_s,e_e, A):
    #initialize f_s and f_e the extreme values
    f_s = len(A)
    f_e = 0
    # Loop over the relevant part of the alignment matrix to find positive cells
    # Use the f-coordinate as f_s or f_e if it is smaller/ larger than the value so far
    for i in range(e_s, e_e):
        for j in range(len(A)):
            if A[j][i] != 0:
                f_s = min(j, f_s)
                f_e = max(j, f_e)
    if f_e >= f_s:
       # Check for consistency of the window pair:
       for j in range(f_s, f_e):
           for i in range(len(A[0])):
               if A[j][i]!=0 and (i<e_s or i>e_e):
               #Inconsistent: an alignment point outside of the english window
               #              but inside the foreign window
                   f_s = 0
                   f_e = -1
    return f_s,f_e

def extractPhrases(eLine, fLines, alLines, size, phraseTable):
    e = eLine
    f = fLines[0]
    if size <1:
       size = len(e)
    n = 0

    el = len(e)
    alignments = []
    for i in range(len(fLines)): #iterate over the foreign languages and create alignment matrices
        print fLines[i]
        fl = len(fLines[i])
        alignments.append(getAlignmentMatrix(alLines[i],el,fl))
    A = alignments[0]


    # Establish an English window e_s...e_e with max length = size
    # Find a corresponding foreign window f_s...f_e;
    for e_s in range(len(e)):
        for e_e in range(e_s,min(e_s+size,len(e))):
            if windowOK(e_s, e_e, alignments): # check whether the english window is sensible
               f_s,f_e = getForeignWindow(e_s,e_e,A)
               # If the English window is empty on the French side, do nothing
               if f_e < f_s:
                  return

               fPrev = -1
               fNext = len(f)
               #find borders fPrev and fNext
               fs = f_s
               # Widen the foreign window
               # until you hit the previous/ next foreign alignment point: fPrev or fNext
               while fs > fPrev:
                   fe = f_e
                   while fe < fNext:
                   # If the foreign window does not violate the size constraint:
                   # Extract the phrases and update the dictionary
                       if fe-fs < size:
                           engPhrase = getPhrase(e_s, e_e, e)
                           forPhrase = getPhrase(fs, fe, f)

                           alignment = ""
                           for i in range(fs, fe):
                               for j in range(e_s,e_e):
                                   if A[j][i] != 0:
                                      alignment += ' '+str(i)+'-'+str(j)
                           #write to the phrase table (append)
                           with open(phraseTable, "a") as myfile:
                               print "Extracted a phrase pair"
                               myfile.write(engPhrase+ ' ||| '+forPhrase+' |||'+alignment+'\n')
                               # phrase table file format:
                               #<source phrase> ||| <target phrase> ||| <alignment points>
                       fe +=1
                   fs -= 1

def getPhrase(start,end,sentence):
    phrase = ""
    for i in range(start,end+1):
        phrase+=sentence[i]+" "
    return phrase[0:-1]  # Omit the last space (" ")


def windowOK(e_s, e_e, alignments):
    ok = True
    for al in alignments: #iterate over the other foreign languages
        f_s,f_e = getForeignWindow(e_s,e_e,al)
        # If the English window is empty on the French side, window is not OK
        if f_e < f_s:
           ok = False
           break
    return ok

def getAlignmentMatrix(alLine, el, fl):
    print "get matrix for "+alLine
    print "el is",el, "fl is", fl

    points = alLine.split()
    alignment = [[0 for col in range(el)] for row in range(fl)]
    for point in points:
	print "point is "+point
        e_pos, f_pos = point.split("-")
	f_pos = int(f_pos)
	e_pos = int(e_pos)
        alignment[f_pos][e_pos] = 1
    return alignment


if __name__ == "__main__":
    main()
