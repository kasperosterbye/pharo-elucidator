Class {
	#name : #ElucidationBrush,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
ElucidationBrush >> allHtml [
	^ stream flush wrappedStream contents
]

{ #category : #'as yet unclassified' }
ElucidationBrush >> classBrowseLink: aClass [
	self
		elucidateLink: aClass name asString
		to: 'browseClass/' , aClass name
]

{ #category : #'as yet unclassified' }
ElucidationBrush >> docTitle: title body: bodyBlock [
]

{ #category : #'instance creation' }
ElucidationBrush >> elucidateLink: string to: anchor [
	self link: string  to: Elucidator instance httpPrefix, anchor
]

{ #category : #'instance creation' }
ElucidationBrush >> heading: titleBlock [
	stream tag: 'h3' do: titleBlock
]

{ #category : #'response transformers' }
ElucidationBrush >> html [
	^ stream
]

{ #category : #'response transformers' }
ElucidationBrush >> htmlStream [
	^ stream
]

{ #category : #'instance creation' }
ElucidationBrush >> item: string [
	stream tag: 'li' do: string
]

{ #category : #'instance creation' }
ElucidationBrush >> link: string to: anchor [
	stream tag: 'a' attributes: {'href'. anchor} do: [ stream << string ]
]

{ #category : #initialization }
ElucidationBrush >> page: title do: aBlock [
	stream := ZnHtmlOutputStream on: '' writeStream.
	stream page: title do: aBlock.
	^ self allHtml
]

{ #category : #'instance creation' }
ElucidationBrush >> par: paragraphText [
	"format paragraphText using its existing line-breaks"
	
	stream
		tag: 'p'
		attributes: {'style' . 'white-space: pre-line;'}
		do: [ stream << paragraphText trim ]
]

{ #category : #'instance creation' }
ElucidationBrush >> ulist: block [
	stream tag: 'ul' do: block
]
