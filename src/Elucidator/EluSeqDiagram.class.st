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
	| size class example project diagram uml |
	size := (request at: #size ifAbsent: [ '200' ]) asInteger.
	example := (request at: #example) asSymbol.
	class := ((request at: #class) copyReplaceAll: ' class' with: '')
		asClass.
	project := EluProject fromClass: class.
	diagram := self new.
	diagram
		size: size;
		addPackageFilter: {project name}.
	(class inheritsFrom: TestCase)
				ifTrue: [ diagram tallyFor: [ class run: example ] ]
				ifFalse: [ diagram tallyFor: [ class perform: example ] ].
	uml := diagram uml.
	PlantUMLBridge
		webbrowseUML: uml
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

{ #category : #accessing }
EluSeqDiagram >> addPackageFilter: anObject [
	packageFilter := anObject
]

{ #category : #private }
EluSeqDiagram >> catchAllName [
	^'Something'
]

{ #category : #initialization }
EluSeqDiagram >> initialize [
	savedSenders := OrderedCollection new.
	packageFilter := OrderedCollection new.
	skipSelectors := OrderedCollection new.
	savedSenders addLast: self catchAllName.
	maxSize := 100
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

{ #category : #private }
EluSeqDiagram >> normalized: aClass [
	^ (packageFilter isEmpty
		or: [ packageFilter
				anySatisfy: [ :pn | pn isEmpty or: [ aClass category beginsWith: pn ] ] ])
		ifTrue: [ '"[[http://localhost:20203/browseClass/'
				, (aClass name asString copyReplaceAll: ' ' with: '_') , ' '
				, aClass name asString , ']]" ' ]
		ifFalse: [ ^ aClass package name copyReplaceAll: ' ' with: '_']
]

{ #category : #private }
EluSeqDiagram >> oldnormalized: aClass [
	^ (packageFilter isEmpty
		or: [ packageFilter
				anySatisfy: [ :pn | pn isEmpty or: [ aClass category beginsWith: pn ] ] ])
		ifTrue: [ '"[[http://localhost:20203/browseClass/'
				, (aClass name asString copyReplaceAll: ' ' with: '_') , ' '
				, aClass name asString , ']]" ' ]
		ifFalse: [ ^ self catchAllName ]
]

{ #category : #'uml writing' }
EluSeqDiagram >> olduml [
	^ self uml: {} skipSelectors: {}
]

{ #category : #'uml writing' }
EluSeqDiagram >> olduml: packages skipSelectors: selectors [
	| out |
	packageFilter := packages.
	skipSelectors := selectors , #(tallyFor:).
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
	(out << '-> ' << (self normalized: theTally theClass) << ': ')
		<< theTally method selector;
		cr.
	out << (self visit: theTally).
	out
		<< '@enduml';
		cr.
	^ out contents
]

{ #category : #accessing }
EluSeqDiagram >> packageFilter [
	^ packageFilter
]

{ #category : #accessing }
EluSeqDiagram >> packageFilter: anObject [
	packageFilter := anObject
]

{ #category : #'as yet unclassified' }
EluSeqDiagram >> selectorLink: selector class: receiverClass [
	^ '[[http://localhost:20203/browseMethod/'
		, (receiverClass name asString copyReplaceAll: ' ' with: '_') , '/'
		, selector , ' ' , selector , ']]'
]

{ #category : #accessing }
EluSeqDiagram >> size: size [ 
	maxSize := size.
]

{ #category : #accessing }
EluSeqDiagram >> skipSelectors [
	^ skipSelectors
]

{ #category : #accessing }
EluSeqDiagram >> skipSelectors: anObject [
	skipSelectors := anObject
]

{ #category : #'instance creation' }
EluSeqDiagram >> tallyFor: aBlock [
	theTally := MessageTally
		tallySendsTo: nil
		inBlock: aBlock
		showTree: false
		closeAfter: false
		openResultWindow: false
]

{ #category : #'uml writing' }
EluSeqDiagram >> uml [
	| out |
	skipSelectors := skipSelectors , #(tallyFor:).
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
	(out << '-> ' << (self normalized: theTally theClass) << ': ')
		<< theTally method selector;
		cr.
	out << (self visit: theTally).
	out
		<< '@enduml';
		cr.
	^ out contents
]

{ #category : #'uml writing' }
EluSeqDiagram >> uml: packages [
	^ self uml: packages  skipSelectors: { }
]

{ #category : #'uml writing' }
EluSeqDiagram >> uml: packages skipSelectors: selectors [
	| out |
	packageFilter := packages.
	skipSelectors := selectors , #(tallyFor:).
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
	(out << '-> ' << (self normalized: theTally theClass) << ': ')
		<< theTally method selector;
		cr.
	out << (self visit: theTally).
	out
		<< '@enduml';
		cr.
	^ out contents
]

{ #category : #'uml writing' }
EluSeqDiagram >> visit: aTally [
	"I write the activation coresponding to aTally. 
	I write the box, the #visit:to: writes each call."

	| senderName receivers receiversText |
	senderName := self normalized: aTally theClass.
	receivers := aTally receivers
		reject: [ :tally | skipSelectors includes: tally method selector ].
	receiversText := (receivers
		collect: [ :rec | self visit: aTally to: rec ]) joinUsing: ''.
	receiversText
		ifNotEmpty: [ senderName = self catchAllName
				ifFalse: [ ^ 'Activate ' ,+ senderName ,+ String cr ,+ receiversText
						,+ 'Deactivate ' ,+ senderName ,+ String cr
					"'return return ', aTally method selector, String cr" ]
				ifTrue: [ ^ receiversText ] ].
	^ ''
]

{ #category : #'uml writing' }
EluSeqDiagram >> visit: sender to: tally [
	"I write the tally arrow from sender.
	If max size is reached, I truncate the diagram."

	| senderName receiverName selector arrow out |
	senderName := self normalized: sender theClass.
	receiverName := self normalized: tally theClass.
	selector := tally method selector.
	arrow := (sender theClass inheritsFrom: tally method methodClass)
		ifFalse: [ ' -> ' ]
		ifTrue: [ ' -->> ' ].
	out := ''.
	receiverName = self catchAllName
		ifFalse: [ 
			self needToTruncate ifNotEmpty: [ :str | ^ str ].
	
			senderName = self catchAllName
				ifTrue: [ savedSenders ifNotEmpty: [ senderName := savedSenders removeLast ].
					selector := '...' ,+ selector ].
			out := out ,+ senderName ,+ arrow ,+ receiverName ,+ ': '
				,+ (self selectorLink: selector class: tally theClass)
				,+ String cr ]
		ifTrue: [ senderName = self catchAllName
				ifFalse: [ savedSenders addLast: senderName ] ].
	^ out ,+ (self visit: tally)
]
