"
I am an aggregate elucidation, combining the information from the other subclasses of Elucidation.

"
Class {
	#name : #EluAllElucidation,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
EluAllElucidation >> elucidateClass: subject html: html [
	| class |
	class := self findClass: subject.
	self headerForClass: class on: html.
	EluExamplesElucidattion new elucidateClass: class html: html.
	EluInstanceElucidattion new elucidateClass: class html: html.
	EluCommentsElucidation new elucidateClass: class html: html
]

{ #category : #'as yet unclassified' }
EluAllElucidation >> elucidatePackage: subject html: html [
	EluHelpElucidattion new elucidateProject: subject html: html.
	EluExamplesElucidattion new elucidateProject: subject html: html.
	EluInstanceElucidattion new elucidateProject: subject html: html.
	EluCommentsElucidation new elucidatePackage: subject html: html
]

{ #category : #'as yet unclassified' }
EluAllElucidation >> headerForClass: class on: html [
	"Write a header for class. Include a link to the project page"

	| projName |
	html raw: 'This class lives in the context of the project: '.
	projName := self projectName: class package name.
	html elucidateLink: projName to: 'all/package/' , projName.
	html raw: String cr , '<hr>' , String cr
]
