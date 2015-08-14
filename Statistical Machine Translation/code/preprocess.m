function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % initialize outSentence
  outSentence = inSentence;
  
  % perform language-agnostic changes
  outSentence = regexprep( outSentence, '([\.\?!`"\*,\:;\(\)\[\]/\-\+\<>\=\.\?\!\\$\%\&])', ' $1 ' );
  
  % separate dashes in mathematical expression
  outSentence = regexprep( outSentence, '(\d)\s*(\-)\s*(\d)', '$1 $2 $3' );
  % separate dashes between parentheses
  % inParentheses = false;
  % new_outSentence = '';
  % for i=1:length(outSentence)
  %   c = outSentence(i);
  %   if strcmp(c,'(') || strcmp(c,'[')
  %     inParentheses = true;
  %   end
  %   if inParentheses && strcmp(c,'-')
  %     c = ' - ';
  %   end
  %   if strcmp(c,')') || strcmp(c,']')
  %     inParentheses = false;
  %   end
  %   new_outSentence = [new_outSentence, c];
  % end
  % outSentence = new_outSentence;
  
  switch language
   case 'e'
    outSentence = regexprep( outSentence, '([a-z])('')(ve|m|s|d|ll|re) ', '$1 $2$3 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z])(n''t) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]s)('') ', '$1 $2 ', 'ignorecase' );
   case 'f'
    outSentence = regexprep( outSentence, ' ([ljt]'')([a-z])', ' $1 $2', 'ignorecase' );
    outSentence = regexprep( outSentence, '(qu'')([a-z])', '$1 $2', 'ignorecase' );

  end
  
  % trim whitespaces
  outSentence = regexprep( outSentence, '\s+', ' ');
  outSentence = regexprep( outSentence, '\s$', '');
  outSentence = regexprep( outSentence, '^\s', '');

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

