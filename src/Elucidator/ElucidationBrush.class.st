Class {
	#name : #ElucidationBrush,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #Elucidator
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

{ #category : #'html rendering' }
ElucidationBrush >> classBrowseLink: aClass [
	self
		elucidateLinkTo: 'browseClass/' , aClass name
]

{ #category : #'html rendering' }
ElucidationBrush >> elucidateLink: string to: anchor [
	self link: string  to: Elucidator instance httpPrefix, anchor
]

{ #category : #'html rendering' }
ElucidationBrush >> elucidateLinkTo: anchor [
	self link: '<img src="https://upload.wikimedia.org/wikipedia/commons/c/cf/Pharo.png" height="12">' to: Elucidator instance httpPrefix , anchor
]

{ #category : #'html rendering' }
ElucidationBrush >> heading: title [
	title isBlock
		ifTrue: [ stream tag: 'h3' do: title]
		ifFalse: [ stream tag: 'h3' do: [ stream << title.] ]
]

{ #category : #'response transformers' }
ElucidationBrush >> htmlStream [
	^ stream
]

{ #category : #'response transformers' }
ElucidationBrush >> htmlString [
	^ stream flush wrappedStream contents
]

{ #category : #'html rendering' }
ElucidationBrush >> item: string [
	stream tag: 'li' do: string
]

{ #category : #'html rendering' }
ElucidationBrush >> link: string to: anchor [
	stream tag: 'a' attributes: {'href'. anchor} do: [ stream << string ]
]

{ #category : #'instance creation' }
ElucidationBrush >> on: aZnHtmlOutputStream [
	stream := aZnHtmlOutputStream.
]

{ #category : #'html rendering' }
ElucidationBrush >> page: title do: aBlock [
	stream
		html5;
		tag: #html
			do: [ stream
				tag: #head
					do: [ stream tag: #title with: title.
					stream << self class style ];
				tag: #body
					do: [ stream tag: #h1 with: title.
					aBlock value ] ]
]

{ #category : #'html rendering' }
ElucidationBrush >> par: paragraphText [
	"format paragraphText using its existing line-breaks"
	
	stream
		tag: 'p'
		attributes: {'style' . 'white-space: pre-line;'}
		do: [ stream << paragraphText trim ]
]

{ #category : #'html rendering' }
ElucidationBrush >> part: title [
	title isBlock
		ifTrue: [ stream tag: 'h2' do: title ]
		ifFalse: [ stream tag: 'h2' do: [ stream << title ] ].
	stream tag: 'hr'
]

{ #category : #'html rendering' }
ElucidationBrush >> section: title [
	title isBlock
		ifTrue: [ stream tag: 'h4' do: title ]
		ifFalse: [ stream tag: 'h4' do: [ stream << title ] ]
]

{ #category : #'html rendering' }
ElucidationBrush >> ulist: block [
	stream tag: 'ul' do: block
]
