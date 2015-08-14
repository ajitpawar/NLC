#!/usr/local/bin/python

import sys
import re
import HTMLParser
import string
import NLPlib


ENDING_PUNC = ['.','?','!']
TAGGER = None

#preprocess the input_line 
def remove_html_stuff(input_line):
    #get rid of tags
    new_line = re.sub('<[^<]*>', '', input_line)
    #replace all html character codes with ASCII equivalent
    parser = HTMLParser.HTMLParser()
    new_line = str(parser.unescape(new_line))
    #remove all the urls
    new_line = re.sub('http\S+|www\S+', '', new_line)
    #some url does not start with "www"
    new_line = re.sub('\S+/\S+', '', new_line)
    #remove the preceeding @ and # 
    new_line = new_line.strip().split()
    for i in range(len(new_line)):
        if re.match(r'^@\w+|^#\w+', new_line[i]):
            new_line[i] = new_line[i][1:]
    new_line = " ".join(new_line)
    #incase some tweet does no include an ending punc
    new_line = new_line.strip()
    if new_line and new_line.split()[-1][-1] not in ENDING_PUNC:
        new_line = new_line + '.'
    return new_line

#break the whole tweet into a list of sentenses
def my_lame_break_line(input_line,abbrev_list):
    # for those who always forget to add space after punctuation
    input_line = re.sub(r"(\w+[!?]+)", r'\1 ',input_line)
    input_list = input_line.strip().split()
    elem_list = []
    sentense_list = []
    next_index = 1
    for elem in input_list:
        if elem[-1] == ".": 
            if not is_abbrev(elem, abbrev_list):
                elem_list.append(elem)
                sentense_list.append(" ".join(elem_list))
                elem_list = []
            elif next_index < len(input_list) and input_list[next_index][0].isupper():
                elem_list.append(elem)
                sentense_list.append(" ".join(elem_list))
                elem_list = []
            else:
                # mark abbrev ending with "." with "@" for the convenience
                # of tokenization
                elem_list.append("@"+elem)
        #no abbreviation issue with "!" and "?", just break the line
        elif elem[-1] == "!" or elem[-1] == "?":
            elem_list.append(elem)
            sentense_list.append(" ".join(elem_list))
            elem_list = []
        #not possible to be the case of the end of the sentense
        else:
            # mark abbrev ending with "." with "@" for the convenience
            # of tokenization
            if is_abbrev(elem[:-1],abbrev_list):
                elem = "@" + elem
            elem_list.append(elem)
        next_index += 1
    #in case the tweet does not have an ending punctuation
    if len(elem_list) > 0:
        sentense_list.append(" ".join(elem_list))
    return sentense_list

def is_abbrev(word_token, abbrev_list):
    return (word_token.lower() in abbrev_list)

#tokenize each sentense in the sentense_list
def tokenize_sentense(sentense_list):
    token_list_list = []
    #hope it works fine
    reg = r"n't|'ll|@[\w.]+|[0-9,]+[0-9]+\.[0-9]+|[0-9,]+[0-9]+|[0-9]+|" + \
          r"(?:[A-Z]\.)+|\w+(?=n't)|[\w]+|'\w |[.?!]+|[,&;:$\-()%]+|['\"]+"
    for sentense in sentense_list:
        token_list = re.findall(reg,sentense)
        #clear the ending spaces of each token
        token_list = map(lambda x: x.strip(), token_list)
        for i in range(len(token_list)):
            #remove the prefix "@" which marks the abbreviation
            if token_list[i][0] == "@":
                token_list[i] = token_list[i][1:]
        token_list_list.append(token_list)
    return token_list_list

#tag all tokens in token_list_list
def tag_tokens(token_list_list):
    tag_list_list = []
    for token_list in token_list_list:
        tags = TAGGER.tag(token_list)
        for i in range(len(token_list)):
            tags[i] = token_list[i] + '/' + tags[i]
        tag_list_list.append(tags)
    return tag_list_list

if __name__ == '__main__':
    if (len(sys.argv) != 3):
        print "Usage: twtt.py inputfile outfile"
        sys.exit()
    TAGGER = NLPlib.NLPlib()
    #parsing the arguments
    file_input = sys.argv[1]
    file_output = sys.argv[2]
    abbrev_english = "/u/cs401/Wordlists/abbrev.english"
    tweet_file = open(file_input,'r')
    abbrev_file = open(abbrev_english, 'r')
    extra_abbrev_file = open("extra_abbrev.english",'r')
    revised_file = open(file_output, 'w')

    #loading from the abbrev_file and extra_abbrev_file
    abbrev_list = []
    for line in abbrev_file:
        abbrev_list.append(line.strip().lower())
    for line in extra_abbrev_file:
        abbrev = line.strip()
        if abbrev not in abbrev_list:
            abbrev_list.append(abbrev)

    counter = 0    
    for line in tweet_file:
        new_line = remove_html_stuff(line)
        sentense_list = my_lame_break_line(new_line,abbrev_list)
        token_list_list = tokenize_sentense(sentense_list) 
        tag_list_list = tag_tokens(token_list_list)
        for tag_list in tag_list_list:
            print  >> revised_file, " ".join(tag_list)
        print >> revised_file,"|"

    abbrev_file.close()
    extra_abbrev_file.close()
    tweet_file.close()
    revised_file.close()

