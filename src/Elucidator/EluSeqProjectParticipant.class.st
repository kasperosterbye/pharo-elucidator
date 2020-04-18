Class {
	#name : #EluSeqProjectParticipant,
	#superclass : #EluSeqParticipant,
	#instVars : [
		'projectName'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #'instance creation' }
EluSeqProjectParticipant class >> for: projName [ 
	^self new projectName: projName
]

{ #category : #testing }
EluSeqProjectParticipant >> isClassParticipant [
	^ false
]

{ #category : #accessing }
EluSeqProjectParticipant >> name [
	^ projectName
]

{ #category : #accessing }
EluSeqProjectParticipant >> participantDeclOn: stream [
	(stream << 'participant "[[http://localhost:20203/all/package/'
		<< self name << ' ' << self name << ']]" as ' << self refName)
		<< '<< (P,#ADD1B2) >> #999999';
		cr
]

{ #category : #accessing }
EluSeqProjectParticipant >> projectName [
	^ projectName
]

{ #category : #accessing }
EluSeqProjectParticipant >> projectName: anObject [
	projectName := anObject
]

{ #category : #accessing }
EluSeqProjectParticipant >> refName [
	^ (projectName copyReplaceAll: ' ' with: '_') copyReplaceAll: '-' with: '_' 
]
