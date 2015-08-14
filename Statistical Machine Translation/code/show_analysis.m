
% Analysis.

function show_analysis(english_sentences, test_sentences)

    total_sentences = length(english_sentences);

    total_prop = 0;
    for i=1:total_sentences
        correct_words = strsplit(' ', english_sentences{i} );
        test_words = strsplit(' ', test_sentences{i} );
        correct = 0;
        for w=1:min(length(test_words),length(correct_words))
            if strcmp(test_words{w}, correct_words{w})
                correct = correct + 1;
            end
        end
        proportion_correct = correct / length(correct_words);
        disp(['Correct for sentence ', num2str(i), ': ', num2str(proportion_correct)]);
        total_prop = total_prop + proportion_correct;
    end

    average = total_prop / total_sentences;
    disp(['Average proportion correct: ', num2str(average)]);

end
