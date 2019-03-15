"
Utility class to catch messages
"
Class {
	#name : #DoesNotUnderstandCatcher,
	#superclass : #Object,
	#category : #'AST-Interpreter-Test-Utilities'
}

{ #category : #'reflective operations' }
DoesNotUnderstandCatcher >> doesNotUnderstand: aMessage [
	"returns the message caught"
	^aMessage
]
