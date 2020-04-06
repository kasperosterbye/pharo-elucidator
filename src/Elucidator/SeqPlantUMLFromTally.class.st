"
I am a class which produce a plant uml source code based on the tally from a block.

See example on class side
"
Class {
	#name : #SeqPlantUMLFromTally,
	#superclass : #Object,
	#instVars : [
		'packageFilter',
		'savedSenders',
		'skipSelectors'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #examples }
SeqPlantUMLFromTally class >> example1 [
	<example>
	self 
		seqDiagramFor: [ Float pi printString] 
		in: {'Kernel-Numbers'. 'Collection-Strings'} 
		skipSelectors: #(on:).
]

{ #category : #examples }
SeqPlantUMLFromTally class >> example2 [
	<example>
		self seqDiagramFor: [ 4 factorial ].
]

{ #category : #'as yet unclassified' }
SeqPlantUMLFromTally class >> seqDiagramFor: aBlock [ 
	^ self seqDiagramFor: aBlock in: { '' }.
]

{ #category : #'as yet unclassified' }
SeqPlantUMLFromTally class >> seqDiagramFor: aBlock in: packageList [
	^ self seqDiagramFor: aBlock in: packageList  skipSelectors: #()
]

{ #category : #'as yet unclassified' }
SeqPlantUMLFromTally class >> seqDiagramFor: aBlock in: packageList skipSelectors: selectors [
	|  ulmSource |
	ulmSource := self new umlForBlock: aBlock  in: packageList  skipSelectors: selectors .
	^ PlantUMLBridge webbrowseUML:  ulmSource.
]

{ #category : #'as yet unclassified' }
SeqPlantUMLFromTally >> catchAllName [
	^'Something'
]

{ #category : #initialization }
SeqPlantUMLFromTally >> initialize [
	savedSenders := OrderedCollection new.
	savedSenders addLast: self catchAllName.
	
]

{ #category : #'as yet unclassified' }
SeqPlantUMLFromTally >> normalized: aClass [ 
	^(packageFilter  anySatisfy: [ :pn | pn isEmpty or: [aClass category beginsWith: pn]])
		ifTrue: [ aClass name asString copyReplaceAll: ' ' with: '_'] 
		ifFalse: [ ^ self catchAllName  ]
	
]

{ #category : #'instance creation' }
SeqPlantUMLFromTally >> tallyFor: aBlock [
	^ (MessageTally 
			tallySendsTo: nil 
			inBlock: aBlock 
			showTree: false 
			closeAfter: false 
			openResultWindow: false
		) .
]

{ #category : #'instance creation' }
SeqPlantUMLFromTally >> umlForBlock: aBlock in: packages [
	^ self umlForBlock: aBlock in:  packages skipSelectors: #()
	
	
	
	
]

{ #category : #'instance creation' }
SeqPlantUMLFromTally >> umlForBlock: aBlock in: packages skipSelectors: selectors [
	|outStream tally|
	packageFilter := packages.
	skipSelectors := selectors, #(tallyFor:).
	tally := self tallyFor: aBlock.
	outStream := '' writeStream.
	outStream << '@startuml';cr.
	outStream << 'skinparam shadowing false
skinparam sequence {
ParticipantFontSize 12
}'; cr.
	outStream << '-> ' << (self normalized: tally theClass ) << ': ' << tally method selector;cr.
	outStream << (self visit: tally).
	outStream << '@enduml';cr.
	^outStream contents
	
	
	
	
]

{ #category : #accessing }
SeqPlantUMLFromTally >> visit: aTally [
	| senderName receivers receiversText|
	senderName := (self normalized: aTally theClass).
	receivers := aTally receivers reject: [:tally | skipSelectors includes: tally method selector ].
	receiversText := (receivers  collect: [ :rec | self visit: aTally to: rec ]) joinUsing: ''.
	receiversText ifNotEmpty: [ 
		senderName = self catchAllName 
			ifFalse:  [
				^'Activate ' , senderName, String cr,
			 	receiversText,
				'Deactivate ', senderName, String cr
				"'return return ', aTally method selector, String cr"]
			ifTrue: [ ^receiversText  ]
	].
	^''.
]

{ #category : #accessing }
SeqPlantUMLFromTally >> visit: sender to: aTally [
	| senderName receiverName selector out arrow|
	senderName := self normalized: sender theClass.
	receiverName :=  self normalized: aTally theClass.
	selector := aTally method selector.
	
	arrow := (sender theClass inheritsFrom:  aTally method methodClass)
		ifFalse: [  ' -> ' ]
		ifTrue: [ ' -->> ' ].
	out := '' writeStream .
	(receiverName  = self catchAllName)
		ifFalse: [
			(senderName = self catchAllName)
				ifTrue: [ savedSenders ifNotEmpty: [senderName := savedSenders removeLast]. 
							selector := '...', selector ].
			out 
				<< senderName 
				<< arrow
				<< receiverName
				<< ': '
				<< selector
				<< String cr.]
		ifTrue: [
			(senderName = self catchAllName)
				ifFalse: [savedSenders addLast: senderName]].
	^ out contents, (self visit: aTally)
]
