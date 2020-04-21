"
I represent a call in a sequence diagram. I have the sender, the receiver, and the selector of the call.

In addition, I keep all the calls that happens as children of me. 
"
Class {
	#name : #EluSeqCall,
	#superclass : #Object,
	#instVars : [
		'sender',
		'receiver',
		'selector',
		'subCalls',
		'diagram'
	],
	#category : #'Elucidator-SequenceDiagram'
}

{ #category : #'instance creation' }
EluSeqCall class >> fromTally: tally in: diagram [
	^ self new fromTally: tally in: diagram.
]

{ #category : #'as yet unclassified' }
EluSeqCall >> arrow [
	"return the arrow type to be used for this call. 
	For now, just a fixed arrow"
	
	^ ' -> '
]

{ #category : #'as yet unclassified' }
EluSeqCall >> callDeclOn: stream [
	self includeInDiagram
		ifTrue: [ 
			diagram needToTruncate ifNotEmpty: [ :str | stream << str;cr. ^self].
			stream << sender refName << self arrow << receiver refName.
			self selectorDeclOn: stream.
			stream cr.
			subCalls
				ifNotEmpty: [ stream << 'activate ' << receiver refName.
					receiver isClassParticipant
						ifFalse: [ stream << ' #BBBBBB' ].
					stream cr.
					subCalls do: [ :call | call callDeclOn: stream ].
					stream
						<< 'return return';
						cr ] ]
		ifFalse: [ subCalls do: [ :call | call callDeclOn: stream ] ]
]

{ #category : #accessing }
EluSeqCall >> calls [
	^subCalls 
]

{ #category : #'instance creation' }
EluSeqCall >> fromTally: tally in: aDiagram [
	"I assume sender is being set by the one calling me"

	diagram := aDiagram.
	receiver := diagram participantFor: tally theClass.
	selector := tally method selector.
	subCalls := tally receivers
		collect: [ :rec | 
			self class new
				sender: receiver;
				fromTally: rec in: diagram ]
]

{ #category : #'as yet unclassified' }
EluSeqCall >> includeInDiagram [
	(sender isClassParticipant or: [ receiver isClassParticipant ])
		ifTrue: [ ^ true ].
	^ sender refName ~= receiver refName
]

{ #category : #printing }
EluSeqCall >> printOn: aStream [
	aStream << '[' << sender name << ' -> ' << receiver name << ': '
		<< selector << ']'
]

{ #category : #'as yet unclassified' }
EluSeqCall >> selectorDeclOn: stream [
	receiver isClassParticipant
		ifTrue: [ stream << ' : [[http://localhost:20203/browseMethod/'
				<< receiver refName << '/' << selector << ' ' << selector << ']]' ]
		ifFalse: [ stream << ' : ' << selector ]
]

{ #category : #accessing }
EluSeqCall >> sender: anObject [
	sender := anObject
]
