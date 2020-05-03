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
	class := Elucidator classFromHtmlName: subject.
	self headerForClass: class on: html.
	EluExamplesElucidattion new elucidateClass: class html: html.
	EluInstanceElucidattion new elucidateClass: class html: html.
	EluCommentsElucidation new elucidateClass: class html: html
]

{ #category : #'as yet unclassified' }
EluAllElucidation >> elucidatePackage: subject html: html [
	| elucidations |
	elucidations := {"EluHelpElucidattion  on: subject html: html.
	EluExamplesElucidattion on: subject html: html.
	EluInstanceElucidattion on: subject html: html."
	EluCommentsPackageElucidation on: subject html: html.
	EluAnnouncerPackageElucidation on: subject html: html}.
	html tag:'ul' do: [ elucidations do: [ :el | el synopsis ]].
	(elucidations select: [ :el | el contributes ]) do: [ :el | el renderMe ]
	
]

{ #category : #'as yet unclassified' }
EluAllElucidation >> headerForClass: class on: html [
	"Write a header for class. Include a link to the project page"

	| projName |
	html << 'This class lives in the context of the project: '.
	projName := self projectName: class package name.
	html elucidateLink: projName to: 'all/package/' , projName.
	html << (String cr , '<hr>' , String cr)
]
