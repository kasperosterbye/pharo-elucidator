Class {
	#name : #EluSeqDiagram,
	#superclass : #Object,
	#instVars : [
		'calls',
		'participants',
		'filter',
		'maxSize'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #'as yet unclassified' }
EluSeqDiagram class >> diagramRequest: request [
	| size class example project diagram uml |
	size := (request at: #size ifAbsent: [ '200' ]) asInteger.
	example := (request at: #example) asSymbol.
	class := ((request at: #class) copyReplaceAll: ' class' with: '')
		asClass.
	project := EluProject fromClass: class.
	diagram := self new.
	diagram
		maxSize: size;
		filter: {project name}.
	(class inheritsFrom: TestCase)
		ifTrue: [ diagram fromBlock: [ class run: example ] ]
		ifFalse: [ diagram fromBlock: [ class perform: example ] ].
	uml := diagram uml. 
	PlantUMLBridge webbrowseUML: uml.
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #examples }
EluSeqDiagram class >> example1 [
	<example>
	self new
		filter: {'Kernel'};
		fromBlock: [ 5 factorial ];
		openUml
]

{ #category : #examples }
EluSeqDiagram class >> example2 [
	<example>
	self new
		filter: {'Kernel'};
		fromBlock: [ Float pi printString ];
		openUml
]

{ #category : #accessing }
EluSeqDiagram >> filter: anObject [
	filter := anObject
]

{ #category : #accessing }
EluSeqDiagram >> filters: receiverClass [
	| receiverPackageName |
	(filter isNil or: [ filter isEmpty ]) ifTrue: [ ^true ].
	receiverPackageName := receiverClass package name.
	^ filter anySatisfy: [ :f | receiverPackageName beginsWith: f ]
]

{ #category : #'instance creation' }
EluSeqDiagram >> fromBlock: block [
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
EluSeqDiagram >> fromTally: tally [
	"I assume maxSize and filter has been set"

	participants := OrderedDictionary new.
	calls := tally receivers allButFirst"skip the first call, which is due to the way Tallies are buildt"
		collect: [ :rec | 
			EluSeqCall new
				sender: (self participantFor: tally theClass);
				fromTally: rec in: self ]	
]

{ #category : #accessing }
EluSeqDiagram >> maxSize: anObject [
	maxSize := anObject
]

{ #category : #private }
EluSeqDiagram >> needToTruncate [
	"I truncate the diagram if it grows too big. Utility method to make #visit:to: shorter"

	maxSize := maxSize - 1.
	maxSize = 0
		ifTrue: [ ^ String cr ,+ '== diagram truncated from here ==' ,+ String cr ].
	maxSize <= 0
		ifTrue: [ ^ ' ' ].
	^''
]

{ #category : #'as yet unclassified' }
EluSeqDiagram >> oldreceiverFor: tally [
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
EluSeqDiagram >> openUml [
	PlantUMLBridge webbrowseUML: self uml
]

{ #category : #'as yet unclassified' }
EluSeqDiagram >> participantFor: receiverClass [
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
EluSeqDiagram >> receiverFor: tally [
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
EluSeqDiagram >> uml [
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
	calls do: [ :c | c callDeclOn: out ].
	out
		<< '@enduml';
		cr.
	^ out contents
]
