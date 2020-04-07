"
!! Purpose

I represent a reference between two entities. 

My ==source== is an association between the source entity, and the selector (instance variable name - same thing by design.) The selector is used for putting labels on the references to indicate which variable points where.


"
Class {
	#name : #ObjDiaModelReference,
	#superclass : #Object,
	#instVars : [
		'source',
		'destination',
		'kind',
		'model'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #accessing }
ObjDiaModelReference >> arrowType [
	kind = #singleton 
		ifTrue: [ ^ ' ..> ' ].
	^ ' --> '
]

{ #category : #accessing }
ObjDiaModelReference >> destination [
	^ destination
]

{ #category : #accessing }
ObjDiaModelReference >> destination: anEntity [
	destination ifNotNil:[ destination sources remove: self].
	destination := anEntity.
	destination sources add: self.
]

{ #category : #analysis }
ObjDiaModelReference >> includeDestinationInPseudo: pseudo [
	| destinationEntity |
	destinationEntity := self destination.
	"skip if source already has been visited"
	destinationEntity pseudoObject ifNotNil: [ ^self  ].
	self source: pseudo -> 'Index'.
	(model presentationFilter presentationCheck: destinationEntity obj)
		ifTrue: [ self source: pseudo -> 'Index' ]
		ifFalse: [ destinationEntity pseudoObject: pseudo.
			model entities removeKey: destinationEntity obj.
			pseudo unvisitedSources addAll: destinationEntity sources.
			pseudo unvisitedDestinations addAll: destinationEntity destinations ]
]

{ #category : #analysis }
ObjDiaModelReference >> includeSourceInPseudo: pseudo [
	| sourceEntity |
	sourceEntity := self sourceEntity.
	"skip if source has already been visited"
	sourceEntity pseudoObject ifNotNil: [ ^ self removeFromModel  ].
	self destination: pseudo.
	(model presentationFilter presentationCheck: sourceEntity obj)
		ifTrue: [ self destination: pseudo ]
		ifFalse: [ sourceEntity pseudoObject: pseudo.
			model entities removeKey: sourceEntity obj.
			pseudo unvisitedSources addAll: sourceEntity sources.
			pseudo unvisitedDestinations addAll: sourceEntity destinations ]
]

{ #category : #accessing }
ObjDiaModelReference >> kind [
	^ kind
]

{ #category : #accessing }
ObjDiaModelReference >> kind: anObject [
	kind := anObject
]

{ #category : #accessing }
ObjDiaModelReference >> model [
	^ model
]

{ #category : #accessing }
ObjDiaModelReference >> model: anObject [
	model := anObject
]

{ #category : #printing }
ObjDiaModelReference >> printOn: stream [ 
	stream << 'ModelRef:( '.
	source key printOn: stream.
	stream << ' -> '.
	destination printOn: stream.
	stream << ') '
]

{ #category : #removing }
ObjDiaModelReference >> removeFromModel [
	"remove this ref from model"
	source key destinations remove: self.
	destination sources remove: self.
	model refs remove: self
]

{ #category : #accessing }
ObjDiaModelReference >> source [
	^ source
]

{ #category : #accessing }
ObjDiaModelReference >> source: assocEntitySelector [
	source ifNotNil: [ self sourceEntity destinations remove: self ].
	source := assocEntitySelector.
	source key destinations add: self
]

{ #category : #accessing }
ObjDiaModelReference >> sourceEntity [
	^ source key
]

{ #category : #accessing }
ObjDiaModelReference >> sourceSelector [
	^ source value
]
