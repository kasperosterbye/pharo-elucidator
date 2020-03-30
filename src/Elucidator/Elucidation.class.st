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
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
Elucidation class >> dispatchHttpRequelst: req [
	| elucidation html |
	elucidation := req at: #elucidation.
	html := ElucidationBrush new.
	elucidation = #all
		ifTrue: [ ^ html
				page: 'All of ' , (req at: #subject)
				do: [ EluAllDispatcher new
						elucidate: (req at: #subject)
						scope: (req at: #scope)
						html: html ] ]
]
