from __future__ import division
from collections import defaultdict
import copy, itertools, operator, re
 

def ExpectationMaximization(sentencePairs):
    """ Zip function
    -if I have a list a = [(["a", "b", "c"], ["d","e","f"]), (["g","h","i"], ["j","k","l"])]
    calling s,t = zip(*a)
    results in s = (['a', 'b', 'c'], ['g', 'h', 'i'])
            and t = (['d', 'e', 'f'], ['j', 'k', 'l'])
    """
    # foreign sentences: (['mi', 'casa', 'verde'], ['casa', 'verde'], ['la', 'casa'])
    # english sentences: (['my', 'green', 'house'], ['green', 'house'], ['the', 'house'])
    foreignSentences, englishSentences = zip(*sentencePairs)
    # determine the set of words used by a language: foreignVocabulary - set(['casa', 'verde', 'mi', 'la']),
    #                                                englishVocabulary - set(['green', 'the', 'my', 'house'])
    foreignVocabulary = set(itertools.chain.from_iterable(foreignSentences))
    englishVocabulary = set(itertools.chain.from_iterable(englishSentences))
    
    translationProbsPreviousStep = None
    translationProbs = {}
    
    # Step 1 - Assume uniform initial probabilities t(e|f)
    uniformProb = 1.0 / len(foreignVocabulary)
    for foreignWord in foreignVocabulary:
        for englishWord in englishVocabulary:
            translationProbs[(foreignWord, englishWord)] = uniformProb
    
    # compute the list of all possible alignments
    alignments = []
    for foreign, english in sentencePairs:
        """
        if we have a list a = ['a','b','c'],
        itertools.permutations(a) returns all possible combinations: ('a', 'b', 'c'), ('a', 'c', 'b'), ('b', 'a', 'c'), ('b', 'c', 'a'), ('c', 'a', 'b'), ('c', 'b', 'a')
        """
        englishPermutations = itertools.permutations(english)
        for englishPermutation in englishPermutations:
            """
            x = [1, 2, 3]
            y = [4, 5, 6]
            zipped = zip(x, y) => [(1, 4), (2, 5), (3, 6)]
            """
            alignment = zip(foreign, englishPermutation)
            alignments.append(alignment)
    alignments = [alignments]
 
    # Repeat until convergence
    while translationProbsPreviousStep != translationProbs:
        # update previous translation probabilities, set them to the current values
        translationProbsPreviousStep = copy.copy(translationProbs)
        
        """
        print "alignments are"
        print alignments
        
        Alignment example: #alignments
        [[[('casa', 'green'), ('verde', 'house')], [('casa', 'house'), ('verde', 'green')], [('la', 'the'), ('casa', 'house')], [('la', 'house'), ('casa', 'the')]]]

        {(('la', 'the'), ('casa', 'house')): 0.1111111111111111, (('casa', 'house'), ('verde', 'green')): 0.1111111111111111, (('casa', 'green'),
            ('verde', 'house')): 0.1111111111111111, (('la', 'house'), ('casa', 'the')): 0.1111111111111111}
        """
        
        alignmentProbabilities = {}
        for alignmentList in alignments:
            for pairedAlignment in alignmentList:
                #print pairedAlignment
                alignProb = 1
                for pair in pairedAlignment:
                    alignProb = alignProb * translationProbs[pair]
                #print "score: " + str(alignProb)
                alignmentProbabilities[tuple(pairedAlignment)] = alignProb

        # Normalize alignment probabilities
        NormalizeWithTotal = sum(alignmentProbabilities.values())
        normalizedProbabilities = {}
        for sentenceAlignment, value in alignmentProbabilities.iteritems():
            normalizedProbabilities[sentenceAlignment] = value / NormalizeWithTotal
        alignmentProbabilities = normalizedProbabilities

        # Maximization Step
        # Compute the weighted translation counts
        weightedTranslations = defaultdict(lambda: defaultdict(float))
        for wordPairs, prob in alignmentProbabilities.iteritems():
            for foreignWord, englishWord in wordPairs:
                weightedTranslations[englishWord][foreignWord] += prob
        """
        print "weighted translations"
        print weightedTranslations
        defaultdict(<function <lambda> at 0x02975630>, {'house': defaultdict(<type 'float'>, {'verde': 0.0, 'casa': 1.0, 'la': 0.0}),
        'the': defaultdict(<type 'float'>, {'casa': 0.0, 'la': 0.5}), 'green': defaultdict(<type 'float'>, {'verde': 0.5, 'casa': 0.0})})
        """
        
        #Normalize rows to estimate P(f|e)
        translationProbs = {}
        for englishWord, translations in weightedTranslations.iteritems():
            NormalizeWithTotal = sum(translations.values())
            for foreignWord, score in translations.iteritems():
                translationProbs[foreignWord, englishWord] = score / NormalizeWithTotal

        """
        print "translation probs"
        print translationProbs
        translation probs {('verde', 'house'): 0.0, ('casa', 'house'): 1.0, ('la', 'the'): 1.0, ('casa', 'the'): 0.0,
                            ('casa', 'green'): 0.0, ('verde', 'green'): 1.0, ('la', 'house'): 0.0}
        """
    return translationProbs

def loadSentences(encorpus, nlcorpus):
    fen = open(encorpus,'r')
    fnl = open(nlcorpus,'r')
    pairs = []
    for engSentence, nlSentence in itertools.izip(fen,fnl):
        #remove unnecessary characters
        engSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', engSentence)
        nlSentence = re.sub('["#$%&()?!*+,./:;<=>\^{}~]', '', nlSentence)
        langpair = (engSentence.split(), nlSentence.split())
        pairs.append(langpair)
    return pairs

def main(): 
    
    pairedSentences = [('mi casa verde'.split(), 'my green house'.split()),
                        ('casa verde'.split(), 'green house'.split()),
                        ('la casa'.split(), 'the house'.split())]
    
    """
    EnglishCorpus = "corpus.en"
    ForeignCorpus = "corpus.nl"
    # pairedSentences looks like: [(['mi', 'casa', 'verde'], ['my', 'green', 'house']), (['casa', 'verde'], ['green', 'house']), (['la', 'casa'], ['the', 'house'])]
    pairedSentences = loadSentences(ForeignCorpus, EnglishCorpus)
    """
    
    print ExpectationMaximization(pairedSentences)
 
 
if __name__ == '__main__':
    main()
