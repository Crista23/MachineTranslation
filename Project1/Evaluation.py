from __future__ import division
import ast, nltk, collections

def determineAlignment(foreignSentence, englishSentence):
    alignments = []
    foreignWords = foreignSentence.split(" ")
    #print "foreign words"
    #print foreignWords
    englishWords =  englishSentence.replace("({ ", "").split(" }) ")
    #print "english words"
    #print englishWords
    for i in range(len(foreignWords)):
        index = i + 1
        for j in range(len(englishWords)):
            lookUpWordIndex = str(index)
            engValues = englishWords[j].split(" ")
            if (lookUpWordIndex in engValues):
                #print foreignWords[i] + " found in " + engValues[0]
                alignments.append(j)
    #print "alignments"
    #print alignments
    return alignments

def getGoldStandardAlignments(goldStandard):
    goldAlignments = []
    
    alignmentInfo = ""
    foreignSentence = ""
    englishSentence = ""
    
    i=0
    for line in goldStandard:
        line = line.replace("\n", "")
        if line.startswith("#"):
            alignmentInfo = line
        elif line.startswith("NULL"):
            englishSentence = line
        else:
            foreignSentence = line
        i += 1
        if(i % 3 == 0):
            #print "alignInfo: " + alignmentInfo
            #print "foreignSentence: " + foreignSentence
            #print "englishSentence: " + englishSentence

            goldAlignment = determineAlignment(foreignSentence, englishSentence)
            goldAlignments.append(goldAlignment)
            #print "gold alignments"
            #print goldAlignments
            
            alignmentInfo = ""
            foreignSentence = ""
            englishSentence = ""
        #if i > 2:
        #    break
    return goldAlignments

def getViterbiAlignments(viterbiStandard):
    viterbiAlignments = []
    i = 1
    for line in viterbiStandard:
        if(i%2 == 0):
            alignment = line.replace("\n", "")
            alignment = ast.literal_eval(alignment)
            #print '|' + alignment + '|'
            #print "alignment"
            #print alignment
            #print "list alignment"
            #print list(alignment)
            viterbiAlignments.append(alignment)
            #print "viterbi"
            #print viterbiAlignments
        i += 1
    return viterbiAlignments
    
def main():
    goldStandard = open("corpus_1000_gold", 'r')
    viterbiStandard = open("corpus_1000_viterbi.txt", 'r')

    goldStandardAlignments = getGoldStandardAlignments(goldStandard)
    viterbiAlignments = getViterbiAlignments(viterbiStandard)
    #print len(goldStandardAlignments)
    #print len(viterbiAlignments)

    
    
    if(len(goldStandardAlignments) == len(viterbiAlignments)):
        for i in range(len(goldStandardAlignments)):
            print i
            print nltk.metrics.precision(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
            print nltk.metrics.recall(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
                    
if __name__ == '__main__':
    main()
    
