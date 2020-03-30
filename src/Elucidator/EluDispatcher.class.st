Class {
	#name : #EluDispatcher,
	#superclass : #Object,
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
EluDispatcher >> findPackage: packageName [
	"find package based on packageName. Ignore case and implementation class"
	| allNames |
	allNames := RPackageOrganizer default packageNames.
	allNames
		do: [ :pName | 
			(pName sameAs: packageName)
				ifTrue: [ ^ RPackageOrganizer default packageNamed: pName ] ].
	^ nil
]
