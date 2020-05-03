"
I represent a project - a collection of packages.
I am rather simple minded. A project is all the packages which shares a common prefix before the first $-. 
For example, the 'Debugger' project consists of packages:
Debugger-Actions, Debugger-Filters, Debugger-Model, etc.
"
Class {
	#name : #EluProject,
	#superclass : #Object,
	#instVars : [
		'packages',
		'projectName'
	],
	#category : #'Elucidator-Core'
}

{ #category : #'instance creation' }
EluProject class >> fromClass: aClass [
	^ self fromPackage: aClass package
]

{ #category : #'instance creation' }
EluProject class >> fromPackage: rPack [
	^ self fromPackagePrefix: rPack name
]

{ #category : #'instance creation' }
EluProject class >> fromPackagePrefix: pName [
	^ self new fromPackagePrefix: pName
]

{ #category : #accessing }
EluProject >> classes [
	^ (packages collect: [ :p | p definedClasses ]) flattened
]

{ #category : #'instance creation' }
EluProject >> fromPackagePrefix: packName [
	| allNames |
	projectName := packName copyUpTo: $-.
	allNames := RPackageOrganizer default packageNames
		select: [ :name | (name copyUpTo: $-) sameAs: projectName ].
	packages := allNames
		collect: [ :pName | RPackageOrganizer default packageNamed: pName ]
]

{ #category : #accessing }
EluProject >> name [
	^ projectName 
]

{ #category : #accessing }
EluProject >> packages [
	^ packages
]
