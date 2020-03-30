Class {
	#name : #BaselineOfElucidator,
	#superclass : #BaselineOf,
	#category : #BaselineOfElucidator
}

{ #category : #baselines }
BaselineOfElucidator >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'Teapot'
					with: [ spec
						repository: 'github://zeroflag/Teapot/source';
						loads: #('Deployment') ];
				package: 'Elucidator' ]
]
