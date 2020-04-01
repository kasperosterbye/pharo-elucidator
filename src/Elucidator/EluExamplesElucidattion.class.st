Class {
	#name : #EluExamplesElucidattion,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #'helper methods' }
EluExamplesElucidattion >> allClasses [
	^ Object allSubclasses 
]

{ #category : #elucidation }
EluExamplesElucidattion >> elucidatePackage: subject html: html [
	| rPack examples |
	rPack := self findPackage: subject.
	examples := self findExampleMethods
		select: [ :meth | meth methodClass package = rPack ].
	examples
		ifEmpty: [ html section: 'No examples in package ' , subject.
			^ self ].
	html section: 'Example code'.
	" each item is on the form: pharoLink, class>>method, first line of comment if any"
	html
		ulist: [ examples
				do: [ :method | 
					html
						item: [ html methodBrowseLink: method.
							html raw: method name.
							method comments
								ifNotEmpty: [ :coms | html raw: '. <i>' , coms first lines first, '</i>' ] ] ] ]
]

{ #category : #'helper methods' }
EluExamplesElucidattion >> findExampleMethods [
	"return a collecion of compiled methods which contain example code."

	"I look for Pragmas of type: #example, exampleWidget #sampleInstance, #script, script:.
	I look for methods with example in its name"

	| exampleByName examplePragmaNames exampleByPragma |
	examplePragmaNames := #(example exampleWidget sampleInstance).
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
