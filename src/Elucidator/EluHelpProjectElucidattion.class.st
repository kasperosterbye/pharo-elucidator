"
There is a help browser in the Pharo image. It is badly out of date. Nevertheless, I try to find out if there are any help topics to be used in elucidation. 

As there are so few, I only look for whole projects. Looking up for a class or package will look up in the containing project.
"
Class {
	#name : #EluHelpProjectElucidattion,
	#superclass : #Elucidation,
	#instVars : [
		'project',
		'html',
		'help'
	],
	#category : #'Elucidator-Core'
}

{ #category : #elucidation }
EluHelpProjectElucidattion >> analyze [
	help := CustomHelp allSubclasses
		select: [ :cl | project packages includes: cl package ].
]

{ #category : #elucidation }
EluHelpProjectElucidattion >> contributes [ 
	^ help isNotEmpty 
]

{ #category : #elucidation }
EluHelpProjectElucidattion >> elucidatePackage: subject html: html [
	self elucidateProject: (subject copyUpTo: $-) html: html
]

{ #category : #elucidation }
EluHelpProjectElucidattion >> elucidateProject: subject html: html [
	| project help |
	project := EluProject fromPackagePrefix: subject.
	help := CustomHelp allSubclasses
		select: [ :cl | project packages includes: cl package ].
	help
		ifEmpty: [ html part: 'No pharo help defined for project ' , project name.
			^ self ].
	html part: 'System help for ' , project name.
	help
		do: [ :helpclass | 
			| helpTopic |
			helpTopic := helpclass perform: helpclass pages first.
			html
				section: [ html helpBrowserLink: helpclass.
					html
						<<
							(helpclass bookName , ' topic 1 of '
								, helpclass pages size printString , ' - ' , helpTopic title) ];
				par: helpTopic contents asString ]
]

{ #category : #'instance creation' }
EluHelpProjectElucidattion >> html: brush [
	html := brush
]

{ #category : #'instance creation' }
EluHelpProjectElucidattion >> on: subject [
	project := EluProject fromPackagePrefix: subject.
]

{ #category : #elucidation }
EluHelpProjectElucidattion >> renderMe [
	
	html part: 'Help from help browser' id: 'help'.
	help
		do: [ :helpclass | 
			| helpTopic |
			helpTopic := helpclass perform: helpclass pages first.
			html
				section: [ html helpBrowserLink: helpclass.
					html
						<<
							(helpclass bookName , ' topic 1 of '
								, helpclass pages size printString , ' - ' , helpTopic title) ];
				par: helpTopic contents asString ]
]

{ #category : #elucidation }
EluHelpProjectElucidattion >> synopsis [ 
	html tag: 'li' do:[
	html << '<b>Help:</b> '.
	self contributes 
		ifTrue: [ html << 'I found ' << help size printString << ' help-books. <br>See more <a href="#help">further down</a>' ]
		ifFalse: [ html << 'I found no help defined in the help system. That is the case for most projects.' ]]
]
