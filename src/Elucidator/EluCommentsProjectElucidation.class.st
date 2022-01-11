"
I am an elucidator which tries to find relevant comments package. I am not very clever about this.

I look for the package comment (in manifest class), and the classes with the most comments.
"
Class {
	#name : #EluCommentsProjectElucidation,
	#superclass : #Elucidation,
	#instVars : [
		'allMethods',
		'classComments',
		'html',
		'packageComments',
		'project'
	],
	#category : #'Elucidator-Core'
}

{ #category : #elucidation }
EluCommentsProjectElucidation >> analyze [
	"render the commentry for the project onto html"

	packageComments := project packages 
		select: [ :pack | pack packageComment notEmpty  ] 
		thenCollect: [ :pack | pack -> pack packageComment ].
	classComments := ((project classes
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ]) first: 10.
]

{ #category : #'helper methods' }
EluCommentsProjectElucidation >> classCommentsForPackage: aRPackage [
	"I return an ordered collection of class associated to its comment, longest comments first, only first 10"

	^ ((aRPackage definedClasses
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ]) takeFirst: 10
]

{ #category : #'as yet unclassified' }
EluCommentsProjectElucidation >> contributes [
	^packageComments notEmpty | classComments notEmpty
]

{ #category : #'instance creation' }
EluCommentsProjectElucidation >> html: brush [
	html := brush
]

{ #category : #'instance creation' }
EluCommentsProjectElucidation >> on: subject [ 
	project := EluProject fromPackagePrefix: subject 
]

{ #category : #'helper methods' }
EluCommentsProjectElucidation >> packageCommentForPackage: aRPackage [
	^aRPackage packageComment

]

{ #category : #rendering }
EluCommentsProjectElucidation >> renderClassComments [
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
EluCommentsProjectElucidation >> renderMe [
	"render the commentry for the package onto html"

	html part: 'Comments' id: #comments.
	packageComments
		ifEmpty: [ html heading: 'No package comments'  ]
		ifNotEmpty: [ self renderPackageComments ].
	self renderClassComments
]

{ #category : #rendering }
EluCommentsProjectElucidation >> renderPackageComment [
	packageComments
		ifEmpty: [ html heading: 'No package comment for ' , project ]
		ifNotEmpty: [ html
				heading: 'Package comment: ';
				par: packageComments ] 
]

{ #category : #rendering }
EluCommentsProjectElucidation >> renderPackageComments [
	packageComments
		ifEmpty: [ html heading: 'No package comments' ]
		ifNotEmpty: [ 
			packageComments do: [ :packageComment |
			html
				heading: 'Package comment for ', packageComment key name;
				par: packageComment value] ]
]

{ #category : #elucidation }
EluCommentsProjectElucidation >> synopsis [

	html << '<li><b>Comments:</b> '.
	packageComments  
		ifEmpty:  [html << 'no package comment for ' << project name << '. ' ] 
		ifNotEmpty:  [ html << 'I found package comments for: '  
			<< ((packageComments collect: [:p | p key name]) joinUsing: ', ') << '. '].
	html << '<br>I have collected class comments for these classes from the package (10 longest comments): '.
	html << ((classComments collect: [ :c | c key]) joinUsing: ', ') << '. '.
	html << '<br>See comments <a href="#comments">further down</a></li>'
	
]
