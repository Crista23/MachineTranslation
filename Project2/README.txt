1) The command used for building a phrased based SMT system using the Moses installation on deze:
        /apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl 
		-external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile 
		-mgiza -mgiza-cpus 4 
		--f nl --e en 
		--lm 0:3:/home/bart/project2_data/lm/europarl-v7.nl-en.train.blm.en:8  
		--corpus /home/ggarbacea/SSLP/Project2/training/p2_training 
		-alignment grow-diag-final-and 
		-reordering msd-bidirectional-fe 
		-root-dir /home/ggarbacea/SSLP/MosesResults

2) The command used for traslation of the Dutch test set to English:
		nohup /apps/smt_tools/decoders/mosesdecoder/bin/moses 
		-f /home/ggarbacea/SSLP/MosesResults/model/moses.ini 
		< /home/bart/project2_data/test/p2_test.nl 
		> /home/ggarbacea/SSLP/TranslationResults/translatedtestNLtoENG.en 
		2>/home/ggarbacea/SSLP/TranslationResults/translation.out

3) The command used for computing the BLEU score:
		/apps/smt_tools/decoders/mosesdecoder/scripts/generic/multi-bleu.perl 
		/home/bart/project2_data/test/p2_test.en 
		< /home/ggarbacea/SSLP/TranslationResults/translatedtestNLtoENG.en


Reference: http://www.statmt.org/moses/?n=moses.baseline