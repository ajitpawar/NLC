function logProb = lm_prob(sentence, LM, type, delta, vocabSize, N, N_r, count_bigrams, S)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;
  vocabSize = length(fieldnames(LM.uni));

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
  end
  if (isempty(type))
    delta = 0;
  elseif strcmp(type, 'smooth')
      
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta < 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  elseif ~strcmp(type, 'turing')
    disp( 'type must be either '''' or ''smooth'' or ''turing''' );
    return;
  end

  words = strsplit(' ', sentence);
  
  % Calculate log P(sentence) = P(w1|w0) x P(w2|w1) x ... x P(w_n|w_n-1)
  
  if ~strcmp(type, 'turing')

    logProb = 0;

    for w=2:length(words)
      
        first_word = words{w-1};
        second_word = words{w};

        count_first_word = 0;
        count_first_word_second_word = 0;

        if isfield(LM.bi, first_word)
            count_first_word = LM.uni.(first_word);
        end

        if isfield(LM.bi, first_word) && isfield(LM.bi.(first_word), second_word)
            count_first_word_second_word = LM.bi.(first_word).(second_word);
        end

        if count_first_word == 0 && (vocabSize == 0 || delta == 0)
            cond_prob = 0;
        else
            cond_prob = (count_first_word_second_word + delta) / (count_first_word + delta*vocabSize);
        end

        if cond_prob > 0
          logProb = logProb + log2(cond_prob);
        else
          logProb = -Inf;
          break
        end
      
    end

  else

    if nargin < 9
      [N, N_r, count_bigrams, S] = good_turing_init(LM);
    end

    logProb = good_turing(LM, words, N, N_r, count_bigrams, S);

  end
  
end



function logProb = good_turing(LM, words, N, N_r, count_bigrams, S)

    % N = number of training instances
    % r = frequency of N-gram
    % N_r = number of bins that have r training instances
    %
    % For C(w1...w_n) = r > 0:
    % P(w1 ... w_n) = r*/N
    % r* = (r+1)*S(r+1)/S(r)
    %
    % For r = 0:
    % P(w1 ... w_n) ~ N_1/(N_0*N)
    %
    % P(w_n|w_n-1) = P(w_n-1, w_n) / P(w_n-1)

    k = 100; % only use G-T when frequence is less than k.

    logProb = 0;

    for w=2:length(words)

      first_word = words{w-1};
      second_word = words{w};

      % Calculate P(first_word second_word)

      if isfield(LM.bi, first_word) && isfield(LM.bi.(first_word), second_word)
        r = LM.bi.(first_word).(second_word);
      else
        r = 0;
      end

      if r == 0
        prob_first_word_second_word = (N_r.get(1) / N) / (power(length(fieldnames(LM.uni)),2)-count_bigrams); 
      else
        r_star = (r+1) * polyval(S,r+1) / polyval(S,r);
        prob_first_word_second_word = r_star / N;
      end

      % Calculate P(first_word)
      if isfield(LM.uni, first_word)
        r = LM.uni.(first_word);
      else
        r = 0;
      end

      if r == 0
        prob_first_word =  N_r.get(1) / N;
      else
        r_star = (r+1) * polyval(S,r+1) / polyval(S,r);
        prob_first_word = r_star / N;
      end

      % Calculate P(second_word | first_word)
      if r < k
        if prob_first_word == 0
          prob = 0;
        else
          prob = prob_first_word_second_word / prob_first_word;
        end
      else
        % We calculate P(second_word | first_word) via MLE
        count_first_word = 0;
        count_first_word_second_word = 0;
        if isfield(LM.bi, first_word)
            count_first_word = LM.uni.(first_word);
        end
        if isfield(LM.bi, first_word) && isfield(LM.bi.(first_word), second_word)
            count_first_word_second_word = LM.bi.(first_word).(second_word);
        end
        if count_first_word == 0
            prob = 0;
        else
            prob = (count_first_word_second_word) / count_first_word;
        end
      end

      if prob > 0
        logProb = logProb + log2(prob);
      else
        logProb = -Inf;
        break
      end

    end

    

end


