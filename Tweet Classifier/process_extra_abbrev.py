if __name__ == '__main__':
	abbrev1 = open('extra_abbrev','r')
	abbrev1_output = open('extra_abbrev.english','w')
	for line in abbrev1:
		line = line.strip().split()
		if line[-1][-1] == "." and len(line[-1]) > 2:
			print >> abbrev1_output, line[-1].lower()
	abbrev1.close()
	abbrev1_output.close()