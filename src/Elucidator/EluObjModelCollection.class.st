"
!! Purpose
I represent a collection object. 
"
Class {
	#name : #EluObjModelCollection,
	#superclass : #EluObjModelEntity,
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #analysis }
EluObjModelCollection >> analyzeDestinationRange [
	"I create destinations for my obj. I create one destination for each of my elements (up to 7)"

	| count |
	(obj class inheritsFrom: String)
		ifTrue: [ ^ self ].
	count := 7.
	obj
		do: [ :elem | 
			| destination |
			destination := model entityFor: elem.
			destination setAsDestination.
			destination range: (range - 1 max: destination range).
			self destinationsAt: 'Index' putEntity: destination.
			count := count - 1.
			count = 0
				ifTrue: [ ^ self ] ]
]

{ #category : #testing }
EluObjModelCollection >> modelsCollection [
	^ true
]

{ #category : #accessing }
EluObjModelCollection >> packageName [
	sources
		ifNotEmpty: [ sources first source key obj
				in: [ :o | 
					o isCollection
						ifFalse: [ ^ o class package name ] ] ].
	^ nil
]

{ #category : #writing }
EluObjModelCollection >> printName [
	obj isString
		ifTrue: [ ^ '''', (obj contractTo: 12), ''''  ]
		ifFalse: [ ^ obj class name ]
]

{ #category : #writing }
EluObjModelCollection >> writeRefsOn: out [
	destinations
		do: [ :ref | 
			out << self printNameNoSpace << ref arrowType 
				<< ref destination printNameNoSpace << String cr ] 
]

{ #category : #writing }
EluObjModelCollection >> writeUmlOn: out [
	self packageName
		in: [ :packageName | 
			packageName
				ifNil: [ super writeUmlOn: out ]
				ifNotNil: [ (out << 'package ' << self packageHtmlLink)
						<< ' {';
						cr.
					super writeUmlOn: out.
					out
						<< '}';
						cr ] ]
]
