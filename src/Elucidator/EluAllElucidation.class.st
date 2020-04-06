Class {
	#name : #EluAllElucidation,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #'as yet unclassified' }
EluAllElucidation >> elucidatePackage: subject html: html [
	EluHelpElucidattion new elucidateProject: subject html: html.
	EluExamplesElucidattion new elucidateProject: subject html: html.
	EluInstanceElucidattion new elucidateProject: subject html: html.
	EluCommentsElucidation new elucidatePackage: subject html: html
]
