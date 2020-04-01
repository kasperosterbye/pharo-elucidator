"
I am the superclass for elucications.
Each elucidation explains a specific aspect of code.

subclasses must implement:
	elucidate: request 
	
request is forwarded from the elucidator 
"
Class {
	#name : #Elucidation,
	#superclass : #Object,
	#category : #Elucidator
}

{ #category : #'as yet unclassified' }
Elucidation class >> dispatch: req on: html [
	| elucidation |
	elucidation := req at: #elucidation.
	elucidation = #all
		ifTrue: [ ^ EluAllElucidation new
						handle: req
						on: html ]
]

{ #category : #elucidation }
Elucidation >> elucidate: subject scope: scope html: html [
	scope = #package
		ifTrue: [ ^ self elucidatePackage: subject html: html ].
	"scope = #class
		ifTrue: [ ^ self elucidateClass: subject ].
	^ self scopeNotDefined"
]

{ #category : #elucidation }
Elucidation >> elucidateClass: subject html: html [
	self subclassResponsibility
]

{ #category : #elucidation }
Elucidation >> elucidatePackage: subject html: html [ 
	self subclassResponsibility 
]

{ #category : #'helper methods' }
Elucidation >> findPackage: packageName [
	"find package based on packageName. Ignore case and implementation class"
	| allNames |
	allNames := RPackageOrganizer default packageNames.
	allNames
		do: [ :pName | 
			(pName sameAs: packageName)
				ifTrue: [ ^ RPackageOrganizer default packageNamed: pName ] ].
	^ nil
]

{ #category : #elucidation }
Elucidation >> handle: req on: html [
	| scope subject |
	scope := req at: #scope.
	subject := req at: #subject.
	html
		page: 'All of ' , scope , ': ' , subject
		do: [ self elucidate: subject scope: scope html: html ]
]
