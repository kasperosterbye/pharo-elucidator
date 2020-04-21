"
I represent a participant in the UML diagram (The boxes on the top of the diagram).

I have two subclasses to represent the two kinds of participants.
A class participant and a Package participant. Package participants are filtered classes which are mapped to their package to reduce clutter.
"
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
