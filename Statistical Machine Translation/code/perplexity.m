function pp = perplexity( LM, testDir, language, smooth_type, delta )
%
%  perplexity
% 
%  This function computes the perplexity of language model given a test corpus 
%
%  INPUTS:
%
%       LM        : (variable) the language model previously trained by lm_train
%       testDir   : (directory name) The top-level directory containing 
%                   data from which to compute perplexity
%                   e.g., '/u/cs401/A2_SMT/data/Hansard/Testing/'
%       language  : (string) either 'e' for English or 'f' for French
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%
% 
% Template (c) 2011 Frank Rudzicz

global CSC401_A2_DEFNS

DD        = dir( [ testDir, filesep, '*', language] );
pp        = 0;
N         = 0;
vocabSize = length(fields(LM.uni));

if strcmp(smooth_type,'turing')
  [N, N_r, count_bigrams, S] = good_turing_init(LM);
end

for iFile=1:length(DD)

  lines = textread([testDir, filesep, DD(iFile).name], '%s','delimiter','\n');

  for l=1:length(lines)

    processedLine = preprocess(lines{l}, language);

    if strcmp(smooth_type,'turing')    
      tpp = lm_prob( processedLine, LM, smooth_type, 0, 0, N, N_r, count_bigrams, S);
    else
      tpp = lm_prob( processedLine, LM, smooth_type, delta, vocabSize, 0, 0, 0, 0);
    end
    
    if (tpp > -Inf)   % only consider sentences that have some probability 
      pp = pp + tpp;
      words = strsplit(' ', processedLine);
      N = N + length(words);
    end
  end
end

pp = 2^(-pp/N);
return