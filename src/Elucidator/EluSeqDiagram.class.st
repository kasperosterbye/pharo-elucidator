"
I am a class which produce a plant uml source code based on the tally from a block.

See example on class side
"
Class {
	#name : #EluSeqDiagram,
	#superclass : #Object,
	#instVars : [
		'packageFilter',
		'savedSenders',
		'skipSelectors',
		'theTally',
		'maxSize'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #'as yet unclassified' }
EluSeqDiagram class >> diagramRequest: request [
	| size class example |
	size := (request at: #size ifAbsent: [ '35' ]) asInteger.
	example := (request at: #example) asSymbol.
	class := ((request at: #class) copyReplaceAll: ' class' with: '')
		asClass.
	PlantUMLBridge
		webbrowseUML:
			((class inheritsFrom: TestCase)
				ifTrue: [ self new
						size: size;
						tallyFor: [ class run: example ];
						uml ]
				ifFalse: [ self new
						size: size;
						tallyFor: [ class perform: example ];
						uml ])
]

{ #category : #examples }
EluSeqDiagram class >> example1 [
	<example>
	self 
		seqDiagramFor: [ Float pi printString] 
		in: {'Kernel-Numbers'. 'Collection-Strings'} 
		skipSelectors: #(on:).
]

{ #category : #examples }
EluSeqDiagram class >> example2 [
	<example>
		self seqDiagramFor: [ 4 factorial ].
]

{ #category : #'as yet unclassified' }
EluSeqDiagram class >> seqDiagramFor: aBlock [ 
	^ self seqDiagramFor: aBlock in: { '' }.
]

{ #category : #'as yet unclassified' }
EluSeqDiagram class >> seqDiagramFor: aBlock in: packageList [
	^ self seqDiagramFor: aBlock in: packageList  skipSelectors: #()
]

{ #category : #'as yet unclassified' }
EluSeqDiagram class >> seqDiagramFor: aBlock in: packageList skipSelectors: selectors [
	| ulmSource |
	ulmSource := self new
		tallyFor: aBlock;
		uml: packageList skipSelectors: selectors.
	^ PlantUMLBridge webbrowseUML: ulmSource
]

{ #category : #private }
EluSeqDiagram >> catchAllName [
	^'Something'
]

{ #category : #initialization }
EluSeqDiagram >> initialize [
	savedSenders := OrderedCollection new.
	packageFilter := OrderedCollection new.
	savedSenders addLast: self catchAllName.
	maxSize := 100
]

{ #category : #private }
EluSeqDiagram >> normalized: aClass [ 
	^(packageFilter  anySatisfy: [ :pn | pn isEmpty or: [aClass category beginsWith: pn]])
		ifTrue: [ aClass name asString copyReplaceAll: ' ' with: '_'] 
		ifFalse: [ ^ self catchAllName  ]
	
]

{ #category : #accessing }
EluSeqDiagram >> size: size [ 
	maxSize := size.
]

{ #category : #'instance creation' }
EluSeqDiagram >> tallyFor: aBlock [
	^ theTally := MessageTally
		tallySendsTo: nil
		inBlock: aBlock
		showTree: false
		closeAfter: false
		openResultWindow: false
]

{ #category : #'uml writing' }
EluSeqDiagram >> uml [
	^ self uml: {} skipSelectors: {}
]

{ #category : #'uml writing' }
EluSeqDiagram >> uml: packages [
	^ self uml: packages  skipSelectors: { }
]

{ #category : #'uml writing' }
EluSeqDiagram >> uml: packages skipSelectors: selectors [
	| outStream |
	packageFilter := packages.
	skipSelectors := selectors , #(tallyFor:).
	outStream := '' writeStream.
	outStream
		<< '@startuml';
		cr.
	outStream
		<<
			'skinparam shadowing false
skinparam sequence {
ParticipantFontSize 12
}';
		cr.
	(outStream << '-> ' << (self normalized: theTally theClass) << ': ')
		<< theTally method selector;
		cr.
	outStream << (self visit: theTally).
	outStream
		<< '@enduml';
		cr.
	^ outStream contents
]

{ #category : #'uml writing' }
EluSeqDiagram >> visit: aTally [
	| senderName receivers receiversText |
	senderName := self normalized: aTally theClass.
	receivers := aTally receivers
		reject: [ :tally | skipSelectors includes: tally method selector ].
	receiversText := (receivers
		collect: [ :rec | self visit: aTally to: rec ]) joinUsing: ''.
	receiversText
		ifNotEmpty: [ senderName = self catchAllName
				ifFalse: [ ^ 'Activate ' , senderName , String cr , receiversText
						, 'Deactivate ' , senderName , String cr
					"'return return ', aTally method selector, String cr" ]
				ifTrue: [ ^ receiversText ] ].
	^ ''
]

{ #category : #'uml writing' }
EluSeqDiagram >> visit: sender to: aTally [
	| senderName receiverName selector out arrow |
	maxSize := maxSize - 1.
	maxSize = 0
		ifTrue: [ ^ String cr , '== diagram truncated from here ==' , String cr ].
	maxSize < 0
		ifTrue: [ ^ '' ].
	senderName := self normalized: sender theClass.
	receiverName := self normalized: aTally theClass.
	selector := aTally method selector.
	arrow := (sender theClass inheritsFrom: aTally method methodClass)
		ifFalse: [ ' -> ' ]
		ifTrue: [ ' -->> ' ].
	out := '' writeStream.
	receiverName = self catchAllName
		ifFalse: [ senderName = self catchAllName
				ifTrue: [ savedSenders ifNotEmpty: [ senderName := savedSenders removeLast ].
					selector := '...' , selector ].
			out << senderName << arrow << receiverName << ': ' << selector
				<< String cr ]
		ifTrue: [ senderName = self catchAllName
				ifFalse: [ savedSenders addLast: senderName ] ].
	^ out contents , (self visit: aTally)
]
