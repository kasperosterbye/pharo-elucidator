Class {
	#name : #EluAllElucidation,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #'as yet unclassified' }
EluAllElucidation >> elucidate: subject scope: scope html: html [
	scope = #package
		ifTrue: [ ^ self elucidatePackage: subject html: html ].
	"scope = #class
		ifTrue: [ ^ self elucidateClass: subject ].
	^ self scopeNotDefined"
]

{ #category : #'as yet unclassified' }
EluAllElucidation >> elucidatePackage: subject html: html [
	^ EluCommentsElucidation new elucidatePackage: subject html: html
]

{ #category : #'as yet unclassified' }
EluAllElucidation >> handle: req on: html [
	| scope subject |
	scope := req at: #scope.
	subject := req at: #subject.
	html
		page: 'All of ' , scope , ': ' , subject
		do: [ self elucidate: subject scope: scope html: html ]
]
