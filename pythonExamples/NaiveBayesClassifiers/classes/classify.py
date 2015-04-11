#####	Marc Sturzl | 21404133

import math as m

class Classify:
	@staticmethod
	def classify(toClassify, totalFWords, totalSWords, sites, sSites, sWords, fWords,col668Repetitions):
			pStudent = m.log(float(sSites)/float(sites)) #log(P(Site=Student))
			pFaculty = m.log(float((sites-sSites))/float(sites)) #log(P(Site=Faculty))
			for i in range(len(sWords)):
				if(i == 668):
					while(col668Repetitions>0):
						col668Repetitions -= 1
						if int(toClassify[i]) != 0:
								if(pStudent != 1):
										if(sWords[i] == 0):
												pStudent = 1 #error value, log went to negative infinity, the word doesn't appear in the training set
										else:
												pStudent += float(toClassify[i])*m.log(float(sWords[i])/float(totalSWords))
								if(pFaculty != 1):
										if fWords[i] == 0:
												pFaculty = 1
										else:
												pFaculty += float(toClassify[i])*m.log(float(fWords[i])/float(totalFWords))
				else:
					if int(toClassify[i]) != 0:
								if(pStudent != 1):
										if(sWords[i] == 0):
												pStudent = 1 #error value, log went to negative infinity, the word doesn't appear in the training set
										else:
												pStudent += float(toClassify[i])*m.log(float(sWords[i])/float(totalSWords))
								if(pFaculty != 1):
										if fWords[i] == 0:
												pFaculty = 1
										else:
												pFaculty += float(toClassify[i])*m.log(float(fWords[i])/float(totalFWords))
			if(pStudent == pFaculty or pStudent == 1):
					return 'faculty' #tie or not in student --> faculty
			elif(pFaculty == 1):
				return 'student' #not in faculty --> student
			else:
				return 'student' if pStudent>pFaculty else 'faculty'  # --> argmax(Pstudent,PFaculty)

	@staticmethod
	def classifyTFIDF(toClassify, sSites, fSites, bsWords, bfWords, sites):
		pStudent = 0
		pFaculty = 0
		for i,word in enumerate(toClassify):
			if int(word) > 0:
				pStudent += float(1 + m.log(int(word)))*m.log(float(sSites)/float(1+bsWords[i]))
				pFaculty += float(1+ m.log(int(word)))*m.log(float(fSites)/float(1+bfWords[i]))
		if(pStudent >= pFaculty):
			return 'faculty' #tie or not in student --> faculty
		else:
			return 'student'

	@staticmethod
	def fold(dataFileName, foldFileName, foldNo, totalFWords, totalSWords, sites, sSites, sWords, fWords, tfidf,col668Repetitions):
		#tStudent, fStudent, tFaculty, fFaculty
		tSetCMatrix = [0,0,0,0]
		vSetCMatrix = [0,0,0,0]
		folds = open(foldFileName)
		data = open(dataFileName)

		for line in data:
			split = line.split(',')
			if tfidf:
				classification = Classify.classifyTFIDF(split[1:], sSites, sites-sSites, totalSWords, totalFWords, sites)
			else:
				classification =  Classify.classify(split[1:],totalFWords, totalSWords, sites, sSites, sWords,fWords,col668Repetitions)
			label = split[0]
			if(folds.readline() != str(foldNo)+'\n'): #the fold passed in is the excluded in the test set (excluded from the validation set)
				if classification != label:
					if label == 'faculty':
						tSetCMatrix[1] += 1 #if the guess was a incorrect and the correct guess was student incriment falese Student
					else:
						tSetCMatrix[3] += 1 #or if the correct guess was faculty incriment false faculty
				else:
					if label == 'student':
						tSetCMatrix[0] += 1 # if it was correct about a student, then incriment true student
					else:
						vSetCMatrix[2] += 1
			else:
				if classification != label:
					if label == 'faculty':
						vSetCMatrix[1] += 1 #if the guess was a incorrect and the correct guess was student incriment falese Student
					else:
						vSetCMatrix[3] += 1 #or if hte correct guess was faculty incriment false faculty
				else:
					if label == 'student':
						vSetCMatrix[0] += 1 # if it was correct about a student, then incriment true student
					else:
						vSetCMatrix[2] += 1
		#tStudent, fStudent, tFaculty, fFaculty
		vSetAccuracy = float(vSetCMatrix[0]+vSetCMatrix[2])/float(vSetCMatrix[0]+vSetCMatrix[1]+vSetCMatrix[2]+vSetCMatrix[3])
		tSetAccuracy = float(tSetCMatrix[0]+tSetCMatrix[2])/float(tSetCMatrix[0]+tSetCMatrix[1]+tSetCMatrix[2]+tSetCMatrix[3])
		return [tSetCMatrix,vSetCMatrix,tSetAccuracy,vSetAccuracy]