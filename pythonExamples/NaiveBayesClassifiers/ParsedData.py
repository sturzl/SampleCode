#####	Marc Sturzl | 21404133

from classes.classify import Classify

class ParsedData:

	def __init__(self,fold, dataFile, foldFile):
			self.sites, self.fSites, self.sSites, self.totalSWords, self.totalFWords = 0,0,0,0,0
			self.sWords, self.fWords,self.bsWords, self.bfWords = [0]*1309,[0]*1309,[0]*1309,[0]*1309
			self.dataFile, self.foldFile = dataFile, foldFile
			self.fold = fold
			self.parseData()

	def parseData(self):
			data = open(self.dataFile,'r')
			folds = open(self.foldFile, 'r')
			for line in data:
					if(folds.readline() != str(self.fold) + '\n'): #exclude the fold passed in
							words = line.split(',')
							self.sites += 1
							if words[0] == 'faculty':
									self.fSites += 1
									for word in range(1308):
										wordOccurrences = int(words[word+1])
										if wordOccurrences > 0:
											self.fWords[word] += wordOccurrences
											self.totalFWords += wordOccurrences
											self.bfWords[word] += 1
							else:
									for word in range(1308):
											wordOccurrences = int(words[word+1])
											if wordOccurrences > 0:
												self.sWords[word] += wordOccurrences
												self.totalSWords += wordOccurrences
												self.bsWords[word] += 1

			self.sSites = self.sites - self.fSites
			return

	def smoothing(self):
			vocabCardinality = len(self.sWords)
			for x in range(vocabCardinality):
				self.sWords[x] += 1
				self.fWords[x] += 1
				self.bsWords[x] += 1
				self.bfWords[x] += 1
			self.totalFWords += vocabCardinality
			self.totalSWords += vocabCardinality
			self.sSites += vocabCardinality
			self.fSites += vocabCardinality
			self.sites += 2*vocabCardinality

	def printStats(self):
			print 'sites  =  ' + str(self.sites)
			print 'fSites  =  ' + str(self.fSites)
			print 'sSites  =  ' + str(self.sSites)
			print 'totalSWords  =  ' + str(self.totalSWords)
			print 'totalFWords  =  ' + str(self.totalFWords) + '\n'

def main():
		dataFileName = 'data.txt'
		foldFileName = 'folds.txt'
		foldsToTest = 10+1 #number of folds to test + 1, max is 11 for all 10 folds
		folds = [ParsedData(x,dataFileName,foldFileName) for x in range (1,foldsToTest)]
		polynomialVerificationAccuracySum = 0
		polynomialTestAccuracySum = 0
		SmoothPolynomialVerificationSum = 0
		SmoothPolynomialTestSum = 0
		bpolynomialVerificationAccuracySum = 0
		bpolynomialTestAccuracySum = 0
		bSmoothPolynomialVerificationSum = 0
		bSmoothPolynomialTestSum = 0
		TFIDFVerificationAccuracySum = 0
		TFIDFTestAccuracySum = 0
		for i,fold in enumerate(folds):
			tfidf = Classify.fold(dataFileName,foldFileName,(i+1),fold.bfWords,fold.bsWords,fold.sites,fold.sSites,fold.sWords,fold.fWords,True,1)
			p  = Classify.fold(dataFileName,foldFileName,(i+1),fold.totalFWords,fold.totalSWords,fold.sites,fold.sSites,fold.sWords,fold.fWords,False,1)
			b  = Classify.fold(dataFileName,foldFileName,(i+1),fold.fSites,fold.sSites,fold.sites,fold.sSites,fold.bsWords,fold.bfWords,False,1)
			fold.smoothing()
			ps = Classify.fold(dataFileName,foldFileName,(i+1),fold.totalFWords,fold.totalSWords,fold.sites,fold.sSites,fold.sWords,fold.fWords,False,1)
			bs = Classify.fold(dataFileName,foldFileName,(i+1),fold.fSites,fold.sSites,fold.sites,fold.sSites,fold.bsWords,fold.bfWords,False,1)
			TFIDFVerificationAccuracySum += tfidf[3]
			TFIDFTestAccuracySum += tfidf[2]
			polynomialVerificationAccuracySum += p[3]
			polynomialTestAccuracySum += p[2]
			SmoothPolynomialVerificationSum += ps[3]
			SmoothPolynomialTestSum += ps[2]
			bpolynomialVerificationAccuracySum += b[3]
			bpolynomialTestAccuracySum += b[2]
			bSmoothPolynomialVerificationSum += bs[3]
			bSmoothPolynomialTestSum += bs[2]
		print('Bernoulli Verification Accuracy Crosss Verification				' + str(bpolynomialVerificationAccuracySum/float(foldsToTest-1)))
		print('Smoothed Bernoulli Verification Accuracy Crosss Verification	 '+ str(bSmoothPolynomialVerificationSum/float(foldsToTest-1)))
		print('Polynomial Verification Accuracy Crosss Verification			' + str(polynomialVerificationAccuracySum/float(foldsToTest-1)))
		print('Smoothed Polynomial Verification Accuracy Crosss Verification	' + str(SmoothPolynomialVerificationSum/float(foldsToTest-1)))
		print('TF-IDF Verification Accuracy Crosss Verification				' + str(TFIDFVerificationAccuracySum/float(foldsToTest-1)) + '\n')
		print('Bernoulli Test Accuracy Crosss Verification						' + str(bpolynomialTestAccuracySum/float(foldsToTest-1)))
		print('Smoothed Bernoulli Test Accuracy Crosss Verification			' + str(bSmoothPolynomialTestSum/float(foldsToTest-1)))
		print('Polynomial Test Accuracy Crosss Verification					' + str(polynomialTestAccuracySum/float(foldsToTest-1)))
		print('Smoothed Polynomial Test Accuracy Crosss Verification			' + str(SmoothPolynomialTestSum/float(foldsToTest-1)))
		print('TF-IDF Test Accuracy Crosss Verification						' + str(TFIDFTestAccuracySum/float(foldsToTest-1)) + '\n')

		print('The most accurate modles are the Polynomial and Bernoulli predictors at 83.49 and 83.27 percent')
		print('accuracy on the test data. They are followed by the their smoothed versions and the TF-IDF classifier')
		print('which range from 81.27 to 81.41 percent accurracy. The confusion matricies for all models are below.\n')


		print('LP, LF Labelled true, labelled false, CT CF classified true classified false')
		print('students are considered true, faculty is considered false ex:\n')

		print('   LT   LF')
		print('CT TP   FP')
		print('CF FN   TN\n\n')

		print('ordered from most to least accurate, confusion matricies of the models based on cross validated test data:\n')

		print('Polynomial Test Data Confusion Matrix')
		print('   LT   LF')
		print('CT '+str(p[1][0])+'  '+str(p[1][3])+'')
		print('CF '+str(p[1][1])+'  '+str(p[1][2])+'\n\n')

		print('Bernoulli Test Data Confusion Matrix')
		print('   LT   LF')
		print('CT '+str(b[1][0])+'  '+str(b[1][3])+'')
		print('CF '+str(b[1][1])+'  '+str(b[1][2])+'\n\n')

		print('TF-IDF  Test Data Confusion Matrix')
		print('   LT   LF')
		print('CT '+str(tfidf[1][0])+'  '+str(tfidf[1][3])+'')
		print('CF '+str(tfidf[1][1])+'  '+str(tfidf[1][2])+'\n\n')

		print('Smoothed Polynomial Test Data Confusion Matrix')
		print('   LT   LF')
		print('CT '+str(ps[1][0])+'  '+str(ps[1][3])+'')
		print('CF '+str(ps[1][1])+'  '+str(ps[1][2])+'\n\n')

		print('Smoothed Bernoulli Test Data Confusion Matrix')
		print('   LT   LF')
		print('CT '+str(bs[1][0])+'  '+str(bs[1][3])+'')
		print('CF '+str(bs[1][1])+'  '+str(bs[1][2])+'\n\n\n\n')
		repetitions668 = [1,2,5,10,20]
		print('Polynomial Cross Verified Accuracy with repetitions of Column 668\n')
		for n in repetitions668:
			polynomialVerificationAccuracySum = 0
			polynomialTestAccuracySum = 0
			for i,fold in enumerate(folds):
				p  = Classify.fold(dataFileName,foldFileName,(i+1),fold.totalFWords,fold.totalSWords,fold.sites,fold.sSites,fold.sWords,fold.fWords,False,n)
				polynomialVerificationAccuracySum += p[3]
				polynomialTestAccuracySum += p[2]
			print('Column 668 repetitions: ' + str(n))
			print('Verification Accuracy			' + str(polynomialVerificationAccuracySum/float(foldsToTest-1)))
			print('Test Accuracy					' + str(polynomialTestAccuracySum/float(foldsToTest-1)) + '\n')
if __name__=='__main__':main()