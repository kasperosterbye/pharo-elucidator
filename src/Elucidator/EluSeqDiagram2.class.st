Class {
	#name : #EluSeqDiagram2,
	#superclass : #Object,
	#instVars : [
		'calls',
		'participants',
		'filter',
		'maxSize'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #examples }
EluSeqDiagram2 class >> example1 [
	<example>
	(self new
		filter: {'Kernel'};
		fromBlock: [ Float pi printString ];
		uml) inspect
		
]

{ #category : #examples }
EluSeqDiagram2 class >> example2 [
	<example>
	self new
		filter: {'Kernel'};
		fromBlock: [ Float pi printString ];
		openUml
]

{ #category : #accessing }
EluSeqDiagram2 >> filter: anObject [
	filter := anObject
]

{ #category : #accessing }
EluSeqDiagram2 >> filters: receiverClass [
	| receiverPackageName |
	(filter isNil or: [ filter isEmpty ]) ifTrue: [ ^true ].
	receiverPackageName := receiverClass package name.
	^ filter anySatisfy: [ :f | receiverPackageName beginsWith: f ]
]

{ #category : #'instance creation' }
EluSeqDiagram2 >> fromBlock: block [
	^ self
		fromTally:
			(MessageTally
				tallySendsTo: nil
				inBlock: block
				showTree: false
				closeAfter: false
				openResultWindow: false)
]

{ #category : #'instance creation' }
EluSeqDiagram2 >> fromTally: tally [
	"I assume maxSize and filter has been set"

	participants := OrderedDictionary new.
	calls := EluSeqCall new
		sender: (self participantFor: UndefinedObject);
		fromTally: tally in: self
]

{ #category : #'as yet unclassified' }
EluSeqDiagram2 >> includeCallFrom: senderParticipant to: receiverTally [
	"return true if this call should be included in the diagram.
	The condition one of the two should be a class participant"

	^ senderParticipant isClassParticipant
		or: [ 
			(self participantFor: receiverTally theClass) isClassParticipant ]
]

{ #category : #accessing }
EluSeqDiagram2 >> maxSize: anObject [
	maxSize := anObject
]

{ #category : #'as yet unclassified' }
EluSeqDiagram2 >> oldreceiverFor: tally [
	"I return the receiver (Participant) for the tally. I apply filter to be able to reduce complexity of the diagram"

	| receiverClass |
	receiverClass := tally theClass.
	^ (self filters: receiverClass)
		ifTrue: [ participants
				at: receiverClass name
				ifAbsentPut: [ EluSeqClassParticipant for: receiverClass ] ]
		ifFalse: [ | projName |
			projName := receiverClass package name copyUpTo: $-.
			^ participants
				at: projName
				ifAbsentPut: [ EluSeqProjectParticipant for: projName ] ]
]

{ #category : #'uml writing' }
EluSeqDiagram2 >> openUml [
	PlantUMLBridge webbrowseUML: self uml
]

{ #category : #'as yet unclassified' }
EluSeqDiagram2 >> participantFor: receiverClass [
	"I return the receiver (Participant) for the tally. 
	I apply filter to be able to reduce complexity of the diagram"

	^ participants
		at: receiverClass name
		ifAbsentPut: [ (self filters: receiverClass)
				ifTrue: [ EluSeqClassParticipant for: receiverClass ]
				ifFalse: [ | projName |
					projName := receiverClass package name.	"copyUpTo: $-".
					EluSeqProjectParticipant for: projName ] ]
]

{ #category : #'as yet unclassified' }
EluSeqDiagram2 >> receiverFor: tally [
	"I return the receiver (Participant) for the tally. 
	I apply filter to be able to reduce complexity of the diagram"

	| receiverClass |
	receiverClass := tally theClass.
	^ participants
		at: tally theClass name
		ifAbsentPut: [ (self filters: receiverClass)
				ifTrue: [ EluSeqClassParticipant for: receiverClass ]
				ifFalse: [ | projName |
					projName := receiverClass package name copyUpTo: $-.
					EluSeqProjectParticipant for: projName ] ] 
]

{ #category : #'uml writing' }
EluSeqDiagram2 >> uml [
	| out |
	out := '' writeStream.
	out
		<< '@startuml';
		cr.
	out
		<<
			'skinparam shadowing false
skinparam sequence {
ParticipantFontSize 12
}';
		cr.
	participants do: [ :p | p participantDeclOn: out ].
	calls callDeclOn: out.
	out
		<< '@enduml';
		cr.
	^ out contents
]
