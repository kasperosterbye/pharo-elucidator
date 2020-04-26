"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestElucidator,
	#superclass : #PackageManifest,
	#category : #'Elucidator-Manifest'
}

{ #category : #'code-critics' }
ManifestElucidator class >> ruleRBUncommonMessageSendRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#Elucidator #initialize #false)) #'2020-04-23T07:34:03.630056+02:00') )
]
