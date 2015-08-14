#!/usr/local/bin/python

import re
import sys
import argparse
import string

FEATURE_NUM = 20

FIRST_PERSON = ["i","my","me","mine","we","our","us","ours"]
THIRD_PERSON = ["he","his","him","she","her","hers","it","its","they","them","their","theirs"]
SECOND_PERSON = ["you","your","yours","u","ur","urs"]
# Pos tag for pronoun
PRONOUN_TAG = ["PRP","PRP$"]
# Pos tag for whword
WHWORD = ["WDT","WP","WP$","WRB"]
# Pos tag for whword
ADVERB = ["RB","RBR","RBS"]
# signals of futre tense
FUTURE = ["will","gonna"]
# coordinating conjunctions
CONJ = []
# list of slang
SLANG = []


# list of features to extract
FEATURES = ["first_person_pronouns",\
			"second_person_pronouns",\
			"third_person_pronouns", \
			"coord_conj",\
			"past_tense_verb",\
			"future_tense_verb",\
			"commas_num",
			"colons_and_semi_colons",\
			"dash_num",\
			"paren_num",\
			"ellipses_num",\
			"common_nouns",\
			"proper_nouns",\
			"adverb_num", \
			"whwords_num",\
			"slang_num",\
			"all_in_upper_case_num",\
			"avg_len_of_sentense",\
			"avg_len_of_tokens",\
			"num_of_sentense"]

#hard code a list filled with 0s to record statistics
STATS = [0]*FEATURE_NUM

def is_first_person_pronoun(token):
	return int(token.lower() in FIRST_PERSON)

def is_second_person_pronoun(token):
	return int(token.lower() in SECOND_PERSON)

def is_third_person_pronoun(token):
	return int(token.lower() in THIRD_PERSON)

def is_coordinating_conjunction(token,tagged_token):
	return int(tagged_token == "CC" or token.lower() in CONJ)

def is_past_verb(tagged_token):
	return int(tagged_token == "VBD")

''' 
scan through tag_list to count how many verb in future tense, tag list
is a list of "token/pos_tag"
'''
def extract_future_verbs(tag_list):
	cur_total = 0
	for i in range(len(tag_list)):
		tagged_token = tag_list[i]
		result = re.findall(r"[^/]+",tagged_token)
		# thin line could be unsafe
		if result and (result[0].lower() in FUTURE or result[0].find("'ll") != -1):
			if i+1 < len(tag_list):
				next_token = tag_list[i+1]
				result = re.findall(r"[^/]+",next_token)
				if result and result[1] == "VB":
					cur_total += 1
		elif result[0].lower() == "going":
			if i+1 < len(tag_list) and i+2 < len(tag_list):
				next_token = tag_list[i+1]
				next_next_token = tag_list[i+2]
				result_next = re.findall(r"[^/]+",next_token)
				result_next_next = re.findall(r"[^/]+",next_next_token)
				if result_next[0].lower() == "to" and result_next_next[1] == "VB":
					cur_total += 1
	return cur_total

def is_comma(token):
	return int(token == ",")

def is_colon_or_semi_colon(token):
	return int(token == ":" or token ==";")

def is_dash(token):
	#What is the definition of dash
	return int(token == "-" * len(token))

def is_parentheses(token):
	return int(token == "(" or token == ")")

def is_ellipses(token):
	return int(token == "." * len(token) and len(token) > 2)

def is_common_noun(tagged_token):
	return int(tagged_token == "NN" or tagged_token == "NNS")

def is_proper_noun(tagged_token):
	return int(tagged_token == "NNP" or tagged_token == "NNPS")

def is_adverb(tagged_token):
	return int(tagged_token in ADVERB)

def is_whword(tagged_token):
	return int(tagged_token in WHWORD)
	
def is_all_upper(token):
	return int(len(token) >= 2 and token.isupper())

def is_slang(token):
	return int(token.lower() in SLANG)

'''load words form Slang and Conjunct'''
def initialize_slang_and_conj():
	slang_file = open("/u/cs401/Wordlists/Slang","r")
	for line in slang_file:
		SLANG.append(line.strip().lower())
	conj_file = open("/u/cs401/Wordlists/Conjunct","r")
	for line in conj_file:
		CONJ.append(line.strip().lower())

'''print relation name'''
def print_headers_to_file(arff_file,classes,relation):
	print >> arff_file, "@relation " + relation
	print >> arff_file, ""
	for elem in FEATURES:
		print >> arff_file, "@attribute " + elem + " numeric"
	class_set = "{"
	for class_name in classes:
		class_set += class_name
		class_set += ","
	print >> arff_file, "@attribute class " + class_set[:-1] + "}"
	print >> arff_file, ""
	print >> arff_file, "@data"

''' 
scan through tag_list to count each features defined in FEATURES
token_list is a list of word tokens from each line of the sentesnse
tag_list is a list of pos tag with one to one mapping to tokens in 
token_list
'''
def extract_features(token_list,tag_list):
	for i in range(len(token_list)):
		token = token_list[i]
		tag = tag_list[i]
		#extracting features
		STATS[FEATURES.index("first_person_pronouns")] += is_first_person_pronoun(token)
		STATS[FEATURES.index("second_person_pronouns")] += is_second_person_pronoun(token)
		STATS[FEATURES.index("third_person_pronouns")] += is_third_person_pronoun(token)
		STATS[FEATURES.index("coord_conj")] += is_coordinating_conjunction(token,tag)
		STATS[FEATURES.index("past_tense_verb")] += is_past_verb(tag)
		STATS[FEATURES.index("commas_num")] += is_comma(token)
		STATS[FEATURES.index("colons_and_semi_colons")] += is_colon_or_semi_colon(token)
		STATS[FEATURES.index("dash_num")] += is_dash(token)
		STATS[FEATURES.index("paren_num")] += is_parentheses(token)
		STATS[FEATURES.index("ellipses_num")] += is_ellipses(token)
		STATS[FEATURES.index("common_nouns")] += is_common_noun(tag)
		STATS[FEATURES.index("proper_nouns")] += is_proper_noun(tag)
		STATS[FEATURES.index("adverb_num")] += is_adverb(tag)
		STATS[FEATURES.index("whwords_num")] += is_whword(tag)
		STATS[FEATURES.index("slang_num")] += is_slang(token)


if __name__ == "__main__":
	if (len(sys.argv) < 3):
		print "Usage error: not enough arguments"
		sys.exit()
	#initialize the default tweet limit with a super large number
	max_tweet_num = 1000000
	#parse the input arguments
	input_args = sys.argv[1:-1]
	file_output = sys.argv[-1]
	arff_file = open(file_output,'w')
	# load ffrom files contain slang and conjunctions
	initialize_slang_and_conj()
	# define the relation as the file name of the output file
	relation = re.findall(r"\w+(?=.arff)",file_output)[0]
	# list of classes specified by the user
	classes = []
	# list of files associate with each class
	class_files = []

	# max number of tweets is specified
	if input_args[0][0] == "-":
		max_tweet_num = int(input_args[0][1:])
		input_args = input_args[1:]

	for i in range(len(input_args)):
		input_arg = input_args[i].split(":")
		if len(input_arg) > 1:
			#class name is specified
			classes.append(input_arg[0])
		else:
			#class name is not specified
			classes.append(re.findall(r"\w+(?=.twt)",input_arg[0])[0])
		class_files.append(input_arg[-1].split("+"))

	print_headers_to_file(arff_file,classes,relation)

	# use to index class_files for each class
	class_index = 0
	num_of_sentense = 0
	num_of_tokens = 0
	total_len_of_token = 0
	num_of_of_non_punc = 0
	punctuation = list(string.punctuation)

	for class_name in classes:
		files = class_files[class_index]
		open_files = []
		#open all files for this class
		for file_name in files:
			open_files.append(open(file_name,'r'))
		for twt_file in open_files:
			num_of_tweet = 0
			#processing the file
			for line in twt_file:
				if num_of_tweet == max_tweet_num:
						break
				elif line.strip() == "|":
					# end of the tweet, print all collected stats to arff file if
					# ignore the empty tweet after normalization
					if num_of_sentense != 0:
						STATS[FEATURES.index("avg_len_of_sentense")] = float(num_of_tokens)/num_of_sentense
						if num_of_of_non_punc != 0:	
							STATS[FEATURES.index("avg_len_of_tokens")] = float(total_len_of_token)/num_of_of_non_punc
						else:
							STATS[FEATURES.index("avg_len_of_tokens")] = 0
						STATS[FEATURES.index("num_of_sentense")] = num_of_sentense
						print >> arff_file, str(STATS)[1:-1] + "," + class_name
					#re-initiate statistics
					num_of_tweet += 1
					num_of_sentense = 0
					num_of_tokens = 0
					total_len_of_token = 0
					num_of_of_non_punc = 0
					STATS = [0] * FEATURE_NUM
				else:
					num_of_sentense += 1
					tagged_token_list = line.strip().split()
					STATS[FEATURES.index("future_tense_verb")] += extract_future_verbs(tagged_token_list)
					token_list = []
					tag_list = []
					for tagged_token in tagged_token_list:
						r = re.findall(r"[^/]+",tagged_token)
						#get rid of untagged token
						if len(r) > 1:
							#check to see if it is punctuation
							#if it's not a single punctuation, update the stats
							if not r[0] in punctuation:	
								total_len_of_token += len(r[0])
								num_of_of_non_punc += 1
							num_of_tokens += 1
							token_list.append(r[0])
							tag_list.append(r[1])
					# extract features from token list
					extract_features(token_list,tag_list)
		class_index += 1
		#close all the open files
		for open_file in open_files:
			open_file.close()
	arff_file.close()