"
!! Purpose
I am a message logger. I work somewhat similar to MessageTally, creating a trace of all messages sendt from executing a block given to me as parameter in ==logBlock:==.
"
Class {
	#name : #SeqMessageLogger,
	#superclass : #Object,
	#instVars : [
		'log'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #visiting }
SeqMessageLogger >> accept: aVisitor [
	^ log accept: aVisitor
]

{ #category : #'as yet unclassified' }
SeqMessageLogger >> logBlock: aBlock [
	| prev |
	prev := aBlock.
	thisContext sender
		runSimulated: aBlock
		contextAtEachStep: [ :current | 
			current willReturn
				ifTrue: [ self logReturn: current ]
				ifFalse: [ (current ~= prev and: [ prev sender notNil ])
						ifTrue: [ self logCall: current ] ].
			prev := current ]
]

{ #category : #'as yet unclassified' }
SeqMessageLogger >> logCall: aContext [
	| entry |
	entry := SeqMessageLoggerEntry new
		sender: aContext sender receiver;
		receiver: aContext receiver;
		selector: aContext methodSelector;
		arguments: ([aContext arguments] on: Exception do: [ #() ]);
		yourself.
	log ifNotNil: [log addChild: entry].
	log := entry.
]

{ #category : #'as yet unclassified' }
SeqMessageLogger >> logReturn: aContext [
| entry |
	entry := SeqMessageLoggerEntry new
		sender: aContext sender receiver;
		receiver: aContext receiver;
		selector: #'^';
		arguments: { aContext top };
		yourself.
	log parent 
		ifNotNil: [ :p | log := p ]
]
