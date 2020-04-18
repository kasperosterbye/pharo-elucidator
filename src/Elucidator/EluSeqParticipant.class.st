Class {
	#name : #EluSeqParticipant,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #testing }
EluSeqParticipant >> isClassParticipant [
	self subclassResponsibility 
]

{ #category : #accessing }
EluSeqParticipant >> name [ self subclassResponsibility 
]

{ #category : #printing }
EluSeqParticipant >> printOn: aStream [
	aStream << self name
]
