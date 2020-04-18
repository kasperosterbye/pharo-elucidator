Class {
	#name : #EluSeqClassParticipant,
	#superclass : #EluSeqParticipant,
	#instVars : [
		'theClass'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #'instance creation' }
EluSeqClassParticipant class >> for: class [ 
	^ self new theClass: class
]

{ #category : #testing }
EluSeqClassParticipant >> isClassParticipant [
	^true
]

{ #category : #accessing }
EluSeqClassParticipant >> name [
	^ theClass name 
]

{ #category : #accessing }
EluSeqClassParticipant >> participantDeclOn: stream [
	(stream << 'participant "[[http://localhost:20203/browseClass/'
		<< self refName << ' ' << self name << ']]" as ')
		<< self refName;
		cr
]

{ #category : #accessing }
EluSeqClassParticipant >> refName [
	^ (theClass name copyReplaceAll: ' ' with: '_') copyReplaceAll: '-' with: '_' 
]

{ #category : #accessing }
EluSeqClassParticipant >> theClass [
	^ theClass
]

{ #category : #accessing }
EluSeqClassParticipant >> theClass: anObject [
	theClass := anObject
]
