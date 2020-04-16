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

{ #category : #'as yet unclassified' }
Elucidator class >> elucidateBlock: block [
	"I draw a sequence diagram for the block. I timeout ofter 10 sek.
	I assume the block do not need arguments"

	self elucidateBlock: block timeout: 10
]

{ #category : #'as yet unclassified' }
Elucidator class >> elucidateBlock: block timeout: timeoutSeconds [
	"I draw a sequence diagram for the block. I timeout.
	I assume the block do not need arguments"

	| uml |
	uml := [ EluSeqDiagram new
		tallyFor: block;
		uml ]
		valueWithin: (Duration seconds: (timeoutSeconds min: 90))
		onTimeout: [ nil ].
	uml
		ifNotNil: [ PlantUMLBridge webbrowseUML: uml ]
		ifNil: [ AlertDialogWindow new
				text: 'Diagram construction timed out ';
				openInWorld ]
]

{ #category : #'as yet unclassified' }
Elucidator class >> elucidateObject: obj [
	"I draw an object diagram of range 2 with outset in obj"
	self elucidateObject: obj range: 2

	
]

{ #category : #'as yet unclassified' }
Elucidator class >> elucidateObject: obj range: range [
	"I draw an object diagram of range with outset in obj"
	(ObjDiaModel new range: range from: obj) webbrowseDiagram 
	
]

{ #category : #'as yet unclassified' }
Elucidator class >> elucidatePackage: packageName [ 
	self instance openBrowserOnPackage: packageName
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

{ #category : #menu }
Elucidator >> about [
	^ 'Elucidate (verb) means: make (something) clear; explain: work such as theirs will help to elucidate this matter | [with clause] : in what follows I shall try to elucidate what I believe the problems to be.'
]

{ #category : #private }
Elucidator >> browseClass: className [
	| cls |
	cls := (className endsWith: ' class')
		ifTrue: [ (className copyReplaceAll: ' class' with: '') asClass class ]
		ifFalse: [ className asClass ].
	WorldState defer: [ cls browse ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #private }
Elucidator >> browseClassComment: className [
	WorldState
		defer: [ className asClass browse
				withTool: ClyClassCommentEditorToolMorph
				do: [ :tool | tool selectAsMainTab ] ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #private }
Elucidator >> browseHelp: className [
	
	WorldState defer: [ HelpBrowser openOn: className asClass ].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		yourself
]

{ #category : #private }
Elucidator >> browseMethod: selector inClass: className [
	| cls |
	cls := (className endsWith: ' class')
		ifTrue: [ (className copyReplaceAll: ' class' with: '') asClass class ]
		ifFalse: [ className asClass ].
	WorldState defer: [ (cls >> selector asSymbol) browse ].
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
			'seqdiagram/<class>/<example>'
				-> [ :req | EluSeqDiagram  diagramRequest: req ];
		GET:
			'objdiagram/<class>/<range>'
				-> [ :req | ObjDiaModel diagramRequest: req ];
		GET: 'inspect/<model>/<oid>' -> [ :req | ObjDiaModel inspectRequest: req ];
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
