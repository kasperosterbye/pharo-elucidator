"
I represent a sequence diagram which is build from by executing a block and capturing a MessageTally.

In order to prevent the diagram from becoming too big, I apply two techniques:

A maxSize, which is the max number of calls to be included in the diagram.
A filter, which specify which classes should be included in the diagram.

The filter is a collection of package name (or package name prefixes). A class is included in a diagram if the package of a class matches one of the names in the filter. If a class does not match the filter, the class is not included in the diagram, but its package is included instead (in the hope to reduce the number of actors in the diagram).

Example2 shows the result of applying a filter.
"
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
	"I create a svg sequence diagram from a request of the form:
	seqdiagram/<class>/<method>?size=value.
	I handle two kinds of methods - examples and test methods.	"
	| size class example project diagram uml |
	size := (request at: #size ifAbsent: [ '75' ]) asInteger.
	example := (request at: #example) asSymbol.
	class := ((request at: #class) copyReplaceAll: ' class' with: '')
		asClass.
	project := EluProject fromClass: class.
	diagram := self new.
	diagram
		maxSize: size;
		filter: {project name}.
	WorldState
		defer: [ (class inheritsFrom: TestCase)
				ifTrue: [ diagram fromBlock: [ class run: example ] ]
				ifFalse: [ diagram fromBlock: [ class perform: example ] ].
			uml := diagram uml.
			PlantUMLBridge webbrowseUML: uml ].
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

{ #category : #initialization }
EluSeqDiagram >> initialize [
	maxSize := 150.
	filter := OrderedCollection new.
	
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
					projName := receiverClass package name.
					EluSeqPackageParticipant for: projName ] ]
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
