
function evalAlign(LME, LMF)

    global CSC401_A2_DEFNS

    if ~exist('LME') || ~exist('LMF')
        disp('Computing LME and LMF...');
        [LME, LMF] = evalStart();
        disp('Done.')
    end

    vocabSizeEng = length(fieldnames(LME.uni));    
    
    % Get the sentences to be used for evaluation
    english_sentences = textread([CSC401_A2_DEFNS.TEST_DIR, filesep, 'Task5.e'], '%s','delimiter','\n');
    french_sentences = textread([CSC401_A2_DEFNS.TEST_DIR, filesep, 'Task5.f'], '%s','delimiter','\n');

    numSentences = [1000, 10000, 15000, 30000];
    deltas = [0, 0.1, 0.25, 0.5, 0.75, 1.0];

    for n=1:length(numSentences)
        AM = align_ibm1( CSC401_A2_DEFNS.TRAIN_DIR, numSentences(n), 20, strcat('AMFE_',num2str(numSentences(n)),'.mat') );
        for d=1:length(deltas)
            delta = deltas(d);

            disp(['ANALYSIS - ' num2str(numSentences(n)) ' SENTENCES AND DELTA=',num2str(delta)]);

            
            test_english_sentences = cell(length(english_sentences));

            for f=1:length(french_sentences)
                french_sentence = preprocess(french_sentences{f}, 'f');
                test_english_sentences{f} = decode2( french_sentence, LME, AM, 'smooth', delta, vocabSizeEng );
            end

            show_analysis(english_sentences, test_english_sentences);

            disp('----------------------------------------------');

        end
    end
end

