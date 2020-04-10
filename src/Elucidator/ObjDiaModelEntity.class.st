"
!! Purpose
I represent an object in the model.

I keep track of which sources (incoming references) and which destinations (outgoing references) I have.




"
Class {
	#name : #ObjDiaModelEntity,
	#superclass : #Object,
	#instVars : [
		'sources',
		'destinations',
		'obj',
		'model',
		'entityId',
		'pseudoObject',
		'range'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #'instance creation' }
ObjDiaModelEntity class >> on: obj in: model [
	| entityClass |
	entityClass := obj isCollection
		ifTrue: [ ObjDiaModelCollection ]
		ifFalse: [ ObjDiaModelObject ].
	^ entityClass new
		obj: obj;
		model: model
]

{ #category : #'as yet unclassified' }
ObjDiaModelEntity >> analyzeDestinationRange [
	self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
ObjDiaModelEntity >> analyzeRange [
	"I add sources and destinations to this entity"

	range <= 0
		ifTrue: [ ^ self ].
	self analyzeDestinationRange
]

{ #category : #'as yet unclassified' }
ObjDiaModelEntity >> analyzeSourceRange [
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

{ #category : #'as yet unclassified' }
ObjDiaModelEntity >> categoryHtmlLink [
	| categoryName |
	categoryName := self categoryName.
	^ '"[[http://localhost:20203/all/package/' , categoryName , ' '
		, categoryName , ']]"'
]

{ #category : #accessing }
ObjDiaModelEntity >> categoryName [
	^ self subclassResponsibility 
]

{ #category : #accessing }
ObjDiaModelEntity >> destinationEntities [
	^ destinations  collect: [ :ref | ref destination  ]
]

{ #category : #accessing }
ObjDiaModelEntity >> destinationObjects [
	^ self destinations collect: [ :ref | ref destination obj ]
]

{ #category : #accessing }
ObjDiaModelEntity >> destinations [
	^ destinations
]

{ #category : #accessing }
ObjDiaModelEntity >> destinations: anObject [
	destinations := anObject
]

{ #category : #accessing }
ObjDiaModelEntity >> destinationsAt: accessor put: value [
	"add an outgoing ref from me to the entity for value"
	| destination ref |
	destination := model entityFor: value.
	ref := ObjDiaModelReference new
		source: self -> accessor;
		destination: destination;
		model: model.
	model refs add: ref.
]

{ #category : #accessing }
ObjDiaModelEntity >> destinationsAt: accessor putEntity: destination [
	"add an outgoing ref from me to the entity for value"
	| ref |
	ref := ObjDiaModelReference new
		source: self -> accessor;
		destination: destination;
		model: model.
	model refs add: ref.
]

{ #category : #accessing }
ObjDiaModelEntity >> entityId [
	entityId ifNil:[ entityId := model nextEntityNumber].
	^ entityId 
]

{ #category : #analysis }
ObjDiaModelEntity >> includeInPseudo: pseudo [
	pseudoObject ifNotNil: [ ^ self ].
	(model presentationFilter check: self)
		ifFalse: [ pseudoObject := pseudo.
			pseudoObject unvisitedSources addAll: sources.
			pseudoObject unvisitedDestinations addAll: destinations ] 
]

{ #category : #initialization }
ObjDiaModelEntity >> initialize [
	sources := OrderedCollection new.
	destinations  := OrderedCollection  new.
	range := 0.
	
]

{ #category : #testing }
ObjDiaModelEntity >> isCollection [
	^ false
]

{ #category : #testing }
ObjDiaModelEntity >> isPartOfPresentation [
	pseudoObject ifNotNil: [ ^false ].
	^ (model presentationFilter presentationCheck: obj)
]

{ #category : #accessing }
ObjDiaModelEntity >> model [
	^ model
]

{ #category : #accessing }
ObjDiaModelEntity >> model: anObject [
	model := anObject
]

{ #category : #testing }
ObjDiaModelEntity >> modelsCollection [
	self subclassResponsibility 
]

{ #category : #accessing }
ObjDiaModelEntity >> obj [
	^ obj
]

{ #category : #accessing }
ObjDiaModelEntity >> obj: anObject [
	obj := anObject
]

{ #category : #analysis }
ObjDiaModelEntity >> preparePresentation [
	(model presentationFilter presentationCheck: obj)
		ifTrue: [ ^ self ].
	pseudoObject ifNotNil: [ ^ self ].
	self removeFromPresentation
]

{ #category : #writing }
ObjDiaModelEntity >> printName [
	^ obj class name
]

{ #category : #writing }
ObjDiaModelEntity >> printNameNoSpace [
	^ (obj class name copyReplaceAll: ' ' with: '_') , self entityId
]

{ #category : #printing }
ObjDiaModelEntity >> printOn: stream [
	stream << 'Model of:( '.
	obj printOn: stream.
	stream << ') '
]

{ #category : #accessing }
ObjDiaModelEntity >> pseudoObject [
	^ pseudoObject
]

{ #category : #accessing }
ObjDiaModelEntity >> pseudoObject: anObject [
	pseudoObject := anObject
]

{ #category : #accessing }
ObjDiaModelEntity >> range [
	^ range
]

{ #category : #accessing }
ObjDiaModelEntity >> range: anObject [
	range := anObject
]

{ #category : #removing }
ObjDiaModelEntity >> removeFromPresentation [
	"Assumes I need to be removed from the model.
	Helper method called from preparePresentation"

	pseudoObject := ObjDiaModelPseudoObject new.
	pseudoObject
		obj: pseudoObject;
		model: model.
	model entities at: pseudoObject put: pseudoObject.
	model entities removeKey: obj.
	pseudoObject closeReachOf: self.
	pseudoObject removeRefsToSelf
]

{ #category : #accessing }
ObjDiaModelEntity >> sourceEntities [
	^ sources collect: [ :ref | ref source key ]
]

{ #category : #'as yet unclassified' }
ObjDiaModelEntity >> sourceObjects [
	^ self destinations collect: [ :ref | ref destination obj ]
]

{ #category : #accessing }
ObjDiaModelEntity >> sources [
	^ sources
]

{ #category : #accessing }
ObjDiaModelEntity >> sources: anObject [
	sources := anObject
]

{ #category : #writing }
ObjDiaModelEntity >> url [
	^ '[[http://localhost:20203/inspect/' , model id , '/'
		, self printNameNoSpace , ' ' , self printName , ']]'
]

{ #category : #accessing }
ObjDiaModelEntity >> writeUmlOn: out [
	(out << 'object "' << self url<< '" as ')
		<< self printNameNoSpace;
		cr
]
