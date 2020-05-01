Class {
	#name : #EluAnnouncerElucidattion,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #'as yet unclassified' }
EluAnnouncerElucidattion >> findAnnouncementsClassIn: ast [
	"return all literal Annoucements classes in ast"

	| allClasses |
	allClasses := ast allChildren
		select: [ :node | 
			node isVariable
				and:
					[ node isGlobal and: [ (node name asClassIfAbsent: [ nil ]) notNil ] ] ].
	^ allClasses select: [ :globalNode | 
			globalNode name asClass in: [:cl | cl= Announcement or: [ cl inheritsFrom: Announcement ]
				]]
]

{ #category : #'as yet unclassified' }
EluAnnouncerElucidattion >> findAnnouncementsIn: packageName [
	"return the set of announcements defined in this package"
	^Announcement allSubclasses select: [ :cl | cl package name beginsWith:  packageName ]
	
]

{ #category : #'as yet unclassified' }
EluAnnouncerElucidattion >> findAnnouncerMatrixFor: packageName [
	"I return a collection of Announcer, Announcement, anouncersenderSelector triplets. "

	"I do this by finding all senders of #announce: in the package, and then try to find which announcement is sent. I first look in the arguments to announce:, and if no Announcement is found there, I look in the rest of the sender method"

	| announcers triplets |
	announcers := #announce: senders
		select: [ :methodDef | methodDef package name beginsWith: packageName ].
	triplets := OrderedCollection new.
	announcers
		do: [ :methodDef | 
			methodDef ast sendNodes
				select: [ :send | send selector = #announce: ]
				thenDo: [ :send | 
					((self findAnnouncementsClassIn: send)
						ifNotEmpty: [ :col | col ]
						ifEmpty: [ self findAnnouncementsClassIn: methodDef ast ])
						do: [ :announcement | 
							triplets
								add:
									{methodDef methodClass name.
									announcement name .
									methodDef selector} ] ] ].
	^ triplets
		sort: [ :a :b | 
			(a first  , ' ' , a second )
				< (b first  , ' ' , b second ) ]
]

{ #category : #'as yet unclassified' }
EluAnnouncerElucidattion >> findAnnouncersIn: package [
	"return a collection of associations obj->ivName where obj store an announcer in that iv. Only return objects which are instances of classes in package"

	Announcer allInstances collect: [ :announcer | 7 ]
]

{ #category : #'as yet unclassified' }
EluAnnouncerElucidattion >> findSubscriberMatrixFor: packageName [
	"Most subscriptions follow this pattern when: Annoucement send: selector to: self. Those not following this pattern will be ignored (TODO: find a way to handle this)"

	"I return collection of triplets (Announcement, Subscriber, selector), where Subscriber is the class of self from the pattern"

	| patterns supscriptions triplets |
	patterns := #(#when:send:to: #when:send:to:with: #when:send:to:withArguments:).
	supscriptions := (patterns collect: [ :sel | sel senders ]) flattened
		select: [ :methodDef | methodDef package name beginsWith: packageName ].
	"subscriptions are all methods in package which contain a subsription"
	triplets := OrderedCollection new.
	supscriptions
		do: [ :meth | 
			meth ast sendNodes
				select: [ :send | 
					(patterns includes: send selector)
						and: [ send arguments third class = RBSelfNode ] ]
				thenCollect: [ :send | 
					triplets
						add:
							{send arguments first name.
							meth methodClass name.
							send arguments second value} ] ].
	^ triplets
]

{ #category : #rendering }
EluAnnouncerElucidattion >> renderMatrix: collection on: html headings: headers [
	"<style>
table, th, td{
  border: 1px solid black;
}
</style>"
	| str firstColumn |
	str := html htmlStream.
	str
		tag: 'table'
		do: [ str
				tag: 'tr'
				do: [ headers do: [ :header | str tag: 'th' with: header ] ].
			firstColumn := collection groupedBy: [ :triplet | triplet first ].
			firstColumn
				keysAndValuesDo: [ :key :values | 
					html htmlStream
						tag: 'tr'
						do: [ html htmlStream
								tag: 'td'
								attributes:
									{'rowspan'.
									values size}
								do: [ html htmlStream
										<< key;
										tag: 'td' with: values first second;
										tag: 'td' with: values first third ].
							values allButFirst
								do: [ :arr | 
									html htmlStream
										tag: 'tr'
										do: [ html htmlStream
												tag: 'td' with: arr second;
												tag: 'td' with: arr third ] ] ] ] ].
	^ html htmlString
]
