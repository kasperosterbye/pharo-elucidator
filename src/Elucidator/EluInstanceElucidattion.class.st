Class {
	#name : #EluInstanceElucidattion,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #elucidation }
EluInstanceElucidattion >> elucidatePackage: subject html: html [
	
]

{ #category : #'as yet unclassified' }
EluInstanceElucidattion >> topTenInstanceClassesIn: projectPrefix [
	"return an ordered collection of classes based on their number of instances in the image.
	return only the first 10.
	look in all classes in all packages which shares the first prefix of projectPrefix"

	| allPackages allClasses top10 |
	allPackages := self
		findPackagesWithPrefix: (projectPrefix copyUpTo: $-).
	allClasses := (allPackages collect: [ :pack | pack definedClasses ])
		flattened.
	top10 := ((allClasses collect: [ :cl | cl -> cl allInstances size ])
		asOrderedCollection sort: [ :a :b | a value > b value ])
		first: (10 min: allClasses size).
	^ top10
]
