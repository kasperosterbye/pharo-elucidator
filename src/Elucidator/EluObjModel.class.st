"
!! Purpose
I am an object diagram model.

I consists of entities (==ObjDiaModelEntity==) connected by references (==ObjDiaModelReference==).


Entities are either objects or collections.


My entities are build by applying a transitive closure over instance variables and collection contents. The transitive closure is restricted by range.

"
Class {
	#name : #EluObjModel,
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
EluObjModel class >> diagramRequest: req [
	"I am called from the Elucidator to draw an object diagram for a random instance of a class."

	| class range obj instances |
	class := Elucidator classFromHtmlName: (req at: #class).
	range := (req at: #range) asNumber.
	instances := class allInstances ifEmpty: [ class allSubInstances ].
	obj := instances
		in: [ :col | col at: (Random new nextInt: col size) ].
	(self new range: range from: obj) webbrowseDiagram.
	^ ZnResponse new
		statusLine: ZnStatusLine noContent;
		entity: (ZnEntity html: 'It is done!');
		yourself
]

{ #category : #example }
EluObjModel class >> example [
	"Show an object diagram in a webbrowser of the state of the (pharo) world."
	"Range 2 means that we will draw a diagram two levels out from the starting object.
	If the diagram becomes too large, plantuml will return a page which says 'forbidden'"
	<example>
	(self new range: 2 from: World worldState) webbrowseDiagram
]

{ #category : #'class initialization' }
EluObjModel class >> initialize [
	"I maintain a model cache to be able to interact with a webbrowser. The links in the object diagram are of the form http://.../inspect/modelID/objectID. "
	modelCounter := modelCache := nil
]

{ #category : #'as yet unclassified' }
EluObjModel class >> inspectRequest: req [
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
EluObjModel class >> modelAt: id [
	(modelCache includesKey: id)
		ifTrue: [ ^ modelCache at: id ] 
		ifFalse: [ ^nil ]
]

{ #category : #'instance creation' }
EluObjModel class >> new [
	"Create a new object diagram. Each diagram is kept in a LRUCache to alllow inspect requests to be resolved."
	"Todo: clear the LRU cache before closing down an image, or when loading it"
	| newModel |
	newModel := super new.
	modelCounter ifNil: [ modelCounter := 0 ].
	modelCounter := modelCounter + 1.
	newModel id: 'objdia' , modelCounter printString.
	modelCache ifNil: [ modelCache := LRUCache new ].
	modelCache at: newModel id put: newModel.
	^ newModel
]

{ #category : #accessing }
EluObjModel >> entities [
	^ entities
]

{ #category : #accessing }
EluObjModel >> entities: anObject [
	entities := anObject
]

{ #category : #accessing }
EluObjModel >> entityFor: obj [
	"I return the model entity for the given object. My primary purpose is to make sure the same model entity is not created twice."
	| newEntity |
	(entities includesKey: obj)
		ifTrue: [ ^ entities at: obj ].
	newEntity := EluObjModelEntity on: obj in: self.
	entities at: obj put: newEntity.
	^ newEntity
]

{ #category : #accessing }
EluObjModel >> findFromPrintString: printNameNoSpace [
	"I resolve the object as part of the inspect request from class side"
	^ entities
		detect: [ :ent | ent printNameNoSpace = printNameNoSpace ]
		ifNone: [ nil ]
]

{ #category : #accessing }
EluObjModel >> id [
	^id
]

{ #category : #accessing }
EluObjModel >> id: newId [
	id := newId
]

{ #category : #initialization }
EluObjModel >> initialize [
	entities := Dictionary new.
	refs := OrderedCollection new.
	entityCounter := 0
]

{ #category : #accessing }
EluObjModel >> nextEntityNumber [
	entityCounter := entityCounter +1.
	^ entityCounter printString
]

{ #category : #initialization }
EluObjModel >> range: range from: root [
	| unVisited visited safetyCount |
	diagramName := 'Object diagram for ' , root class name , ' instance'.
	unVisited := Set new.
	visited := Set new.
	safetyCount := 1000.
	(self entityFor: root)
		in: [ :ent | 
			ent range: range.
			ent setAsRoot.
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

{ #category : #accessing }
EluObjModel >> refs [
	^ refs
]

{ #category : #accessing }
EluObjModel >> refs: anObject [
	refs := anObject
]

{ #category : #'uml writing' }
EluObjModel >> uml [
	"I return a plantuml string based on my diagram"
	^ String new
		writeStreamDo: [ :out | 
			self writeHeaderFor: diagramName on: out.
			self writeObjectsOn: out.
			self writeRefsOn: out.
			self writeFooterOn: out.
			out contents ]
]

{ #category : #public }
EluObjModel >> webbrowseDiagram [
	^ PlantUMLBridge webbrowseUML: (self uml) 
]

{ #category : #'uml writing' }
EluObjModel >> writeFooterOn: out [
	out << String cr << '@enduml' << String cr
]

{ #category : #'uml writing' }
EluObjModel >> writeHeaderFor: root on: out [
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
EluObjModel >> writeObjectsOn: out [
	entities  do: [ :entity | entity writeUmlOn: out ]

	
]

{ #category : #'uml writing' }
EluObjModel >> writeRefsOn: out [
	entities do: [ :entity | entity writeRefsOn: out ]
]
