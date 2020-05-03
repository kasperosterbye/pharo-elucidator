"
I try to find example code. I look for methods with one of the pragmas mentioned in #findExampleMethods, or whose selector contains the substring 'example'.
"
Class {
	#name : #EluExamplesProjectElucidattion,
	#superclass : #Elucidation,
	#instVars : [
		'project',
		'html',
		'examples'
	],
	#category : #'Elucidator-Core'
}

{ #category : #'helper methods' }
EluExamplesProjectElucidattion >> allClasses [
	^ Object allSubclasses 
]

{ #category : #elucidation }
EluExamplesProjectElucidattion >> analyze [
	examples := self findExampleMethods
		select: [ :meth | project packages includes: meth methodClass package ].
	
]

{ #category : #elucidation }
EluExamplesProjectElucidattion >> contributes [ 
	^ examples isNotEmpty 
]

{ #category : #'helper methods' }
EluExamplesProjectElucidattion >> diagramLinksFor: aClass example: example html: html [
	"Create links to sequence diagram of running the example"

	"create links of the form 'seqdiagram/<class>/<example>'"

	html
		elucidateLink: ' Sequence Diagram for example'
		to: 'seqdiagram/' , aClass name , '/' , example selector
]

{ #category : #elucidation }
EluExamplesProjectElucidattion >> elucidateClass: class html: html [
	| examples |
	examples := self findExampleMethods
		select:
			[ :meth | meth methodClass = class class or: [ meth methodClass inheritsFrom: class class] ].
	examples
		ifEmpty: [ html part: 'No examples in class ' , class name , ' or subclasses'.
			^ self ].
	html part: 'Example code for ' , class name.
	" each item is on the form: pharoLink, class>>method, first line of comment if any"
	html
		ulist: [ examples
				do: [ :method | 
					html
						item: [ html methodBrowseLink: method.
							html << method name.
							(method selector isUnary and: [ method methodClass isMeta ])
								ifTrue:
									[ self diagramLinksFor: method methodClass example: method html: html ] ] ] ]
]

{ #category : #elucidation }
EluExamplesProjectElucidattion >> elucidatePackage: subject html: html [
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
							html << method name.
							method comments
								ifNotEmpty: [ :coms | html << ('. <i>' , coms first lines first , '</i>') ] ] ] ]
]

{ #category : #elucidation }
EluExamplesProjectElucidattion >> elucidateProject: subject html: html [
	| proj examples |
	proj := EluProject fromPackagePrefix: subject.
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
							html << method name.
							(method selector isUnary and: [ method methodClass isMeta ])
								ifTrue:
									[ self diagramLinksFor: method methodClass example: method html: html ] ] ] ]
]

{ #category : #'helper methods' }
EluExamplesProjectElucidattion >> findExampleMethods [
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

{ #category : #'instance creation' }
EluExamplesProjectElucidattion >> html: brush [
	html := brush
]

{ #category : #'instance creation' }
EluExamplesProjectElucidattion >> on: prefix [
	project := EluProject fromPackagePrefix: prefix
]

{ #category : #elucidation }
EluExamplesProjectElucidattion >> renderMe [
	
	html part: 'Example code' id: 'examples'.
	" each item is on the form: pharoLink, class>>method, first line of comment if any"
	html
		ulist: [ examples
				do: [ :method | 
					html
						item: [ html methodBrowseLink: method.
							html << method name.
							(method selector isUnary and: [ method methodClass isMeta ])
								ifTrue:
									[ self diagramLinksFor: method methodClass example: method html: html ] ] ] ]
]

{ #category : #elucidation }
EluExamplesProjectElucidattion >> synopsis [
	examples
		ifNotEmpty: [ html
				tag: 'li'
				do: [ html << '<b>Examples:</b> The project contains '
						<< examples size printString << ' examples. <br>'
						<< 'See more <a href="#examples">further down</a>' ] ]
		ifEmpty: [ html
				tag: 'li'
				do: [ html << '<b>Examples:</b> No examples in project' ]]
]