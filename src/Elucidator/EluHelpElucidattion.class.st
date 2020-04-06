Class {
	#name : #EluHelpElucidattion,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #elucidation }
EluHelpElucidattion >> elucidatePackage: subject html: html [
	self elucidateProject: (subject copyUpTo: $-) html: html
]

{ #category : #elucidation }
EluHelpElucidattion >> elucidateProject: subject html: html [
	| project help |
	project := EluProject fromPackageName: subject.
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
						raw:
							helpclass bookName , ' topic 1 of ' , helpclass pages size printString
								, ' - ' , helpTopic title ];
				par: helpTopic contents asString ]
]
