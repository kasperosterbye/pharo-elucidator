"
I am the entry class of the Elucidator.
"
Class {
	#name : #Elucidator,
	#superclass : #Object,
	#instVars : [
		'teapot'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'Elucidator-Core'
}

{ #category : #utility }
Elucidator class >> classFromHtmlName: className [
	"meta classes might end with ' class' or '_class'. Return the class"

	((className endsWith: ' class') or: [ className endsWith: '_class' ])
		ifTrue: [ ^ (className allButLast: 6) asClass class ]
		ifFalse: [ ^ className asClass ]
]

{ #category : #elucidation }
Elucidator class >> elucidateBlock: block [
	"I draw a sequence diagram for the block. I timeout ofter 10 sek.
	I assume the block do not need arguments"

	self elucidateBlock: block timeout: 10
]

{ #category : #elucidation }
Elucidator class >> elucidateBlock: block timeout: timeoutSeconds [
	"I draw a sequence diagram for the block. I timeout.
	I assume the block do not need arguments"

	| uml |
	uml := [ EluSeqDiagram new
		fromBlock: block;
		uml ]
		valueWithin: (Duration seconds: (timeoutSeconds min: 90))
		onTimeout: [ nil ].
	uml
		ifNotNil: [ PlantUMLBridge webbrowseUML: uml ]
		ifNil: [ AlertDialogWindow new
				text: 'Diagram construction timed out ';
				openInWorld ]
]

{ #category : #elucidation }
Elucidator class >> elucidateClass: class [
	"I produce a class elucidation web page"

	^ self instance openBrowserOnClass: class
]

{ #category : #elucidation }
Elucidator class >> elucidateObject: obj [
	"I draw an object diagram of range 2 with outset in obj"

	self elucidateObject: obj range: 2
]

{ #category : #elucidation }
Elucidator class >> elucidateObject: obj range: range [
	"I draw an object diagram of range with outset in obj"
	(EluObjModel new range: range from: obj) webbrowseDiagram 
	
]

{ #category : #elucidation }
Elucidator class >> elucidatePackage: packageName [ 
	self instance openBrowserOnPackage: packageName
]

{ #category : #elucidation }
Elucidator class >> elucidateProject: packageName [ 
	self instance openBrowserOnProject: (packageName copyUpTo: $-)
]

{ #category : #utility }
Elucidator class >> htmlNameForClass: aClass [
	"meta classes print as 'String class', which can confuse plantuml."
	^ aClass name copyReplaceAll: ' ' with: '_'
]

{ #category : #'class initialization' }
Elucidator class >> initialize [
	self newInstance 
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

{ #category : #slides }
Elucidator class >> slide1 [
	<sampleInstance>
	^ PRRichTextComposer asText:'!Elucidator
!! Kasper Østerbye
!! May 4th, 2020'
]

{ #category : #slides }
Elucidator class >> slide2 [
	<sampleInstance>
	^ PRRichTextComposer asText:'!Elucidate
!!! (From Merriam Webster)

- to make ''''lucid'''' especially by explanation or analysis
- ''''Lucid:'''' clear to the understanding
- Elucidator: One who ''''elucidates''''
- Elucidation: an act that elucidates
'
]

{ #category : #slides }
Elucidator class >> slide3 [
	<sampleInstance>
	^ PRRichTextComposer asText:'!Status
!!! Prototype / proof of concept

- Finds comments
- Finds help
- Finds examples
- Finds Announcementss
- Can draw diagrams of things in the image

- Should find pragmas somehow
- Should find annotations
- Should find external documentation (on GitHub and in the Pharo books)
'
]

{ #category : #slides }
Elucidator class >> slide4 [
	<sampleInstance>
	^ PRRichTextComposer asText:'!Demo
'
]

{ #category : #slides }
Elucidator class >> slide5 [
	<sampleInstance>
	^ PRRichTextComposer asText:'!Design principles
	
- Wanted to try out integration of webbrowser and image
- Wanted to give overview by gathering lots of info
- Wanted to experiment with presenting large diagrams (object and sequence) of actual info from image. 
'
]

{ #category : #menu }
Elucidator >> about [
	^ 'Elucidate (verb) means: make (something) clear; explain: work such as theirs will help to elucidate this matter | [with clause] : in what follows I shall try to elucidate what I believe the problems to be.'
]

{ #category : #private }
Elucidator >> browseClass: className [
	| cls |
	cls := Elucidator classFromHtmlName: className.
	WorldState defer: [ cls browse ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #private }
Elucidator >> browseClassComment: className [
	WorldState
		defer: [ (Elucidator classFromHtmlName: className ) browse
				withTool: ClyClassCommentEditorToolMorph
				do: [ :tool | tool selectAsMainTab ] ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #private }
Elucidator >> browseHelp: className [
	WorldState defer: [ HelpBrowser openOn: (Elucidator classFromHtmlName:className)  ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #private }
Elucidator >> browseMethod: selector inClass: className [
	| cls |
	cls := Elucidator classFromHtmlName: className.
	WorldState defer: [ (cls lookupSelector: selector asSymbol) browse ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #dispatching }
Elucidator >> dispatch: req [
	| html |
	html := ElucidationBrush on: '' writeStream.
	Elucidation dispatch: req on: html.
	^ ZnResponse new
		statusLine: ZnStatusLine ok;
		entity: (ZnEntity html: html htmlString);
		yourself
]

{ #category : #private }
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
			'seqdiagram/<class>/<example>'
				-> [ :req | EluSeqDiagram diagramRequest: req ];
		GET:
			'objdiagram/<class>/<range>'
				-> [ :req | EluObjModel diagramRequest: req ];
		GET: 'inspect/<model>/<oid>' -> [ :req | EluObjModel inspectRequest: req ];
		GET:
			'browseClassComment/<className>'
				-> [ :req | self browseClassComment: (req at: #className) ];
		GET:
			'browseClass/<className>'
				-> [ :req | self browseClass: (req at: #className) ];
		GET:
			'browseMethod/<className>/<selector>'
				->
					[ :req | self browseMethod: (req at: #selector) inClass: (req at: #className) ];
		GET:
			'helpBrowse/<helpClass>'
				-> [ :req | self browseHelp: (req at: #helpClass) ];
		GET: '/<elucidation>/<scope>/<subject>' -> [ :req | self dispatch: req ];
		start
]

{ #category : #dispatching }
Elucidator >> openBrowserOnClass: class [
	| url |
	url := self httpPrefix , 'all/class/' , class name.
	WebBrowser openOn: url
]

{ #category : #dispatching }
Elucidator >> openBrowserOnPackage: packageName [
	| url |
	url := self httpPrefix , 'all/package/' , packageName.
	WebBrowser openOn: url
]

{ #category : #dispatching }
Elucidator >> openBrowserOnProject: projectName [
	| url |
	url := self httpPrefix , 'all/project/' , projectName.
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

{ #category : #private }
Elucidator >> socketNumber [
	"random socketNumber, just the year and month I wrote this code"
	^ 20203
]

{ #category : #initialization }
Elucidator >> stop [
	teapot stop
]
