"
There is a help browser in the Pharo image. It is badly out of date. Nevertheless, I try to find out if there are any help topics to be used in elucidation. 

As there are so few, I only look for whole projects. Looking up for a class or package will look up in the containing project.
"
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
