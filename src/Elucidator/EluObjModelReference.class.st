"
!! Purpose

I represent a reference between two entities. 

My ==source== is an association between the source entity, and the selector (instance variable name) The selector is used for putting labels on the references to indicate which variable points where.


"
Class {
	#name : #EluObjModelReference,
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
EluObjModelReference >> arrowType [

	^ ' --> '
]

{ #category : #accessing }
EluObjModelReference >> destination [
	^ destination
]

{ #category : #accessing }
EluObjModelReference >> destination: anEntity [
	destination ifNotNil:[ destination sources remove: self].
	destination := anEntity.
	destination sources add: self.
]

{ #category : #accessing }
EluObjModelReference >> kind [
	^ kind
]

{ #category : #accessing }
EluObjModelReference >> kind: anObject [
	kind := anObject
]

{ #category : #accessing }
EluObjModelReference >> model [
	^ model
]

{ #category : #accessing }
EluObjModelReference >> model: anObject [
	model := anObject
]

{ #category : #printing }
EluObjModelReference >> printOn: stream [ 
	stream << 'ModelRef:( '.
	source key printOn: stream.
	stream << ' -> '.
	destination printOn: stream.
	stream << ') '
]

{ #category : #accessing }
EluObjModelReference >> source [
	^ source
]

{ #category : #accessing }
EluObjModelReference >> source: assocEntitySelector [
	source ifNotNil: [ self sourceEntity destinations remove: self ].
	source := assocEntitySelector.
	source key destinations add: self
]

{ #category : #accessing }
EluObjModelReference >> sourceEntity [
	^ source key
]

{ #category : #accessing }
EluObjModelReference >> sourceSelector [
	^ source value
]
