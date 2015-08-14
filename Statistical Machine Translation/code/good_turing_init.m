
% Call this function before calling good_turing
% This function requires a lot of computation and should
% only be called once for a sequence of good_turing calls.

function [N, N_r, count_bigrams, S] = good_turing_init(LM)

    % Calculate N and Calculate N_r - the number of bins with freq r.
    N = 0;
    N_r = java.util.Hashtable;
    N_r.put(0,0); % Make sure these fields exist
    N_r.put(1,0);
    count_bigrams = 0;

    f = fieldnames(LM.uni);
    for i=1:length(f)
        word = f{i};
        r = LM.uni.(word);
        N = N + r;
        if ~N_r.containsKey(r)
          N_r.put(r,1);
        else
          N_r.put(r, N_r.get(r)+1);
        end
        if isfield(LM.bi, word)
          count_bigrams = count_bigrams + length(fieldnames(LM.bi.(word)));
        end
    end

    % Find a smoothing curve of the form S(r) = N_r = a*r^b where b < -1
    % estimated by log(N_r) = a + b log(r)

    % We have everything we need in N_r.
    X = [];
    Y = [];

    N_r_freqs = N_r.keySet().toArray();
    for i=1:length(N_r_freqs)
      r = N_r_freqs(i);
      Nr = N_r.get(r);
      if Nr > 0
        X(i) = r;
        Y(i) = log2(Nr);
      end
    end

    S = polyfit(X, Y, 1);

end
