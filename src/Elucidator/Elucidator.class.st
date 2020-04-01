Class {
	#name : #Elucidator,
	#superclass : #Object,
	#instVars : [
		'teapot'
	],
	#classInstVars : [
		'instance'
	],
	#category : #Elucidator
}

{ #category : #'as yet unclassified' }
Elucidator class >> elucidatePackage: packageName [ 
	self instance openBrowserOnPackage: packageName
]

{ #category : #accessing }
Elucidator class >> instance [
	instance ifNil: [ instance := self basicNew initialize ].
	^ instance
]

{ #category : #accessing }
Elucidator class >> new [
	self error: 'Use "instance" to get singular instance'
]

{ #category : #accessing }
Elucidator class >> newInstance [
	instance ifNotNil: [ instance stop. instance := nil ].
	^self instance
]

{ #category : #menu }
Elucidator >> about [
	^ 'Elucidate (verb) means: make (something) clear; explain: work such as theirs will help to elucidate this matter | [with clause] : in what follows I shall try to elucidate what I believe the problems to be.'
]

{ #category : #private }
Elucidator >> browseClass: className [
	WorldState defer: [ className asClass browse withTool: ClyClassCommentEditorToolMorph do: [ :tool | tool selectAsMainTab ]  ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #dispatching }
Elucidator >> dispatch: req [
	| html |
	html := ElucidationBrush new
		on: (ZnHtmlOutputStream on: '' writeStream).
	Elucidation dispatch: req on: html.
	^ ZnResponse new
		statusLine: ZnStatusLine ok;
		entity: (ZnEntity html: html htmlString);
		yourself
]

{ #category : #'as yet unclassified' }
Elucidator >> httpPrefix [
	^ 'http://localhost:<1p>/' expandMacrosWith: self socketNumber
]

{ #category : #initialization }
Elucidator >> indexHTML: req [
	^ ZnHtmlOutputStream
		streamContents: [ :html | 
			html
				page: 'Elucidator'
					do: [ html tag: #div class: #main do: [ html tag: #p with: self about ] ];
				tag: #div class: #main do: [ self sample: html ] ]
]

{ #category : #initialization }
Elucidator >> initialize [
	teapot := Teapot configure: {(#port -> self socketNumber)}.
	teapot
		GET:
			'browseClass/<className>'
				-> [ :req | self browseClass: (req at: #className) ];
		GET: '/<elucidation>/<scope>/<subject>' -> [ :req | self dispatch: req ];
		GET: '' -> [ :req | self indexHTML: req ];
		start
]

{ #category : #'as yet unclassified' }
Elucidator >> openBrowserOnPackage: packageName [
	| url |
	url := self httpPrefix , 'all/package/' , packageName.
	WebBrowser openOn: url
]

{ #category : #examples }
Elucidator >> sample [
	^ 'I can elucidate packages or classes. Elucidation of <a href="localhost:20203/all/package/teapot">the package teapot</a>'
]

{ #category : #examples }
Elucidator >> sample: html [
	html
		tag: #p
		do: [ html
				<<
					'I can elucidate packages or classes. Elucidation of <a href="http://localhost:20203/all/package/teapot">the package teapot</a>' ]
]

{ #category : #'as yet unclassified' }
Elucidator >> socketNumber [
	"random socketNumber, just the year and month I wrote this code"
	^ 20203
]

{ #category : #initialization }
Elucidator >> stop [
	teapot stop
]
