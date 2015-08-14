
function evalPerplexity(LME, LMF)

	global CSC401_A2_DEFNS

    testDir = CSC401_A2_DEFNS.TEST_DIR;
    deltas = [0, 0.25, 0.5, 0.75, 1.0];

    for d=1:length(deltas)
        disp(['LME smooth perplexity: ', 'delta=', num2str(deltas(d)), ', ', num2str(perplexity(LME, testDir, 'e', 'smooth', deltas(d)))]);
        disp(['LMF smooth perplexity: ', 'delta=', num2str(deltas(d)), ', ', num2str(perplexity(LMF, testDir, 'f', 'smooth', deltas(d)))]);
    end

    disp(['LME GT perplexity: ', num2str(perplexity(LME, testDir, 'e', 'turing', 0))]);
    disp(['LMF GT perplexity: ', num2str(perplexity(LMF, testDir, 'f', 'turing', 0))]);


end