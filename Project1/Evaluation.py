from __future__ import division
import ast, nltk, collections

def determineAlignment(foreignSentence, englishSentence):
    alignments = []
    foreignWords = foreignSentence.split(" ")
    englishWords =  englishSentence.replace("({ ", "").split(" }) ")
    englishWords = [word for word in englishWords if word != '']
    #print "engWords"
    #print englishWords
    for i in range(len(foreignWords)):
        index = i + 1
        for j in range(len(englishWords)):
            lookUpWordIndex = str(index)
            engValues = englishWords[j].split(" ")
            if (lookUpWordIndex in engValues):
                alignments.append(j)
    return alignments, len(englishWords)-1

def getGoldStandardAlignments(goldStandard):
    goldAlignments = []
    englishSentencesLength = []

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
            goldAlignment, noEngWords = determineAlignment(foreignSentence, englishSentence)
            goldAlignments.append(goldAlignment)

            englishSentencesLength.append(noEngWords)

            alignmentInfo = ""
            foreignSentence = ""
            englishSentence = ""

    f = open("EngSentencesLength.txt", "w")
    for engLength in englishSentencesLength:
        f.write(str(engLength) + ",")
    f.close()

    return goldAlignments

def getViterbiAlignments(viterbiStandard):
    viterbiAlignments = []
    i = 1
    for line in viterbiStandard:
        if(i%2 == 0):
            alignment = line.replace("\n", "")
            alignment = ast.literal_eval(alignment)
            viterbiAlignments.append(alignment)
        i += 1
    return viterbiAlignments

def main():
    goldStandard = open("corpus_1000_gold", 'r')
    viterbiStandard = open("corpus_1000_viterbi_improv.txt", 'r')
    f1scores = "F1scores_improv.txt"


    goldStandardAlignments = getGoldStandardAlignments(goldStandard)
    viterbiAlignments = getViterbiAlignments(viterbiStandard)

    if(len(goldStandardAlignments) == len(viterbiAlignments)):
        precisionValues = []
        recallValues = []
        F1Scores= []
        for i in range(len(goldStandardAlignments)):
            #print i
            #print nltk.metrics.precision(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
            #print nltk.metrics.recall(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
            #print nltk.metrics.f_measure(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
            precision = nltk.metrics.precision(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
            recall = nltk.metrics.recall(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
            F1score = nltk.metrics.f_measure(set(goldStandardAlignments[i]), set(viterbiAlignments[i]))
            precisionValues.append(precision)
            recallValues.append(recall)
            F1Scores.append(F1score)

        # final values
        precisionValue = sum(precisionValues)/len(precisionValues)
        recallValue = sum(recallValues)/len(precisionValues)
        f1Value = sum(F1Scores)/len(precisionValues)
        print "Precision: " + str(precisionValue)
        print "Recall: " + str(recallValue)
        print "F1: " + str(f1Value)
        f = open(f1scores, "w")
        for f1score in F1Scores:
            f.write(str(f1score) + ",")
        f.close()


if __name__ == '__main__':
    main()

