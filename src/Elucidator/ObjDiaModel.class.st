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
		'entities',
		'refs',
		'entityCounter',
		'id',
		'diagramName'
	],
	#classInstVars : [
		'modelCounter',
		'modelCache'
	],
	#category : #'Elucidator-ObjectDiagram'
}

{ #category : #'as yet unclassified' }
ObjDiaModel class >> diagramRequest: req [
	| class range obj instances|
	class := (req at: #class) asClass.
	range := (req at: #range) asNumber.
	instances := class allInstances ifEmpty: [ class allSubInstances ].
	obj := instances in: [:col | col at: (Random new nextInt: col size)].
	(self new range: range from: obj) webbrowseDiagram.
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		entity: (ZnEntity html: 'It is done!');
		yourself
]

{ #category : #examples }
ObjDiaModel class >> example [
	<example>
	(ObjDiaModel  new 
		buildFilter: [:filter | filter includeCategory: 'Kernel']) 
		webbrowseDiagramFor:  ({1.  2@4.  3.})->#(2 3).
]

{ #category : #'class initialization' }
ObjDiaModel class >> initialize [
	modelCounter := modelCache := nil
]

{ #category : #'as yet unclassified' }
ObjDiaModel class >> inspectRequest: req [
	| model entity |
	model := modelCache at: (req at: #model).
	entity := model findFromPrintString: (req at: #oid).
	WorldState defer: [entity obj isClass
		ifTrue: [ entity obj browse ]
		ifFalse: [ entity obj inspect ]].
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		entity: (ZnEntity html: 'It is done!');
		yourself
]

{ #category : #accessing }
ObjDiaModel class >> modelAt: id [
	(modelCache includesKey: id)
		ifTrue: [ ^ modelCache at: id ] 
		ifFalse: [ ^nil ]
]

{ #category : #'instance creation' }
ObjDiaModel class >> new [
	| newModel |
	newModel := super new.
	modelCounter ifNil: [ modelCounter := 0 ].
	modelCounter := modelCounter +1.
	newModel id: 'objdia', modelCounter  printString.
	modelCache ifNil: [ modelCache := LRUCache new ].
	modelCache at: newModel id put: newModel.
	^ newModel
	
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

{ #category : #accessing }
ObjDiaModel >> findFromPrintString: printNameNoSpace [
	^ entities detect: [ :ent | ent printNameNoSpace = printNameNoSpace  ] ifNone: [ nil ]
		
]

{ #category : #accessing }
ObjDiaModel >> id [
	^id
]

{ #category : #accessing }
ObjDiaModel >> id: newId [
	id := newId
]

{ #category : #public }
ObjDiaModel >> imageDiagramFor: root [
	^ PlantUMLBridge imageFromUML: (self umlFor: root)
]

{ #category : #initialization }
ObjDiaModel >> initialize [
	entities := Dictionary new.
	refs := OrderedCollection new.
	entityCounter := 0
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

{ #category : #analysis }
ObjDiaModel >> pruneEmptyCollections [
	| emptyCollections |
	emptyCollections := entities values
		select: [ :ent | ent isCollection and: [ ent destinations isEmpty ] ].
	emptyCollections do: [ :entity | entity removeFromModel ] 
]

{ #category : #initialization }
ObjDiaModel >> range: range from: root [
	| unVisited visited safetyCount |
	diagramName := 'Object diagram for ' , root class name , ' instance'.
	unVisited := Set new.
	visited := Set new.
	safetyCount := 1000.
	(self entityFor: root)
		in: [ :ent | 
			ent range: range.
			unVisited add: ent ].
	[ unVisited notEmpty ]
		whileTrue: [ | entity |
			safetyCount := safetyCount - 1.
			safetyCount = 0
				ifTrue: [ self error: 'Model too large' ].
			entity := unVisited anyOne.
			unVisited remove: entity.
			visited add: entity.
			entity analyzeRange.
			unVisited
				addAll:
					(entity destinationEntities | entity sourceEntities
						copyWithoutAll: visited) ]
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

{ #category : #'uml writing' }
ObjDiaModel >> uml [
	^ String new
		writeStreamDo: [ :out | 
			self writeHeaderFor: diagramName  on: out.
			self writeObjectsOn: out.
			self writeRefsOn: out.
			self writeFooterOn: out.
			out contents ]
]

{ #category : #public }
ObjDiaModel >> umlFor: root [
	self analyzeRoot: root.
	entities ifNil: [ self error: 'model too large' ].
	self reduceModel.
	^self uml
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
ObjDiaModel >> webbrowseDiagram [
	^ PlantUMLBridge webbrowseUML: (self uml) 
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
