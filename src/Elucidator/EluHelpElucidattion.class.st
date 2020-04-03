Class {
	#name : #EluHelpElucidattion,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #elucidation }
EluHelpElucidattion >> elucidatePackage: subject html: html [
	| rootName help |
	rootName := subject copyUpTo: $-.
	help := CustomHelp allSubclasses
		select: [ :cl | (cl package name copyUpTo: $-) = rootName ].
	help
		ifEmpty: [ html part: 'No pharo help defined for: ' , subject.
			^ self ].
	html part: 'System help for ' , rootName .
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
