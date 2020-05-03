Class {
	#name : #EluInstanceElucidattion,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
EluInstanceElucidattion >> diagramLinksFor: aClass html: html [
	"Create links to object diagrams for a instance of aClass. make links for range 1 through 5"

	"create links of the form 'objdiagram/<class>/<range>'"

	html << ' Diagrams for random instance. Diagram range: '.
	1 to: 5 do: [ :range | 
		html
			elucidateLink: range printString
				to: 'objdiagram/' , aClass name , '/' , range printString;
			<< ' ' ]
]

{ #category : #elucidation }
EluInstanceElucidattion >> elucidateClass: class html: html [
	| instances |
	instances := class allSubInstances.
	instances
		ifEmpty: [ html part: 'No instances of class in image'.
			^ self ].
	self diagramLinksFor: class html: html
]

{ #category : #elucidation }
EluInstanceElucidattion >> elucidatePackage: subject html: html [
	| top10 |
	top10 := self topTenInstanceClassesIn: subject.
	top10 first value = 0
		ifTrue: [ html
				part: 'No instances of any class in project ' , (self projectName: subject).
			^ self ].
	html part: 'Instances of classes in project'.
	html
		ulist: [ top10
				do: [ :assoc | 
					html
						item: [ html classBrowseLink: assoc key name.
							html
								<< (assoc key name , ' instances: ' , assoc value printString) ] ] ]
]

{ #category : #elucidation }
EluInstanceElucidattion >> elucidateProject: subject html: html [
	| top10 project |
	project := EluProject fromPackagePrefix: subject.
	top10 := self topTenInstanceClassesInProject: project.
	top10
		ifEmpty: [ html
				part: 'No instances of any class in project ' , (self projectName: subject).
			^ self ].
	html part: 'Instances of classes in ' , project name.
	html
		ulist: [ top10
				do: [ :assoc | 
					html
						item: [ html classBrowseLink: assoc key name.
							html
								<< (assoc key name , ' instances: ' , assoc value printString , '. ').
							self diagramLinksFor: assoc key html: html ] ] ].
	top10 size = 10
		ifTrue: [ html
				par: 'More instantiated classes might exist, only showing the top 10' ]
]

{ #category : #'helper methods' }
EluInstanceElucidattion >> topTenInstanceClassesInProject: project [
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
