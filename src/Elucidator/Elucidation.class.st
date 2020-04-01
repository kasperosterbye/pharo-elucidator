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

{ #category : #'as yet unclassified' }
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
