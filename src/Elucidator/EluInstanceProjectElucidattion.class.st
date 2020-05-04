"
I find information about the instances in the system. Often concrete instances help in the understanding of the general classes. In particular, I am able to help in making object diagrams from those instances.
"
Class {
	#name : #EluInstanceProjectElucidattion,
	#superclass : #Elucidation,
	#instVars : [
		'project',
		'html',
		'instanceExamples'
	],
	#category : #'Elucidator-Core'
}

{ #category : #elucidation }
EluInstanceProjectElucidattion >> analyze [
	instanceExamples  := self topTenInstanceClassesInProject: project.
	
]

{ #category : #elucidation }
EluInstanceProjectElucidattion >> contributes [ 
	^ instanceExamples notEmpty 
]

{ #category : #'as yet unclassified' }
EluInstanceProjectElucidattion >> diagramLinksFor: aClass html: html [
	"Create links to object diagrams for a instance of aClass. make links for range 1 through 5"

	"create links of the form 'objdiagram/<class>/<range>'"

	html << ' Diagrams for random instance. Diagram range: '.
	1 to: 5 do: [ :range | 
		html
			pharoLink: range printString
				to: 'objdiagram/' , aClass name , '/' , range printString;
			<< ' ' ]
]

{ #category : #'instance creation' }
EluInstanceProjectElucidattion >> html: brush [
	html := brush 
]

{ #category : #'instance creation' }
EluInstanceProjectElucidattion >> on: subject [
	project := EluProject fromPackagePrefix: subject 
]

{ #category : #elucidation }
EluInstanceProjectElucidattion >> renderMe [
	
	html part: 'Sample instances ' id: 'instances'.
	html
		ulist: [ instanceExamples 
				do: [ :assoc | 
					html
						item: [ html classBrowseLink: assoc key name.
							html
								<< (assoc key name , ' instances: ' , assoc value printString , '. ').
							self diagramLinksFor: assoc key html: html ] ] ].
	instanceExamples size = 10
		ifTrue: [ html
				par: 'More instantiated classes might exist, only showing the top 10' ]
]

{ #category : #elucidation }
EluInstanceProjectElucidattion >> synopsis [
	html tag: 'li'
	do: [
	html << '<b>Instances:</b> '.
	instanceExamples   
		ifEmpty:  [html << 'no instances of any class in project found in image (It is an application library, not a system library?).' ] 
		ifNotEmpty:  [ html << 'I found instances for: '  
			<< instanceExamples size printString << ' classes (up to 10 picked). '.
	html << 'I have collected class instances for those classes. '.
	html << '<br>See instances <a href="#instances">further down</a>']]
]

{ #category : #'helper methods' }
EluInstanceProjectElucidattion >> topTenInstanceClassesInProject: project [
	"return an ordered collection of class -> number of instances in the project
	return only the first 10 sorted by number of instances
	look in all classes in all packages in project"

	| allClasses top10 |
	allClasses := project classes.
	top10 := ((allClasses collect: [ :cl | cl -> cl allInstances size ])
		asOrderedCollection sort: [ :a :b | a value > b value ])
		first: (10 min: allClasses size).
	^ top10 select: [ :assoc | assoc value > 0 ]
]
