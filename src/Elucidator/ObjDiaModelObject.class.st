"
!! Purpose
I represent an object with instance variables (as opposed to a collection)
"
Class {
	#name : #ObjDiaModelObject,
	#superclass : #ObjDiaModelEntity,
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #analysis }
ObjDiaModelObject >> analyzeAccess [
	| accessors |
	accessors := obj class
		in: [ :c | c allSelectors & c allInstVarNames ].
	accessors do: [ :accessor | self analyzeAccessor: accessor ]
]

{ #category : #analysis }
ObjDiaModelObject >> analyzeAccessor: accessor [
	| object |
	object := obj instVarNamed: accessor.
	(model buildFilter buildCheck: object)
		ifTrue: [ self destinationsAt: accessor put: object ].
]

{ #category : #accessing }
ObjDiaModelObject >> categoryName [
	^ obj class category
]

{ #category : #writing }
ObjDiaModelObject >> writeRefsOn: out [
	"This method writes the code for both the arrow, and for the seletors of the entity"
	| mark |
	mark := 1.
	destinations 
		do: [ :ref | 
			out << self printNameNoSpace << ' "' << mark printString << '" ' << ref arrowType
				<< ref destination printNameNoSpace << String cr.
			out << self printNameNoSpace << ' : ' << mark printString << ') '
				<< ref sourceSelector << String cr.
			mark := mark + 1 ]
]

{ #category : #writing }
ObjDiaModelObject >> writeUmlOn: out [
	out << 'package ' << self categoryName << ' {' ;cr.
		super writeUmlOn: out.
		out << '}'; cr
]
