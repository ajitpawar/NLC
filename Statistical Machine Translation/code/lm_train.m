function LM = lm_train(dataDir, language, fn_LM)
%
%  lm_train
% 
%  This function reads data from dataDir, computes unigram and bigram counts,
%  and writes the result to fn_LM
%
%  INPUTS:
%
%       dataDir     : (directory name) The top-level directory containing 
%                                      data from which to train or decode
%                                      e.g., '/u/cs401/A2_SMT/data/Toy'
%       language    : (string) either 'e' for English or 'f' for French
%       fn_LM       : (filename) the location to save the language model,
%                                once trained
%  OUTPUT:
%
%       LM          : (variable) a specialized language model structure  
%
%  The file fn_LM must contain the data structure called 'LM', 
%  which is a structure having two fields: 'uni' and 'bi', each of which holds
%  sub-structures which incorporate unigram or bigram COUNTS,
%
%       e.g., LM.uni.word = 5       % the word 'word' appears 5 times
%             LM.bi.word.bird = 2   % the bigram 'word bird' appears twice
% 
% Template (c) 2011 Frank Rudzicz

global CSC401_A2_DEFNS

LM = struct('uni', struct(), 'bi', struct());

SENTSTARTMARK = 'SENTSTART'; 
SENTENDMARK = 'SENTEND';

DD = dir( [ dataDir, filesep, '*', language] );

for iFile=1:length(DD)

  %disp(DD(iFile).name);
    
  lines = textread([dataDir, filesep, DD(iFile).name], '%s','delimiter','\n');

  for line=1:length(lines),
            
    % ----------------------------------------------------

    processedLine = preprocess(lines{line}, language);
    words = strsplit(' ', processedLine );
    
    % Count bi/unigrams
    for w=1:length(words)
        
        current_word = words{w};
        
        if ~isempty(current_word)
        
            if w > 1
               % Count bigram
               prev_word = words{w-1};
               if ~isempty(prev_word)
                    if isfield(LM.bi, prev_word) && isfield(LM.bi.(prev_word), current_word)
                        LM.bi.(prev_word).(current_word) = LM.bi.(prev_word).(current_word) + 1;
                    elseif isfield(LM.bi, prev_word)
                        LM.bi.(prev_word).(current_word) = 1;
                    else
                        LM.bi.(prev_word) = struct();
                        LM.bi.(prev_word).(current_word) = 1;
                    end
               end
            end
            
            % Count unigram
            if isfield(LM.uni, current_word)
                LM.uni.(current_word) = LM.uni.(current_word) + 1;
            else
                LM.uni.(current_word) = 1;
            end
        
        end
        
        
    end
        
    % ----------------------------------------------------
    
  end
end

save( fn_LM, 'LM', '-mat'); 