Class {
	#name : #EluInstanceElucidattion,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #elucidation }
EluInstanceElucidattion >> elucidatePackage: subject html: html [
	| top10 |
	top10 := self topTenInstanceClassesIn: subject.
	top10 first value = 0
		ifTrue: [ html part: 'No instances of any class in project ' , (self projectName: subject).
			^ self ].
	html part: 'Instances of classes in project'.
	html
		ulist: [ top10
				do: [ :assoc | 
					html
						item: [ html classBrowseLink: assoc key.
							html
								raw: assoc key name , ' instances: ' , assoc value printString ] ] ]
]

{ #category : #elucidation }
EluInstanceElucidattion >> elucidateProject: subject html: html [
	| top10 project |
	project := EluProject fromPackageName: subject.
	top10 := self topTenInstanceClassesInProject: project.
	top10 first value = 0
		ifTrue: [ html
				part: 'No instances of any class in project ' , (self projectName: subject).
			^ self ].
	html part: 'Instances of classes in ' , project name.
	html
		ulist: [ top10
				do: [ :assoc | 
					html
						item: [ html classBrowseLink: assoc key.
							html
								raw: assoc key name , ' instances: ' , assoc value printString ] ] ].
	top10 last value > 0 
	ifTrue:[ html par: 'More instantiated classes might exist, only showing the top 10' ]
]

{ #category : #'as yet unclassified' }
EluInstanceElucidattion >> topTenInstanceClassesInProject: project [
	"return an ordered collection of class -> number of instances in the project
	return only the first 10 sorted by number of instances
	look in all classes in all packages in project"

	| allClasses top10 |
	allClasses := project classes.
	top10 := ((allClasses
		collect: [ :cl | cl -> cl allInstances size ]) asOrderedCollection
		sort: [ :a :b | a value > b value ])
		first: (10 min: allClasses size).
	^ top10
]
