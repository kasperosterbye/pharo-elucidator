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
					baseline: 'PlantUMLBridge'
					with: [ spec repository: 'github://kasperosterbye/PlantUMLBridge' ];
				package: 'Elucidator' ]
]
