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
		'range',
		'kind'
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
	"do not analyze sources for destinations"
	self isDestination ifTrue: [ self analyzeDestinationRange ].
	self isSource ifTrue: [ self analyzeSourceRange ]
		
		
]

{ #category : #analysis }
EluObjModelEntity >> analyzeSourceRange [
	| sourceObjects |
	(obj class category beginsWith: 'Kernel')
		ifTrue: [ ^ self ].
	sourceObjects := obj pointersToExcept: {self}.
	sourceObjects := sourceObjects
		reject: [ :s | s class package name = #Kernel ].
	sourceObjects := sourceObjects first: (sourceObjects size min: 7).
	sourceObjects
		do: [ :object | 
			| sourceEntity |
			sourceEntity := model entityFor: object.
			sourceEntity range: (range - 1 max: sourceEntity range).
			sourceEntity setAsSource.
			object isCollection
				ifTrue: [ sourceEntity destinationsAt: 'Index' putEntity: self ]
				ifFalse: [ object class allInstVarNames
						detect: [ :ivName | (object instVarNamed: ivName) = obj ]
						ifFound: [ :ivName | sourceEntity destinationsAt: ivName putEntity: self ] ] ]
]

{ #category : #accessing }
EluObjModelEntity >> color [
	"return a plantuml color depending on kind"

	kind = #destination
		ifTrue: [ ^ ' #lightgreen' ].
	kind = #source
		ifTrue: [ ^ ' #lightblue' ].
	kind = #root
		ifTrue: [ ^ ' #BBBBBB' ]
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
	destinations := OrderedCollection new.
	range := 0
]

{ #category : #testing }
EluObjModelEntity >> isCollection [
	^ false
]

{ #category : #accessing }
EluObjModelEntity >> isDestination [
	"kind can be #root, #source or #destination"

	^ kind ~= #source
]

{ #category : #accessing }
EluObjModelEntity >> isSource [
	"kind can be #root, #source or #destination"
	^ kind ~= #destination 
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

{ #category : #initialization }
EluObjModelEntity >> setAsDestination [
	kind ifNil: [kind := #destination]
]

{ #category : #initialization }
EluObjModelEntity >> setAsRoot [
	kind := #root
]

{ #category : #initialization }
EluObjModelEntity >> setAsSource [
	kind ifNil: [ 
	kind := #source]
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

	out << 'object "' << self url << '" as ' << self printNameNoSpace
		<< self color;
		cr
]
