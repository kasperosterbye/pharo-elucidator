Class {
	#name : #EluAllDispatcher,
	#superclass : #EluDispatcher,
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
EluAllDispatcher >> elucidate: subject scope: scope html: html [
	scope = #package
		ifTrue: [ ^ self elucidatePackage: subject html: html].
	scope = #class
		ifTrue: [ ^ self elucidateClass: subject ].
	^ self scopeNotDefined
]

{ #category : #'as yet unclassified' }
EluAllDispatcher >> elucidatePackage: subject html: html [
	^ EluCommentsDispatcher new commentPackage: subject html: html
]
