Class {
	#name : #EluExamplesElucidattion,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #'helper methods' }
EluExamplesElucidattion >> allClasses [
	^ Object allSubclasses 
]

{ #category : #'as yet unclassified' }
EluExamplesElucidattion >> diagramLinksFor: aClass example: example html: html [
	"Create links to sequence diagram of running the example"

	"create links of the form 'seqdiagram/<class>/<example>'"

	html
		elucidateLink: ' Sequence Diagram for example'
		to: 'seqdiagram/' , aClass name , '/' , example selector
]

{ #category : #elucidation }
EluExamplesElucidattion >> elucidatePackage: subject html: html [
	| rPack examples |
	self error: 'Need to be checked'.
	rPack := self findPackage: subject.
	examples := self findExampleMethods
		select: [ :meth | meth methodClass package = rPack ].
	examples
		ifEmpty: [ html part: 'No examples in package ' , subject.
			^ self ].
	html part: 'Example code'.
	" each item is on the form: pharoLink, class>>method, first line of comment if any"
	html
		ulist: [ examples
				do: [ :method | 
					html
						item: [ html methodBrowseLink: method.
							html raw: method name.
							method comments
								ifNotEmpty: [ :coms | html raw: '. <i>' , coms first lines first , '</i>' ] ] ] ]
]

{ #category : #elucidation }
EluExamplesElucidattion >> elucidateProject: subject html: html [
	| proj examples |
	proj := EluProject fromPackageName: subject.
	examples := self findExampleMethods
		select: [ :meth | proj packages includes: meth methodClass package ].
	examples
		ifEmpty: [ html part: 'No examples in project ' , proj name.
			^ self ].
	html part: 'Example code for ' , proj name.
	" each item is on the form: pharoLink, class>>method, first line of comment if any"
	html
		ulist: [ examples
				do: [ :method | 
					html
						item: [ html methodBrowseLink: method.
							html raw: method name.
							(method selector isUnary and: [ method methodClass isMeta ])
								ifTrue:
									[ self diagramLinksFor: method methodClass example: method html: html ] ] ] ]
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
