"
!! Purpose
I am an object diagram model.

I consists of entities (==ObjDiaModelEntity==) connected by references (==ObjDiaModelReference==).


Entities are either objects or collections.


My entities are build by applying a transitive closure over instance variables and collection contents. The transitive closure is restricted by the buildFilter.


It is possible to astract a number of object into ''clouds'' to further reduce diagram clutter. This is controlled by presentation filter. The presentation filter will only be applied to entities already in the model, if an entity does not pass the presentation filter, a closure of all accessible object which also do not pass the filter is build. All entities in the closure are removed from the model and substituted by the single cloud entity. 
- ''Warning: this cloud feature is difficult to control and is an experiment only''
"
Class {
	#name : #ObjDiaModel,
	#superclass : #Object,
	#instVars : [
		'buildFilter',
		'presentationFilter',
		'presentationFilterBlock',
		'entities',
		'refs',
		'entityCounter'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #examples }
ObjDiaModel class >> example [
	<example>
	(ObjDiaModel  new 
		buildFilter: [:filter | filter includeCategory: 'Kernel']) 
		webbrowseDiagramFor:  ({1.  2@4.  3.})->#(2 3).
]

{ #category : #analysis }
ObjDiaModel >> analyzeRoot: root [
	| unVisited visited rootCat safetyCount |
	unVisited := Set new.
	unVisited add: root.
	visited := Set new.
	rootCat := root class category copyUpToLast: $-.
	buildFilter includeCategory: rootCat.
	safetyCount := 10000.	"to prevent too large an investigation"
	[ unVisited notEmpty ]
		whileTrue: [ | obj entity |
			(safetyCount := safetyCount - 1) < 0
				ifTrue: [ ^ nil ].
			obj := unVisited anyOne.
			unVisited remove: obj.
			(visited includes: obj)
				ifFalse: [ entity := self entityFor: obj. 
					entities at: obj put: entity.
					entity analyzeAccess.
					visited add: obj.
					unVisited addAll: (entity destinationObjects copyWithoutAll: visited)] ]
]

{ #category : #accessing }
ObjDiaModel >> buildFilter [
	^ buildFilter
]

{ #category : #accessing }
ObjDiaModel >> buildFilter: initializationBlock [
	initializationBlock value: buildFilter 
]

{ #category : #accessing }
ObjDiaModel >> entities [
	^ entities
]

{ #category : #accessing }
ObjDiaModel >> entities: anObject [
	entities := anObject
]

{ #category : #accessing }
ObjDiaModel >> entityFor: obj [
	| newEntity |
	(entities includesKey: obj)
		ifTrue:[^ entities at: obj].
	newEntity := ObjDiaModelEntity on: obj in: self.
	entities at: obj put: newEntity.
	^newEntity
]

{ #category : #public }
ObjDiaModel >> imageDiagramFor: root [
	^ PlantUMLBridge imageFromUML: (self umlFor: root)
]

{ #category : #initialization }
ObjDiaModel >> initialize [
	entities := Dictionary new.
	refs := OrderedCollection new.
	buildFilter := ObjDiaFilter new.
	entityCounter := 0.
]

{ #category : #accessing }
ObjDiaModel >> nextEntityNumber [
	entityCounter := entityCounter +1.
	^ entityCounter printString
]

{ #category : #analysis }
ObjDiaModel >> preparePresentation [ 
	entities values do: [ :entity | entity preparePresentation ]
]

{ #category : #accessing }
ObjDiaModel >> presentationFilter [
	presentationFilter ifNil: [ 
		presentationFilter := buildFilter copy.
		presentationFilterBlock ifNotNil: [:b | b value: presentationFilter  ]].
	^presentationFilter 
]

{ #category : #accessing }
ObjDiaModel >> presentationFilter: initializationBlock [
	presentationFilterBlock := initializationBlock 
]

{ #category : #analysis }
ObjDiaModel >> pruneEmptyCollections [
	| emptyCollections |
	emptyCollections := entities values
		select: [ :ent | ent isCollection and: [ ent destinations isEmpty ] ].
	emptyCollections do: [ :entity | entity removeFromModel ] 
]

{ #category : #analysis }
ObjDiaModel >> reduceModel [
	self pruneEmptyCollections.
	self simplifySingletonCollections.
	self preparePresentation.
]

{ #category : #accessing }
ObjDiaModel >> refs [
	^ refs
]

{ #category : #accessing }
ObjDiaModel >> refs: anObject [
	refs := anObject
]

{ #category : #analysis }
ObjDiaModel >> simplifySingletonCollections [
	"a singleton collection is one with just one element.
	simplyfy it into a reference of kind #singleton"

	| singletonCollections |
	singletonCollections := entities values
		select: [ :entity | entity isCollection and: [ entity destinations size = 1 ] ].
	singletonCollections
		do: [ :collEntity | collEntity reduceToSingletonRefs ]
]

{ #category : #public }
ObjDiaModel >> umlFor: root [
	| out |
	self analyzeRoot: root.
	entities ifNil: [ self error: 'model too large' ].
	self reduceModel.
	out := String new writeStream.
	self writeHeaderFor: root on: out.
	self writeObjectsOn: out.
	self writeRefsOn: out.
	self writeFooterOn: out.
	^ out contents
]

{ #category : #accessing }
ObjDiaModel >> validateModel [
	entities do: [ :entity |
		entity sources do: [ :ref | 
			(entities at: ref source key obj) = ref source key ifFalse: [ self error ].
			ref destination = entity ifFalse: [ self error ].
			(ref source key destinations includes: ref) ifFalse: [ self error ] ].
		entity destinations do: [ :ref  |
			(entities at: ref destination obj) = ref destination ifFalse: [ self error ].
			ref source key = entity ifFalse: [ self error].
			(ref destination sources includes: ref) ifFalse: [ self error ] ] ].
	refs do: [ :ref |
		(ref source key destinations includes: ref) ifFalse: [ self error ].
		(ref destination sources includes: ref) ifFalse: [ self error ] ].
]

{ #category : #public }
ObjDiaModel >> webbrowseDiagramFor: root [
	^ PlantUMLBridge webbrowseUML: (self umlFor: root) 
]

{ #category : #'uml writing' }
ObjDiaModel >> writeFooterOn: out [
	out << String cr << '@enduml' << String cr
]

{ #category : #'uml writing' }
ObjDiaModel >> writeHeaderFor: root on: out [
	out
		<< '@startuml';
		cr;
		<< 'skinparam packageStyle rectangle';
		cr;
		<< 'title ';
		<< root printString;
		cr;
		cr
]

{ #category : #'uml writing' }
ObjDiaModel >> writeObjectsOn: out [
	entities  do: [ :entity | entity writeUmlOn: out ]

	
]

{ #category : #'uml writing' }
ObjDiaModel >> writeRefsOn: out [
	entities do: [ :entity | entity writeRefsOn: out ]
]
