Class {
	#name : #EluAllElucidation,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #'as yet unclassified' }
EluAllElucidation >> elucidatePackage: subject html: html [
	EluHelpElucidattion new elucidatePackage: subject html: html.
	EluExamplesElucidattion new elucidatePackage: subject html: html.
	EluCommentsElucidation new elucidatePackage: subject html: html
]
