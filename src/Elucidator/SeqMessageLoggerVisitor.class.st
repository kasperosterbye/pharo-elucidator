"
I am a visitor to visit the MessageLogger
"
Class {
	#name : #SeqMessageLoggerVisitor,
	#superclass : #Object,
	#instVars : [
		'out',
		'logFilters',
		'presentationFilters',
		'lastSender'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #adding }
SeqMessageLoggerVisitor >> addLogFilter: aFilterBlock [
	logFilters addLast: aFilterBlock 
]

{ #category : #adding }
SeqMessageLoggerVisitor >> addPresentationFilter: aPresentationFilter [
	presentationFilters addLast: aPresentationFilter 
]

{ #category : #adding }
SeqMessageLoggerVisitor >> checkLogFilters: aLogEntry [
	^logFilters  allSatisfy: [ :pred | pred value: aLogEntry  ] 
]

{ #category : #adding }
SeqMessageLoggerVisitor >> checkPresentationFilters: aLogEntry [
	^presentationFilters allSatisfy: [ :pred | pred value: aLogEntry  ] 
]

{ #category : #'as yet unclassified' }
SeqMessageLoggerVisitor >> intialize [
	out := String new writeStream.
	logFilters := OrderedCollection new.
]

{ #category : #visiting }
SeqMessageLoggerVisitor >> visit: anEntry [
	(self checkPresentationFilters: anEntry)
		ifTrue: [ self writeUmlCallFor: anEntry ]
		ifFalse: [ lastSender := anEntry sender ].
	(self checkLogFilters: anEntry)
		ifTrue: [ anEntry children do: [ :child | child accept: self ] ]
]

{ #category : #writing }
SeqMessageLoggerVisitor >> writeUmlCallFor: anEntry [
	out 
		<< anEntry sender class name; 
		<< ' -> ';
		<< anEntry receiver class name; 
		<< ': ';
		<< anEntry selector.

]
