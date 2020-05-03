"
!! Purpose

I am a class to provide elucidation of a package. I find and present all Annoucements ==announced:== and all Announcements ==subscribed==
"
Class {
	#name : #EluAnnouncerPackageElucidation,
	#superclass : #Elucidation,
	#instVars : [
		'packageName',
		'announcers',
		'subscribers',
		'html'
	],
	#category : #'Elucidator-Core'
}

{ #category : #'helper methods' }
EluAnnouncerPackageElucidation >> analyze [
	announcers := self findAnnouncerMatrix.
	subscribers := self findSubscriberMatrix
]

{ #category : #'helper methods' }
EluAnnouncerPackageElucidation >> anyAnnouncementsIn: packageName [
	^(self findAnnouncerMatrixFor: packageName) isNotEmpty | 
	(self findSubscriberMatrixFor: packageName) isNotEmpty 
]

{ #category : #'as yet unclassified' }
EluAnnouncerPackageElucidation >> contributes [
	"return true if I have something to contribute to the elucidation of subject"
	^ announcers isNotEmpty | subscribers isNotEmpty 
]

{ #category : #elucidation }
EluAnnouncerPackageElucidation >> elucidatePackage: subject html: html [
	(self anyAnnouncementsIn: subject)
		ifFalse: [ html part: 'No annoucement info for package ' , subject.
			^ self ].
	html part: 'Annoucements announced or handled'.
	self renderCombinedMatrixForPackage: subject on: html
]

{ #category : #'helper methods' }
EluAnnouncerPackageElucidation >> findAnnouncementsClassIn: ast [
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
EluAnnouncerPackageElucidation >> findAnnouncerMatrix [
	"I return a collection of Announcement, Announcer, anouncersenderSelector triplets. "

	"I do this by finding all senders of #announce: in the package, and then try to find which announcement is sent. I first look in the arguments to announce:, and if no Announcement is found there, I look in the rest of the sender method"

	| announceSenders triplets |
	announceSenders := #announce: senders
		select: [ :methodDef | methodDef package name beginsWith: packageName ].
	triplets := OrderedCollection new.
	announceSenders
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
									{announcement name.
									methodDef methodClass name.
									methodDef selector} ] ] ].
	^ triplets
		sort: [ :a :b | (a first , ' ' , a second) < (b first , ' ' , b second) ]
]

{ #category : #'helper methods' }
EluAnnouncerPackageElucidation >> findSubscriberMatrix [
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
EluAnnouncerPackageElucidation >> html: htmlStream [
	html := htmlStream 
]

{ #category : #'helper methods' }
EluAnnouncerPackageElucidation >> on: aPackageName [
	packageName := aPackageName 
]

{ #category : #'helper methods' }
EluAnnouncerPackageElucidation >> renderCell: info at: indexAtMax [ 
	| index max size |
	index := indexAtMax x.
	max := indexAtMax y.
	size := info size.
	index - 1 < size
		ifTrue: [ html tag: 'td' do: [ html pharoClass: (info at: index) second ].
			html
				tag: 'td'
				do: [ html
						pharoClass: (info at: index) second
						selector: (info at: index) third ] ].
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
EluAnnouncerPackageElucidation >> renderMe [
	| groupedAnnouncers groupedSubscribers announcements |
	groupedAnnouncers := announcers groupedBy: #first.
	groupedSubscribers := subscribers groupedBy: #first.
	announcements := (groupedAnnouncers keys
		union: groupedSubscribers keys) asSet asSortedCollection.
	html part: 'Announcements' id: 'announcements'.
	html << 'The following table list all Announcements that I Announce in an #announce: method, or subscribes to in an #when:send:to: (or similar) method'.
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
					ann := groupedAnnouncers at: announcement ifAbsent: [ #() ].
					subs := groupedSubscribers at: announcement ifAbsent: [ #() ].
					self renderRowWith: ann and: subs ] ]
]

{ #category : #'helper methods' }
EluAnnouncerPackageElucidation >> renderRowWith: ann and: subs [
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
			do: [ self renderCell: ann at: index @ max.
				index = 1
					ifTrue: [ html
							tag: 'td'
							attributes:
								{'rowspan'.
								max}
							do: [ html pharoClass: announcement ] ].
				self renderCell: subs at: index @ max ].
		html << String cr ]
]

{ #category : #documenting }
EluAnnouncerPackageElucidation >> synopsis [
	self contributes 
		ifFalse: [ html 
			tag: 'li' 
			do: [ html << '<b>Announcements:</b> It seems like this package do not announce or subscribe to any Announcements' ] ]
		ifTrue: [ html 
			tag: 'li' 
			do: [ html << '<b>Announcements:</b> This package announce or subscribe to various annoucement. <br>See more <a href="#announcements">further down</a>' ] ]
]
