"
I am an extension of the build in html brush. I add a few extras like heading types and pharo browse links.
"
Class {
	#name : #ElucidationBrush,
	#superclass : #ZnHtmlOutputStream,
	#category : #'Elucidator-Core'
}

{ #category : #accessing }
ElucidationBrush class >> style [
	^ '<style>
table {
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    border-collapse: collapse;
    width: 100%;
}

table td, #customers th {
    border: 1px solid #ddd;
    padding: 3px;
}

table tr:nth-child(even){background-color: #f2f2f2;}

table tr:hover {background-color: #ddd;}

table th {
    padding: 12px;
    padding-bottom: 12px;
    text-align: left;
    background-color: #4CAF50;
    color: white;
}
a.button {
    -webkit-appearance: button;
    -moz-appearance: button;
    appearance: button;
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    text-decoration: none;
    padding: 12px;
    text-align: center;
    background-color: #4CAF50;
    color: initial;
}
body {
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    padding-bottom: 8px
}
h1 {
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    color: #50AF50;;
}
</style>'
]

{ #category : #'pharo links' }
ElucidationBrush >> browseClassCommentLink: aClass [
	self pharoLinkTo: 'browseClassComment/' , aClass name
]

{ #category : #'pharo links' }
ElucidationBrush >> classBrowseLink: className [
	self pharoLinkTo: 'browseClass/' , className
]

{ #category : #'pharo links' }
ElucidationBrush >> classCommentBrowseLink: aClass [
	self pharoLinkTo: 'browseClassComment/' , aClass name
]

{ #category : #'html rendering' }
ElucidationBrush >> heading: title [
	title isBlock
		ifTrue: [ self tag: 'h3' do: title ]
		ifFalse: [ self tag: 'h3' do: [ self << title ] ]
]

{ #category : #'pharo links' }
ElucidationBrush >> helpBrowserLink: helpClass [
	self pharoLinkTo: 'helpBrowse/' , helpClass name
]

{ #category : #'response transformers' }
ElucidationBrush >> htmlStream [
	^ stream
]

{ #category : #'response transformers' }
ElucidationBrush >> htmlString [
	^ stream flush; contents
]

{ #category : #'html rendering' }
ElucidationBrush >> item: stringOrBlock [
	stringOrBlock isBlock
		ifTrue: [ self tag: 'li' do: stringOrBlock ]
		ifFalse: [ self tag: 'li' do: [ self << stringOrBlock ] ]
]

{ #category : #'html rendering' }
ElucidationBrush >> link: string to: anchor [
	self tag: 'a' attributes: {'href'. anchor} do: [ self << string ]
]

{ #category : #'pharo links' }
ElucidationBrush >> methodBrowseLink: aMethod [
	self pharoLinkTo: 'browseMethod/' , aMethod methodClass name, '/', aMethod selector
]

{ #category : #'pharo links' }
ElucidationBrush >> methodBrowseLink: selector inClass: className [
	self
		pharoLinkTo: 'browseMethod/' , className , '/' ,  selector
]

{ #category : #'html rendering' }
ElucidationBrush >> page: title do: aBlock [
	self
		html5;
		tag: #html
			do: [ self
				tag: #head
					do: [ self tag: #title with: title.
					self << self class style ];
				tag: #body
					do: [ self tag: #h1 with: title.
					aBlock value ] ]
]

{ #category : #'html rendering' }
ElucidationBrush >> par: paragraphText [
	"format paragraphText using its existing line-breaks"

	self
		tag: 'p'
		attributes: {'style' . 'white-space: pre-line;'}
		do: [ self << paragraphText trim ]
]

{ #category : #'html rendering' }
ElucidationBrush >> part: title [
	title isBlock
		ifTrue: [ self tag: 'h2' do: title ]
		ifFalse: [ self tag: 'h2' do: [ self << title ] ].
	self tag: 'hr'
]

{ #category : #'html rendering' }
ElucidationBrush >> part: title id: id [
	title isBlock
		ifTrue: [ self tag: 'h2' attributes: {'id'. id} do: title ]
		ifFalse: [ self 	tag: 'h2' attributes: {'id'.id} do: [ self << title ] ].
	self tag: 'hr'
]

{ #category : #'pharo links' }
ElucidationBrush >> pharoClass: className [
	"I produce an anchor of the form '<logo> className', with the logo being a browseLink to className"

	self
		link: self pharoLogo
		to: Elucidator instance httpPrefix , 'browseClass/' , className.
	self tag: 'em' with: className
]

{ #category : #'pharo links' }
ElucidationBrush >> pharoClass: className selector: selector [
	"I produce an anchor of the form '<logo> selector', with the logo being a browseLink to className>>selector"

	self
		link: self pharoLogo
		to:
			Elucidator instance httpPrefix , 'browseMethod/' , className , '/'
				, selector.
	self tag: 'em' with: selector
]

{ #category : #'pharo links' }
ElucidationBrush >> pharoClassComment: className [
	"I produce an anchor of the form '<logo> className', with the logo being a browseLink to className"

	self
		link: self pharoLogo
		to: Elucidator instance httpPrefix , 'browseClassComment/' , className.
	self tag: 'em' with: className
]

{ #category : #'pharo links' }
ElucidationBrush >> pharoHelp: className [
	"I produce an anchor of the form '<logo> className', with the logo being a browseLink to className"

	self
		link: self pharoLogo
		to: Elucidator instance httpPrefix , 'helpBrowse/' , className.
	self tag: 'em' with: className
]

{ #category : #'pharo links' }
ElucidationBrush >> pharoLink: string to: anchor [
	self link: string  to: Elucidator instance httpPrefix, anchor
]

{ #category : #'pharo links' }
ElucidationBrush >> pharoLinkTo: anchor [
	self link: self pharoLogo  to: Elucidator instance httpPrefix , anchor
]

{ #category : #'pharo links' }
ElucidationBrush >> pharoLogo [
	^ '<img src="https://avatars1.githubusercontent.com/u/1838382?s=12">'
]

{ #category : #'html rendering' }
ElucidationBrush >> section: title [
	title isBlock
		ifTrue: [ self tag: 'h4' do: title ]
		ifFalse: [ self tag: 'h4' do: [ self << title ] ]
]

{ #category : #'html rendering' }
ElucidationBrush >> ulist: block [
	self tag: 'ul' do: block
]
