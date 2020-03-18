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
				package: 'Elucidator'.]
]
