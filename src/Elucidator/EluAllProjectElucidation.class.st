"
I am an aggregate elucidation, combining the information from the other subclasses of Elucidation.

"
Class {
	#name : #EluAllProjectElucidation,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
EluAllProjectElucidation >> elucidateProject: subject html: html [
	| elucidations |
	elucidations := {
		EluCommentsProjectElucidation on: subject html: html.
		EluAnnouncerProjectElucidation on: subject html: html.
		EluExamplesProjectElucidattion on: subject html: html.
		EluHelpProjectElucidattion on: subject html: html.
		EluInstanceProjectElucidattion  on: subject html: html.
	}.
	
	html tag: 'ul' do: [ elucidations do: [ :el | el synopsis ] ].
	(elucidations select: [ :el | el contributes ])
		do: [ :el | el renderMe ]
]

{ #category : #'as yet unclassified' }
EluAllProjectElucidation >> headerForClass: class on: html [
	"Write a header for class. Include a link to the project page"

	| projName |
	html << 'This class lives in the context of the project: '.
	projName := self projectName: class package name.
	html pharoLink: projName to: 'all/package/' , projName.
	html << (String cr , '<hr>' , String cr)
]
