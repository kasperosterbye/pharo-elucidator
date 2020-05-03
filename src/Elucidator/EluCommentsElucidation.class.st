"
I am an elucidator which tries to find relevant comments in the system. I am not very clever about this.

For classes, I find the class comment, and the methods with the longest comments.

For packages, I look for the package comment (in manifest class), and the classes with the most comments.

For projects, I look for the packages with the most comments.
"
Class {
	#name : #EluCommentsElucidation,
	#superclass : #Elucidation,
	#instVars : [
		'allMethods'
	],
	#category : #'Elucidator-KeptForFutureUpdate'
}

{ #category : #'helper methods' }
EluCommentsElucidation >> classCommentsForClass: class [
	"I return a collection of class associated to its comment for class and all its subclasses, ordered by size of comment"

	^ (class allSubclasses
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ]
]

{ #category : #'helper methods' }
EluCommentsElucidation >> classCommentsForPackage: aRPackage [
	"I return an ordered collection of class associated to its comment, longest comments first"

	^ (aRPackage definedClasses
		collect: [ :cl | cl -> cl instanceSide organization classComment ])
		asOrderedCollection
		sort: [ :p1 :p2 | p1 value size > p2 value size ]
]

{ #category : #elucidation }
EluCommentsElucidation >> elucidateClass: class html: html [
	| classComments |
	html part: 'Comments for class (and subclasses of) ' , class name.
	classComments := self classCommentsForClass: class.
	self renderClassComments: classComments on: html.
	self renderMethodComments: (self methodCommentsForClass: class) on: html 
]

{ #category : #elucidation }
EluCommentsElucidation >> elucidatePackage: packageName html: html [
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

{ #category : #'as yet unclassified' }
EluCommentsElucidation >> findNumberOfSendersOf: selector [
	"private method. Assumes allMethod is cleared elsewhere at the right times"

	allMethods := allMethods
		ifNil: [ (Object allSubclasses collect: [ :c | c methods ]) flattened ].
	^ allMethods count: [ :m | (m hasLiteral: selector) ]
]

{ #category : #'helper methods' }
EluCommentsElucidation >> methodCommentsForClass: class [
	"I return a collection of association selector->number of senders of class, sorted by number of senders"

	allMethods := nil.
	^ ((class selectors \ class superclass allSelectors
			collect: [ :sel | 
				sel -> (self findNumberOfSendersOf: sel) ])
			asOrderedCollection 
				sort: [ :m1 :m2 | m1 value > m2 value ])
					in: [ :col | 
						(col first: (10 min: col size)) 
							collect: [:pair | class >> pair key -> pair value ]]
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

{ #category : #rendering }
EluCommentsElucidation >> renderMethodComments: methodComments on: html [
	"methodComments is a collection of association, mapping methods to their comments"

	methodComments ifNotEmpty: [ html heading: '10 most used methods' ].
	html
		ulist: [ (methodComments first: (10 min: methodComments size))
				do: [ :methAndSenders | 
					| method |
					method := methAndSenders key.
					html
						item: [ html methodBrowseLink: method.
							html htmlStream << ' ' << method printString << ' (senders: '
								<< methAndSenders value printString << ') '
						 << (method comment ifNil: [ 'not commented' ]) ] ]]
]

{ #category : #rendering }
EluCommentsElucidation >> renderPackageComment: packageComment on: html [
	html
		heading: 'Package comment: ';
		par: packageComment
]
