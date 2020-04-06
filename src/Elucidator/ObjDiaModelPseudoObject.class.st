"
!! Purpose

I represent a collapsed sub-graph of the model.

I am a pseudoObject which represent the transitive closeure of entities which do not pass the presentation filter.

The closure is computed in ==closeReachOf:==, and utilize two collections of unvisited entities. It is possible to tell if an entity has already been included in the closure by checking if the entity's ==pseudoObject== is nonNil
"
Class {
	#name : #ObjDiaModelPseudoObject,
	#superclass : #ObjDiaModelCollection,
	#instVars : [
		'unvisitedSources',
		'unvisitedDestinations'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #accessing }
ObjDiaModelPseudoObject >> categoryName [
	^ 'Stuff'
]

{ #category : #initialization }
ObjDiaModelPseudoObject >> closeReachOf: entity [
	"I am the main closure loop of the presentation filter"
	unvisitedSources addAll: entity sources.
	unvisitedDestinations addAll: entity destinations.
	[ unvisitedSources notEmpty | unvisitedDestinations notEmpty ]
		whileTrue: [ unvisitedSources notEmpty
				ifTrue: [ unvisitedSources removeLast includeSourceInPseudo: self ]
				ifFalse: [ unvisitedDestinations removeLast includeDestinationInPseudo: self ] ]
]

{ #category : #initialization }
ObjDiaModelPseudoObject >> initialize [
	super initialize.
	unvisitedSources := OrderedCollection new.
	unvisitedDestinations := OrderedCollection new.
]

{ #category : #testing }
ObjDiaModelPseudoObject >> isPartOfPresentation [
	^true
]

{ #category : #printing }
ObjDiaModelPseudoObject >> printOn: stream [
	stream << ' PseudoObject '.
]

{ #category : #removing }
ObjDiaModelPseudoObject >> removeRefsToSelf [
	(self sources copy select: [ :ref | ref source key = self ])
		do: [ :ref | ref removeFromModel ].
	(self destinations copy select: [ :ref | ref destination = self ])
		do: [ :ref | ref removeFromModel ]
]

{ #category : #accessing }
ObjDiaModelPseudoObject >> unvisitedDestinations [
	^ unvisitedDestinations
]

{ #category : #accessing }
ObjDiaModelPseudoObject >> unvisitedDestinations: anObject [
	unvisitedDestinations := anObject
]

{ #category : #accessing }
ObjDiaModelPseudoObject >> unvisitedSources [
	^ unvisitedSources
]

{ #category : #accessing }
ObjDiaModelPseudoObject >> unvisitedSources: anObject [
	unvisitedSources := anObject
]

{ #category : #accessing }
ObjDiaModelPseudoObject >> writeUmlOn: out [

	out << 'package Stuff as ' << self printNameNoSpace << ' <<Cloud>> {' ;cr.
	out << '}'; cr
]
