from collections import defaultdict

"""
Create a decoding dictionary from the phrase extraction dictionary
Param:  engPhrases - a dictionary of dictionaries of ints (counts)
        n          - the total number of phrase pairs encountered (sum of counts)
Return: fPhrases   - a dictionary of dictionaries of floats
"""
def getDecodingDict(engPhrases, n):
    fPhrases = defaultdict(dict)
    for engPhrase, forDict in engPhrases.iteritems():
        engCount = sum(engPhrase.itervalues())
        for fPhrase, count in forDict.iteritems():
            conditional = count / engCount
            joint = count / n
            fPhrases[fPhrase][engPhrase] = (conditional, joint)
    return fPhrases


