"
!! Purpose
I represent an object in the model.

I keep track of which sources (incoming references) and which destinations (outgoing references) I have.




"
Class {
	#name : #EluObjModelEntity,
	#superclass : #Object,
	#instVars : [
		'sources',
		'destinations',
		'obj',
		'model',
		'entityId',
		'range'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #'instance creation' }
EluObjModelEntity class >> on: obj in: model [
	| entityClass |
	entityClass := obj isCollection
		ifTrue: [ EluObjModelCollection ]
		ifFalse: [ EluObjModelObject ].
	^ entityClass new
		obj: obj;
		model: model
]

{ #category : #analysis }
EluObjModelEntity >> analyzeDestinationRange [
	self subclassResponsibility 
]

{ #category : #analysis }
EluObjModelEntity >> analyzeRange [
	"I add sources and destinations to this entity"

	range <= 0
		ifTrue: [ ^ self ].
	self analyzeDestinationRange
]

{ #category : #analysis }
EluObjModelEntity >> analyzeSourceRange [
	| sourceObjects accessors|
	(obj class category beginsWith: 'Kernel')
		ifTrue: [ ^self ].
	sourceObjects := obj pointersToExcept: { self. self model entities }.
	sourceObjects := sourceObjects reject: [ :s | s isKindOf: Context ].
	sourceObjects := sourceObjects first: (sourceObjects size min: 15).
	sourceObjects do: [ :object | |sourceEntity|
		accessors := object class allInstVarNames.
		accessors ifEmpty: [ "a collection"
			sourceEntity := model entityFor: object.
			sourceEntity range: (range-1 max: sourceEntity range).
			sourceEntity destinationsAt: 'Index' putEntity: self.
			 ] 
		ifNotEmpty: [ 
			accessors 
				detect: [ :ivName | (object instVarNamed: ivName) = obj ]
				ifFound: [ :ivName | 
					sourceEntity := model entityFor: object.
					sourceEntity range: (range-1 max: sourceEntity range).
					sourceEntity destinationsAt: ivName putEntity: self.
					 ]
			 ]
		]. 
]

{ #category : #accessing }
EluObjModelEntity >> destinationEntities [
	^ destinations  collect: [ :ref | ref destination  ]
]

{ #category : #accessing }
EluObjModelEntity >> destinationObjects [
	^ self destinations collect: [ :ref | ref destination obj ]
]

{ #category : #accessing }
EluObjModelEntity >> destinations [
	^ destinations
]

{ #category : #accessing }
EluObjModelEntity >> destinations: anObject [
	destinations := anObject
]

{ #category : #accessing }
EluObjModelEntity >> destinationsAt: accessor putEntity: destination [
	"add an outgoing ref from me to the entity for value"
	| ref |
	ref := EluObjModelReference new
		source: self -> accessor;
		destination: destination;
		model: model.
	model refs add: ref.
]

{ #category : #accessing }
EluObjModelEntity >> entityId [
	entityId ifNil:[ entityId := model nextEntityNumber].
	^ entityId 
]

{ #category : #initialization }
EluObjModelEntity >> initialize [
	sources := OrderedCollection new.
	destinations  := OrderedCollection  new.
	range := 0.
	
]

{ #category : #testing }
EluObjModelEntity >> isCollection [
	^ false
]

{ #category : #accessing }
EluObjModelEntity >> model [
	^ model
]

{ #category : #accessing }
EluObjModelEntity >> model: anObject [
	model := anObject
]

{ #category : #testing }
EluObjModelEntity >> modelsCollection [
	self subclassResponsibility 
]

{ #category : #accessing }
EluObjModelEntity >> obj [
	^ obj
]

{ #category : #accessing }
EluObjModelEntity >> obj: anObject [
	obj := anObject
]

{ #category : #writing }
EluObjModelEntity >> packageHtmlLink [
	| packageName |
	packageName := self packageName.
	^ '"[[http://localhost:20203/all/package/' , packageName , ' '
		, packageName , ']]"'
]

{ #category : #accessing }
EluObjModelEntity >> packageName [
	^ self subclassResponsibility
]

{ #category : #writing }
EluObjModelEntity >> printName [
	"I print the name of my class - including ' class' if I am a class myself"
	^ obj class name
]

{ #category : #writing }
EluObjModelEntity >> printNameNoSpace [
	"remove the space in 'Point class', and add my entityId numbere - eg. 'Point_classs23' "

	^ (obj class name copyReplaceAll: ' ' with: '_') , self entityId
]

{ #category : #printing }
EluObjModelEntity >> printOn: stream [
	stream << 'Model of:( '.
	obj printOn: stream.
	stream << ') '
]

{ #category : #accessing }
EluObjModelEntity >> range [
	^ range
]

{ #category : #accessing }
EluObjModelEntity >> range: anObject [
	range := anObject
]

{ #category : #accessing }
EluObjModelEntity >> sourceEntities [
	^ sources collect: [ :ref | ref source key ]
]

{ #category : #accessing }
EluObjModelEntity >> sourceObjects [
	^ self destinations collect: [ :ref | ref destination obj ]
]

{ #category : #accessing }
EluObjModelEntity >> sources [
	^ sources
]

{ #category : #accessing }
EluObjModelEntity >> sources: anObject [
	sources := anObject
]

{ #category : #writing }
EluObjModelEntity >> url [
	"create a link in markup: '[[url anchor text]]'"
	^ '[[http://localhost:20203/inspect/' , model id , '/'
		, self printNameNoSpace , ' ' , self printName , ']]'
]

{ #category : #accessing }
EluObjModelEntity >> writeUmlOn: out [
	"produce 'object URL as ID"
	(out << 'object "' << self url << '" as ')
		<< self printNameNoSpace;
		cr
]
