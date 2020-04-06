"
!! Purpose
I represent a collection object. 
"
Class {
	#name : #ObjDiaModelCollection,
	#superclass : #ObjDiaModelEntity,
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #analysis }
ObjDiaModelCollection >> analyzeAccess [
	"analyze the elements in my objects collection. Special case - do not analyze inside strings!"
	
	obj isString | obj isText
		ifTrue: [ ^ self ].
	obj
		do: [ :elem |  self analyzeElement: elem]
]

{ #category : #analysis }
ObjDiaModelCollection >> analyzeElement: elem [
	( model buildFilter buildCheck: elem)
		ifTrue: [ self destinationsAt: 'Index' put: elem ].
	
]

{ #category : #accessing }
ObjDiaModelCollection >> categoryName [
	sources
		ifEmpty: [ destinations
				ifEmpty: [ ^ 'Unclassified' ]
				ifNotEmpty: [ ^ destinations first destination obj class category ] ]
		ifNotEmpty:[
	^ sources first source key obj class category]
]

{ #category : #testing }
ObjDiaModelCollection >> isCollection [ 
	^true
]

{ #category : #testing }
ObjDiaModelCollection >> isPartOfPresentation [
	^ self sourceEntities allSatisfy: [ :ent | ent isPartOfPresentation  ]
]

{ #category : #analysis }
ObjDiaModelCollection >> preparePresentation [
	pseudoObject ifNotNil: [ ^ self ].
	self isPartOfPresentation 
		ifFalse:[
			self removeFromPresentation
		]
]

{ #category : #removing }
ObjDiaModelCollection >> reduceToSingletonRefs [
	"I have but a single element in my collection. Change my source references to point to that element"
	| singletonDest singletonRef|
	singletonRef := destinations first.
	singletonDest := singletonRef destination.
	sources copy do: [ :ref | 
		ref destination: singletonDest; kind: #singleton.
		singletonDest sources add: ref ].
	singletonDest sources remove: singletonRef .
	model entities removeKey: self obj.
	model refs remove: singletonRef
]

{ #category : #removing }
ObjDiaModelCollection >> removeFromModel [
	sources copy do: [ :ref | ref removeFromModel ].
	destinations copy do: [ :ref | ref removeFromModel ].
	model entities removeKey: self obj
]

{ #category : #writing }
ObjDiaModelCollection >> writeRefsOn: out [
	destinations
		do: [ :ref | 
			out << self printNameNoSpace << ref arrowType 
				<< ref destination printNameNoSpace << String cr ] 
]

{ #category : #writing }
ObjDiaModelCollection >> writeUmlOn: out [
	out << 'package ' << self categoryName << ' {' ;cr.
		super writeUmlOn: out.
		out << '}'; cr
]
