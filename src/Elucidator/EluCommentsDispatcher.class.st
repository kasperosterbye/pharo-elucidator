Class {
	#name : #EluCommentsDispatcher,
	#superclass : #EluDispatcher,
	#category : #'Elucidator-Comments'
}

{ #category : #'as yet unclassified' }
EluCommentsDispatcher >> classCommentsForPackage: aRPackage [
			
	^ (aRPackage definedClasses
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ]
]

{ #category : #'as yet unclassified' }
EluCommentsDispatcher >> commentPackage: packageName html: html [
	"render the commentry for the package onto html"

	| rPack packageComment classComments |
	rPack := self findPackage: packageName.
	packageComment := self packageCommentForPackage: rPack.
	classComments := self classCommentsForPackage: rPack.
	packageComment
		ifEmpty: [ html heading: 'No package comment for ' , packageName ]
		ifNotEmpty: [ self renderPackageComment: packageComment on: html ].
	self renderClassComments: classComments on: html
]

{ #category : #'as yet unclassified' }
EluCommentsDispatcher >> packageCommentForPackage: aRPackage [
	aRPackage packageComment 
		ifEmpty: [ ^'no package comment' ]
		ifNotEmpty: [ :com | ^ com ].

]

{ #category : #rendering }
EluCommentsDispatcher >> renderClassComments: classComments on: html [
	"classComments is a collection of association, mapping classes to their comments"

	classComments
		do: [ :pair | 
			pair value
				ifNotEmpty: [ "do not print empty comments"
					html
						heading: [ (html classBrowseLink: pair key). html htmlStream << ' comment:' ];
						par: pair value ] ]
]

{ #category : #rendering }
EluCommentsDispatcher >> renderPackageComment: packageComment on: html [
	html
		heading: 'Package comment: ';
		par: packageComment
]
