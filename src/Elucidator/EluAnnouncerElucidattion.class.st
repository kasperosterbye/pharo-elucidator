Class {
	#name : #EluAnnouncerElucidattion,
	#superclass : #Elucidation,
	#category : #'Elucidator-Core'
}

{ #category : #'helper methods' }
EluAnnouncerElucidattion >> anyAnnouncementsIn: packageName [
	^(self findAnnouncerMatrixFor: packageName) isNotEmpty | 
	(self findSubscriberMatrixFor: packageName) isNotEmpty 
]

{ #category : #elucidation }
EluAnnouncerElucidattion >> elucidatePackage: subject html: html [
	(self anyAnnouncementsIn: subject)
		ifFalse: [ html part: 'No annoucement info for package ' , subject.
			^ self ].
	html part: 'Annoucements announced or handled'.
	self renderCombinedMatrixForPackage: subject on: html
]

{ #category : #'helper methods' }
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

{ #category : #'helper methods' }
EluAnnouncerElucidattion >> findAnnouncerMatrixFor: packageName [
	"I return a collection of Announcement, Announcer, anouncersenderSelector triplets. "

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
									{
									announcement name.
									methodDef methodClass name.
									methodDef selector} ] ] ].
	^ triplets
		sort:
			[ :a :b | (a first , ' ' , a second) < (b first , ' ' , b second) ]
]

{ #category : #'helper methods' }
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

{ #category : #'helper methods' }
EluAnnouncerElucidattion >> renderCell: info at: indexAtMax on: html [
	| index max size |
	index := indexAtMax x.
	max := indexAtMax y.
	size := info size.
	index - 1 < size
		ifTrue:
			[ html tag: 'td' do: [ html pharoClass: (info at: index) second ].
			html
				tag: 'td'
				do: [ html pharoClass: (info at: index) second selector:  (info at: index) third] ].
	index - 1 = size
		ifTrue: [ 2
				timesRepeat: [ html
						tag: 'td'
						attributes:
							{'rowspan'.
							(max - size)}
						do: [ html << '&nbsp;' ] ] ]
]

{ #category : #'helper methods' }
EluAnnouncerElucidattion >> renderCombinedMatrixForPackage: packageName on: html [

	| announcers subscribers announcements |
	announcers := (self findAnnouncerMatrixFor: packageName)
		groupedBy: #first.
	subscribers := (self findSubscriberMatrixFor: packageName)
		groupedBy: #first.
	announcements := (announcers keys union: subscribers keys) asSet
		asSortedCollection.
	html
		tag: 'table'
		do: [ html
				tag: 'tr'
				do: [ {'Announcer' . 'annoucing method' . 'Announcement' . 'Subscriber'.
					'via method'} do: [ :header | html tag: 'th' with: header ] ].
			html << String cr.
			announcements
				do: [ :announcement | 
					| ann subs |
					ann := announcers at: announcement ifAbsent: [ #() ].
					subs := subscribers at: announcement ifAbsent: [ #() ].
					self renderRowWith: ann and: subs on: html ] ].
]

{ #category : #'helper methods' }
EluAnnouncerElucidattion >> renderRowWith: ann and: subs on: html [
	"Ann is a list of the form (Announcement Announcer selector), subs on the form (Announcement Subscriber selector"

	| max announcement |
	max := ann size max: subs size.
	announcement := ann
		ifNotEmpty: [ ann first first ]
		ifEmpty: [ subs first first ].
	html << ('<!---   ' , announcement , '   --->' , String cr).
	1 to: max do: [ :index | 
		html
			tag: 'tr'
			do: [ self renderCell: ann at: index @ max on: html.
				index = 1
					ifTrue: [ html
							tag: 'td'
							attributes:
								{'rowspan'.
								max}
							do: [ html pharoClass: announcement ] ].
				self renderCell: subs at: index @ max on: html ].
		html << String cr ]
]
