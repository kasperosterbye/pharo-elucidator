Class {
	#name : #EluCommentsElucidation,
	#superclass : #Elucidation,
	#category : #Elucidator
}

{ #category : #'helper methods' }
EluCommentsElucidation >> classCommentsForPackage: aRPackage [
			
	^ (aRPackage definedClasses
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ]
]

{ #category : #elucidation }
EluCommentsElucidation >> elucidatePackage: packageName html: html [
	"render the commentry for the package onto html"

	| rPack packageComment classComments |
	rPack := self findPackage: packageName.
	rPack
		ifNil: [ html heading: 'No package named: ' , packageName.
			^ self ].
	packageComment := self packageCommentForPackage: rPack.
	classComments := self classCommentsForPackage: rPack.
	packageComment
		ifEmpty: [ html heading: 'No package comment for ' , packageName ]
		ifNotEmpty: [ self renderPackageComment: packageComment on: html ].
	self renderClassComments: classComments on: html
]

{ #category : #'helper methods' }
EluCommentsElucidation >> packageCommentForPackage: aRPackage [
	aRPackage packageComment 
		ifEmpty: [ ^'no package comment' ]
		ifNotEmpty: [ :com | ^ com ].

]

{ #category : #rendering }
EluCommentsElucidation >> renderClassComments: classComments on: html [
	"classComments is a collection of association, mapping classes to their comments"

	classComments ifNotEmpty: [ html part: 'Class comments' ].
	classComments
		do: [ :pair | 
			pair value
				ifNotEmpty: [ "do not print empty comments"
					html
						heading: [ html classBrowseLink: pair key.
							html htmlStream << pair key name << ' comment:' ];
						par: pair value ] ]
]

{ #category : #rendering }
EluCommentsElucidation >> renderPackageComment: packageComment on: html [
	html
		heading: 'Package comment: ';
		par: packageComment
]
