"
!! Purpose
I am a filter which is used to control which objects are included in the ==ObjDiaModel==.

I am created using the methods ==buildFilter:== and  ==presentattionFilter== in the ==ObjDiaModel==.


"
Class {
	#name : #ObjDiaFilter,
	#superclass : #Object,
	#instVars : [
		'includeCategories',
		'excludeCategories',
		'includeClasses',
		'excludeClasses'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #'instance creation' }
ObjDiaFilter class >> new [
	self halt: 'filter algorithm'.
]

{ #category : #checking }
ObjDiaFilter >> buildCheck: anObject [
	| objClass |
	anObject ifNil: [ ^ false ].
	anObject class = ObjDiaModelPseudoObject
		ifTrue: [ ^ true ].
	anObject isString
		ifTrue: [ ^ false ].
	anObject isCollection
		ifTrue: [ ^ anObject isNotEmpty ].
	objClass := anObject class.
	((includeCategories
		anySatisfy: [ :cat | objClass category beginsWith: cat ])
		or: [ includeClasses
				anySatisfy: [ :class | objClass includesBehavior: class ] ])
		ifFalse: [ ^ false ].
	((excludeCategories
		anySatisfy: [ :cat | objClass category beginsWith: cat ])
		or: [ excludeClasses
				anySatisfy: [ :class | objClass includesBehavior: class ] ])
		ifTrue: [ ^ false ].
	^ true
]

{ #category : #copying }
ObjDiaFilter >> copy [
	| copy |
	copy := super copy.
	copy includeCategories: includeCategories copy.
	copy includeClasses: includeClasses copy.
	copy excludeCategories: excludeCategories copy.
	copy excludeClasses: excludeClasses copy.
	^copy
	
]

{ #category : #accessing }
ObjDiaFilter >> excludeCategories [
	^ excludeCategories
]

{ #category : #accessing }
ObjDiaFilter >> excludeCategories: anObject [
	excludeCategories := anObject
]

{ #category : #building }
ObjDiaFilter >> excludeCategory: category [
	excludeCategories add: category 
]

{ #category : #accessing }
ObjDiaFilter >> excludeClasses [
	^ excludeClasses
]

{ #category : #accessing }
ObjDiaFilter >> excludeClasses: anObject [
	excludeClasses := anObject
]

{ #category : #building }
ObjDiaFilter >> excludeSubclassesOf: aClass [
	excludeClasses add: aClass
]

{ #category : #accessing }
ObjDiaFilter >> filterBlock [
	^[:obj | self check: obj]
]

{ #category : #accessing }
ObjDiaFilter >> includeCategories [
	^ includeCategories
]

{ #category : #accessing }
ObjDiaFilter >> includeCategories: anObject [
	includeCategories := anObject
]

{ #category : #building }
ObjDiaFilter >> includeCategory: category [
	includeCategories add: category 
]

{ #category : #accessing }
ObjDiaFilter >> includeClasses [
	^ includeClasses
]

{ #category : #accessing }
ObjDiaFilter >> includeClasses: anObject [
	includeClasses := anObject
]

{ #category : #building }
ObjDiaFilter >> includeSubclassesOf: aClass [
	includeClasses add: aClass
]

{ #category : #initialization }
ObjDiaFilter >> initialize [
	includeCategories := OrderedCollection new.
	excludeCategories := OrderedCollection new.
	includeClasses := OrderedCollection new.
	excludeClasses := OrderedCollection new
]

{ #category : #checking }
ObjDiaFilter >> presentationCheck: anObject [
	| objClass |
	anObject ifNil: [ ^ false ].
	anObject class = ObjDiaModelPseudoObject
		ifTrue: [ ^ true ].
	anObject isString
		ifTrue: [ ^ false ].
	anObject isCollection
		ifTrue: [ ^ anObject isNotEmpty ].
	objClass := anObject class.
	((includeCategories
		anySatisfy: [ :cat | objClass category beginsWith: cat ])
		or: [ includeClasses
				anySatisfy: [ :class | objClass includesBehavior: class ] ])
		ifFalse: [ ^ false ].
	((excludeCategories
		anySatisfy: [ :cat | objClass category beginsWith: cat ])
		or: [ excludeClasses
				anySatisfy: [ :class | objClass includesBehavior: class ] ])
		ifTrue: [ ^ false ].
	^ true
]
