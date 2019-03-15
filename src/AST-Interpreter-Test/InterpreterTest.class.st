"
Common superclass for SUnit tests of interpreter tests
"
Class {
	#name : #InterpreterTest,
	#superclass : #TestCase,
	#category : #'AST-Interpreter-Test-Tests'
}

{ #category : #testing }
InterpreterTest class >> isAbstract [ 
	"This is an abstract class as superclass of test classes, therefore we return true"
	
	^self name = #InterpreterTest
]

{ #category : #helper }
InterpreterTest >> block [
	^ [2]
]

{ #category : #helper }
InterpreterTest >> blockTemp [
	|stuff|
	stuff := 5.
	^[stuff]
]

{ #category : #helper }
InterpreterTest >> blockTempWrite [
	|stuff|
	^[stuff := 5. stuff]
]

{ #category : #helper }
InterpreterTest >> ensureNonLocalReturn: anOrderedCollection [
	[^2] ensure: [anOrderedCollection add: 5]
]

{ #category : #helper }
InterpreterTest >> errorBlock [
	^ [Error signal]
]

{ #category : #helper }
InterpreterTest >> lazyInitialization [
	|foo|
	^foo ifNil: [ foo := 5 ]
]

{ #category : #helper }
InterpreterTest >> methodWithTemp [
	|temp|
	temp := 5 + 2.
	^temp
]

{ #category : #helper }
InterpreterTest >> returningBlock [
	^ [^ 2]
]

{ #category : #helper }
InterpreterTest >> returningBlockArg [
	^ [:arg| ^arg]
]

{ #category : #helper }
InterpreterTest >> returningBlockInsideLoop [
	[ ^5] whileFalse
]

{ #category : #helper }
InterpreterTest >> returningBlockNonRootContext [
	self should: [self returningBlock value] raise: BlockCannotReturn
]

{ #category : #helper }
InterpreterTest >> returningBlockNonRootContext2 [
	[self returningBlock value] on: BlockCannotReturn do: [ 1 ]
]

{ #category : #helper }
InterpreterTest >> returningBlockValue [
	[ ^5 ] value
]

{ #category : #helper }
InterpreterTest >> returningLoop [
	|index|
	index := 1.
	[index := index + 1.
	index = 5 ifTrue: [^index ].
	index = 10] whileFalse.
	^self error
]

{ #category : #helper }
InterpreterTest >> returningTempBlock [
	|stuff|
	stuff := 5.
	[ ^stuff] value
]

{ #category : #helper }
InterpreterTest >> superSendInNestedBlock [
	[[ ^ super selector ] value ] value
]

{ #category : #helper }
InterpreterTest >> thisContextCopyMethod [
	|var|
	var := thisContext copy.
	^var
]

{ #category : #helper }
InterpreterTest >> thisContextMethod [
	^thisContext
]

{ #category : #helper }
InterpreterTest >> unknownSuperSend [
	^ super aSelectorThatDoesNotExist
]

{ #category : #helper }
InterpreterTest >> unknownSuperSendInNestedBlock [
	[[ ^ super aSelectorThatDoesNotExist ] value ] value
]
