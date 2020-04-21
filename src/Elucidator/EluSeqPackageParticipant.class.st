"
See comment in EluSeqParticipant
"
Class {
	#name : #EluSeqPackageParticipant,
	#superclass : #EluSeqParticipant,
	#instVars : [
		'projectName'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #'instance creation' }
EluSeqPackageParticipant class >> for: projName [ 
	^self new projectName: projName
]

{ #category : #testing }
EluSeqPackageParticipant >> isClassParticipant [
	^ false
]

{ #category : #accessing }
EluSeqPackageParticipant >> name [
	^ projectName
]

{ #category : #accessing }
EluSeqPackageParticipant >> participantDeclOn: stream [
	(stream << 'participant "[[http://localhost:20203/all/package/'
		<< self name << ' ' << self name << ']]" as ' << self refName)
		<< '<< (P,#ADD1B2) >> #999999';
		cr
]

{ #category : #accessing }
EluSeqPackageParticipant >> projectName [
	^ projectName
]

{ #category : #accessing }
EluSeqPackageParticipant >> projectName: anObject [
	projectName := anObject
]

{ #category : #accessing }
EluSeqPackageParticipant >> refName [
	^ (projectName copyReplaceAll: ' ' with: '_') copyReplaceAll: '-' with: '_' 
]
