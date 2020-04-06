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
		'pseudoObject'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #'instance creation' }
ObjDiaModelEntity class >> on: obj in: model [
	| entityClass |
	entityClass := (obj isCollection
		ifTrue: [ ObjDiaModelCollection ]
		ifFalse: [ ObjDiaModelObject ]).
	^ entityClass new
		obj: obj;
		model: model
]

{ #category : #analysis }
ObjDiaModelEntity >> analyzeAccess [ 
	^self subclassResponsibility 
]

{ #category : #accessing }
ObjDiaModelEntity >> categoryName [
	^ self subclassResponsibility 
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
	^ obj class name, self entityId 
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

{ #category : #accessing }
ObjDiaModelEntity >> sources [
	^ sources
]

{ #category : #accessing }
ObjDiaModelEntity >> sources: anObject [
	sources := anObject
]

{ #category : #accessing }
ObjDiaModelEntity >> writeUmlOn: out [
	(out << 'object "' << self printName << '" as ')
		<< self printNameNoSpace;
		cr
]
