import * from phraseExtraction

main():
    enFile = "data/training/p2_training.en"
    forFile = "data/training/p2_training.nl"
    alignFile = "data/training/p2_training_symal.nlen"
    enSen, forSen, alignments = readFiles(enFile,forFile,alignFile)
    

    
    
if __name__ == '__main__':
    main()