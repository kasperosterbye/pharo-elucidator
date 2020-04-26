"
!! Purpose
I represent an object with instance variables (as opposed to a collection)
"
Class {
	#name : #EluObjModelObject,
	#superclass : #EluObjModelEntity,
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #'as yet unclassified' }
EluObjModelObject >> analyzeDestinationRange [
	| accessors |
	obj isClass
		ifTrue: [ ^ self ].
	accessors := obj class
		in: [ :c | c allSelectors & c allInstVarNames ].
	accessors
		do: [ :accessor | 
			| destination |
			destination := model entityFor: (obj instVarNamed: accessor).
			destination range: (range - 1 max: destination range).
			self destinationsAt: accessor putEntity: destination ]
]

{ #category : #accessing }
EluObjModelObject >> categoryName [
	^ obj class category
]

{ #category : #testing }
EluObjModelObject >> modelsCollection [
	^ false
]

{ #category : #accessing }
EluObjModelObject >> packageName [
	^ obj class package name
]

{ #category : #writing }
EluObjModelObject >> printName [
	obj isNumber
		ifTrue: [ ^ obj printString contractTo: 12 ]
		ifFalse: [ ^ obj class name ]
]

{ #category : #writing }
EluObjModelObject >> writeRefsOn: out [
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
EluObjModelObject >> writeUmlOn: out [
	(out << 'package ' << self packageHtmlLink)
		<< ' {';
		cr.
	super writeUmlOn: out.
	out
		<< '}';
		cr
]
