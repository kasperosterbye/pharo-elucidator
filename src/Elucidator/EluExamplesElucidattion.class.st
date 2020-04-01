Class {
	#name : #EluExamplesElucidattion,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #'to clean later' }
EluExamplesElucidattion >> allClasses [
	^ Object allSubclasses 
]

{ #category : #examples }
EluExamplesElucidattion >> findExampleMethods [
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
