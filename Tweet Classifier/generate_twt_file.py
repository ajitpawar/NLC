import sys
import os

if __name__ == "__main__":
	tweet_files_list = []
	for i in range(1,len(sys.argv)):
		tweet_files_list.append(sys.argv[i])
	for tweet_file in tweet_files_list:
		os.system("python twtt.py "+ tweet_file + " " + tweet_file + ".twt")


