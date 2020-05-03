"
I am an elucidator which tries to find relevant comments package. I am not very clever about this.

I look for the package comment (in manifest class), and the classes with the most comments.
"
Class {
	#name : #EluCommentsPackageElucidation,
	#superclass : #Elucidation,
	#instVars : [
		'allMethods',
		'packageName',
		'packageComment',
		'classComments',
		'html'
	],
	#category : #'Elucidator-Core'
}

{ #category : #elucidation }
EluCommentsPackageElucidation >> analyze [
	"render the commentry for the package onto html"

	| rPack   |
	rPack := self findPackage: packageName.
	rPack ifNil: [ ^ self ].
	packageComment := self packageCommentForPackage: rPack.
	classComments := self classCommentsForPackage: rPack.
]

{ #category : #'helper methods' }
EluCommentsPackageElucidation >> classCommentsForPackage: aRPackage [
	"I return an ordered collection of class associated to its comment, longest comments first, only first 10"

	^ ((aRPackage definedClasses
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ]) takeFirst: 10
]

{ #category : #'as yet unclassified' }
EluCommentsPackageElucidation >> contributes [
	^packageComment notEmpty | classComments notEmpty
]

{ #category : #elucidation }
EluCommentsPackageElucidation >> elucidatePackage: packageName html: html [
	"render the commentry for the package onto html"

	| rPack packageComment classComments |
	rPack := self findPackage: packageName.
	rPack
		ifNil: [ html part: 'No package named: ' , packageName.
			^ self ].
	html part: 'Comments for ', packageName.
	packageComment := self packageCommentForPackage: rPack.
	classComments := self classCommentsForPackage: rPack.
	packageComment
		ifEmpty: [ html heading: 'No package comment for ' , packageName ]
		ifNotEmpty: [ self renderPackageComment: packageComment on: html ].
	self renderClassComments: classComments on: html
]

{ #category : #'instance creation' }
EluCommentsPackageElucidation >> html: brush [
	html := brush
]

{ #category : #'instance creation' }
EluCommentsPackageElucidation >> on: subject [ 
	packageName := subject
]

{ #category : #'helper methods' }
EluCommentsPackageElucidation >> packageCommentForPackage: aRPackage [
	^aRPackage packageComment

]

{ #category : #rendering }
EluCommentsPackageElucidation >> renderClassComments [
	"classComments is a collection of association, mapping classes to their comments"

	classComments ifNotEmpty: [ html heading: 'Class comments' ].
	classComments
		do: [ :pair | 
			pair value
				ifNotEmpty: [ "do not print empty comments"
					html
						section: [ html classBrowseLink: pair key name.
							html << pair key name << ' comment:' ];
						par: pair value ] ]
]

{ #category : #elucidation }
EluCommentsPackageElucidation >> renderMe [
	"render the commentry for the package onto html"

	html part: 'Comments' id: #comments.
	packageComment
		ifEmpty: [ html heading: 'No package comment for ' , packageName ]
		ifNotEmpty: [ self renderPackageComment ].
	self renderClassComments
]

{ #category : #rendering }
EluCommentsPackageElucidation >> renderPackageComment [
	packageComment
		ifEmpty: [ html heading: 'No package comment for ' , packageName ]
		ifNotEmpty: [ html
				heading: 'Package comment: ';
				par: packageComment ] 
]

{ #category : #elucidation }
EluCommentsPackageElucidation >> synopsis [

	html << '<li><b>Comments:</b> '.
	packageComment  
		ifEmpty:  [html << 'no package comment for ' << packageName << '. ' ] 
		ifNotEmpty:  [ html << 'package comment: '  << packageComment << '. '].
	html << '<br>I have collected class comments for these classes from the package: '.
	html << ((classComments collect: [ :c | c key]) joinUsing: ', ') << '. '.
	html << '<br>See class comments <a href="#comments">further down</a></li>'
	
]
