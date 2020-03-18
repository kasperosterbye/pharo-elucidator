Class {
	#name : #Elucidator,
	#superclass : #Object,
	#category : #Elucidator
}

{ #category : #'to clean later' }
Elucidator >> allClasses [
	^ Object allSubclasses 
]

{ #category : #examples }
Elucidator >> findExampleMethods [
	"return a collecion of compiled methods which contain example code."

	"I look for Pragmas of type: #example, exampleWidget #sampleInstance, #script, script:.
	I look for methods with example in its name"

	| exampleByName examplePragmaNames exampleByPragma |
	examplePragmaNames := #(example exampleWidget sampleInstance script script:).
	exampleByPragma := (Pragma allInstances
		select: [ :pragma | examplePragmaNames includes: pragma selector ])
		collect: [ :pragma | pragma method ].
	exampleByName := (self allClasses
		collect: [ :cl | 
			cl methods
				select:
					[ :meth | meth selector includesSubstring: 'example' caseSensitive: false ] ])
		flattened.
	^ (exampleByName , exampleByPragma) asSet asOrderedCollection
]

{ #category : #'as yet unclassified' }
Elucidator >> packageCommentFor: aClass [
	aClass package packageComment ifNotEmpty: [ :com | ^ com ].
	^ ((aClass package definedClasses
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ])
]
