"
SUnit tests for ASTInterpreter
"
Class {
	#name : #ASTInterpreterTest,
	#superclass : #InterpreterTest,
	#instVars : [
		'interpreter',
		'context'
	],
	#category : #'AST-Interpreter-Test-Tests'
}

{ #category : #'as yet unclassified' }
ASTInterpreterTest class >> testMethodArguments: anObject [
	^ [ anObject ] value
]

{ #category : #helper }
ASTInterpreterTest >> compile: aString [
	^interpreter compile: aString
]

{ #category : #helper }
ASTInterpreterTest >> interpret: aString [
	| result |
	
	"context homeContext: thisContext".
	interpreter resetContext: context.
	result := interpreter interpretDoIt: (self compile: aString).
	
	self assert: interpreter context = context.
	^ result
]

{ #category : #helper }
ASTInterpreterTest >> interpretTest: aTest [ 
	| result |
	
	"context homeContext: thisContext".
	interpreter resetContext: context.
	result := interpreter interpret: (aTest ast body).
	
	self assert: interpreter context = context.
	^ result
]

{ #category : #helper }
ASTInterpreterTest >> setUp [
	"for now we use an ast cache to speed up the ast lookup"
	ASTCache initialize.
	interpreter := ASTInterpreter new.
	context := AIRootContext new.
]

{ #category : #testing }
ASTInterpreterTest >> testArrayBasic [

	self assert: (self interpret: '#(12 #de 1.2)') equals: #(12 #de 1.2).
	self assert: (self interpret: '{12 . #de . 1.2}') equals: {12 . #de . 1.2}.
	
]

{ #category : #testing }
ASTInterpreterTest >> testArrayNonLiteral [
	|x y|
	x := 5 + 2.
	y := #aSymbol.

	self assert: (self interpret: '|x y|
		x := 5 + 2.
		y := #aSymbol.
		{x . y}') equals: {x . y}.
]

{ #category : #testing }
ASTInterpreterTest >> testAsInteger [

	self assert: (self interpret: '#''123'' asInteger') equals: 123.
	self assert: (self interpret: '(String withAll: #($1 $2 $3)) asInteger') equals: 123.
	
]

{ #category : #testing }
ASTInterpreterTest >> testAssert [
	self should: [ self interpret: 'ASTInterpreterTest new assert: false ' ] raise: InterpretationError.
	self interpret: 'ASTInterpreterTest new assert: true '
]

{ #category : #testing }
ASTInterpreterTest >> testAssignTemp [
	self assert: (self interpret: '[ |x| x:=4. x] value') equals: 4.
	self should: [self interpret: '[ |x| x:=4. y] value'] raise: Error.
	self assert: (self interpret: 'ASTInterpreterTest new methodWithTemp') equals: 7.
	self assert: (self interpret: '|x| x:=4. x') equals: 4.
	self assert: (self interpret: '|x y| x:=4. y') equals: nil.
	self assert: (self interpret: '|x y| y:=x:=4. y') equals: 4.
	self assert: (self interpret: '|x y| y:=1. y:=x:=4. y') equals: 4.
]

{ #category : #testing }
ASTInterpreterTest >> testBasicCode [
	self assert: (self interpret: '[ true ifTrue: [ nil ] ifFalse: [ 1 ]] value') equals: nil.
	self assert: (self interpret: '[ false ifTrue: [ nil ] ifFalse: [ 1 ]] value') = 1.
	
	self assert: (self interpret: '[ |a| a :=1. [ a < 10 ] whileTrue: [ a := a + 1]. a] value') = 10.
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testBinarySend [
	self assert: (self interpret: '1 + 2') = 3.
	self assert: (self interpret: '1 < 2') = true.
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testBlock [
	self assert: ((self interpret: '[ 1 ]') isKindOf: ASTBlockClosure).
	
	self assert: (self interpret: '[ 1 ] value') = 1.
	self assert: (self interpret: '[^1] value') = 1.
	self assert: (self interpret: '[ 1 + 2 ] value') = 3.
	
	self assert: (self interpret: 'true ifTrue: [ 1 ] ifFalse: [ 0 ]') = 1.
	self assert: (self interpret: 'false ifTrue: [ 1 ] ifFalse: [ 0 ]') = 0.
	
	
	
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testBlockArgument [

	self assert: (self interpret: '[ :a| a ] value: 1') = 1.
	self assert: (self interpret: '[ :a| a + 3 ] value: 3 ') = 6.
	self assert: (self interpret: '[ :a :b | a + b ] value: 3 value: 5 ') = 8.
	
	self assert: (self interpret: '[ :a| a ] valueWithArguments: #(1)') equals: 1.
	self should: [self interpret: '[ :a| a ] valueWithArguments: #(1 3)'] raise: InterpretationError.
	self assert: (self interpret: '[ :a| a + 3 ] valueWithArguments: #(3) ') equals: 6.
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testBlockCannotReturn [
	self should: [ self interpret: 'ASTInterpreterTest new returningBlock value' ] raise: InterpretationError.
	self should: [ self interpret: 'ASTInterpreterTest new returningBlockArg value: 1' ] raise: InterpretationError.
	self interpret: 'ASTInterpreterTest new returningBlockNonRootContext2 '.
	self interpret: 'ASTInterpreterTest new returningBlockNonRootContext '
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testBlockOutOfHomeContext [
	
	self should:  [ self interpret: 'ASTInterpreterTest new errorBlock value' ]
		raise: InterpretationError.
	self assert: (self interpret: 'ASTInterpreterTest new block value') equals: 2.
	self assert: (self interpret: 'ASTInterpreterTest new blockTemp value') equals: 5.
	self assert: (self interpret: 'ASTInterpreterTest new blockTempWrite value') equals: 5.
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testBlockVar [

	self assert: (self interpret: '[ |a| a := 1. a ] value') = 1.
	self assert: (self interpret: '[ |a| a := 1 + 2. a + 3 ] value') = 6.
	
	self assert: (self interpret: '[ |a| [ a := 1 ] value ] value') = 1.
	self assert: (self interpret: '[ |a| a := 1. [ a := 2 ] value ] value') = 2.
	
	self assert: (self interpret: '[ |a| a := 1. [ a := a + 1 ] value ] value') = 2.
	
	self assert: (self interpret: '[ :b ||a| a := 1. [ :c| a := a + 1 + c ] value: b ] value: 3') = 5.
	
	self assert: (self interpret: '|b| b := 2. [ |a| a := 1. a ] value') = 1.
	self assert: (self interpret: '|b| b := 2. [ |a| a := 1. a ] value. b') = 2.
]

{ #category : #testing }
ASTInterpreterTest >> testConstant [
	self assert: (self interpret: '1') = 1.
	self assert: (self interpret: 'nil') = nil.
	self assert: (self interpret: 'false') = false.
	self assert: (self interpret: '''asdf''') = 'asdf'.
	self assert: (self interpret: '#symbol') = #symbol.
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testCull [

	self should: [self interpret: '[ :x :y | x + y ] cull: 1'] raise: InterpretationError.
	self assert: (self interpret: '[:x | x] cull: 1') = 1.
	self assert: (self interpret: '[2] cull: 1') = 2.
	
	self should: [self interpret: '[ :x :y :z | x + y + z ] cull: 1 cull: 2'] raise: InterpretationError.
	self assert: (self interpret: '[:x :y | x + y] cull: 1 cull: 2') = 3.
	self assert: (self interpret: '[:x | x] cull: 1 cull: 2') = 1.
	self assert: (self interpret: '[5] cull: 1 cull: 2') = 5.


	
	
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testDNU [
	| interpretationError dnu |
	
	[ self interpret: '1 aMessageNotUnderstoodBySmallInteger' ]
		on: InterpretationError
		do: [ :err| interpretationError := err ].
	
	dnu := interpretationError cause. 
	
	self assert: dnu message selector equals: #aMessageNotUnderstoodBySmallInteger.
	self assert: dnu receiver equals: 1.
	
	[ self interpret: '1 aMessageNotUnderstoodBySmallInteger: #someArgument' ]
		on: InterpretationError
		do: [ :err| interpretationError := err ].
	
	dnu := interpretationError cause. 
	self assert: dnu message selector equals: #aMessageNotUnderstoodBySmallInteger:.
	self assert: dnu message arguments equals: {#someArgument}.
	self assert: dnu receiver equals: 1.
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testDNUCatched [
	|message|
	message := self interpret: 'DoesNotUnderstandCatcher new someUnknownMessage'.
	self assert: message selector equals: #someUnknownMessage.
	self assert: message arguments equals: #().
	
	message := self interpret: 'DoesNotUnderstandCatcher new someUnknownMessage: #someUnknownArg'.
	self assert: message selector equals: #someUnknownMessage:.
	self assert: message arguments equals: {#someUnknownArg}.
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testDNUInNestedBlock [
	| interpretationError dnu |
	
	[ self interpret: '[[ #someReceiver aMessageNotUnderstoodBySmallInteger: #someArgument ] value ] value' ]
		on: InterpretationError
		do: [ :err| interpretationError := err ].
	
	dnu := interpretationError cause. 
	self assert: dnu message selector equals: #aMessageNotUnderstoodBySmallInteger:.
	self assert: dnu message arguments equals: {#someArgument}.
	self assert: dnu receiver equals: #someReceiver.
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testEnsureBasic [

	self assert: (self interpret: '[ ] ensure: [ 2 ].') = nil.
	self assert: (self interpret: '[ 1 ] ensure: [ 2 ].') = 1.
	self assert: (self interpret: '[ 1 ] ensure: [ 2 ]. 3') = 3.
	
	self assert: (self interpret: '[ 1 ] ensure: [ ^ 2 ]. 3') = 2.
	self assert: (self interpret: '[ ^ 1 ] ensure: [ ^ 2 ]. 3') = 2.
	
	self should: [self interpret: '[ Error signal ] ensure: [ ^ 2 ]. 3'] raise: InterpretationError.
	self should: [self interpret: '[ [Error signal] value ] ensure: [ ^ 2 ]. 3' ] raise: InterpretationError.

]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testEnsureNonLocalReturn [
	"does not work"
	"self assert: false."
	self assert: (self interpret: '
		|x aCol|
		aCol := OrderedCollection new.
		x := ASTInterpreterTest new setUp ensureNonLocalReturn: aCol.
		x + aCol first
	') equals: 7
	
	
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testEnsureTricky [
	self assert: (self interpret: '(String streamContents: [:s | 
		[
		[s nextPutAll: 1 printString. 1/0] ensure: [s nextPutAll: 2 printString]
		] on: Error do: [s nextPutAll: 3 printString]
		]) asInteger') equals: 132.
	
	"not fixed yet"
	self assert: (self interpret: '[[Error signal] ensure: [1].3]on: Error do: [2]') equals: 2.

]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testException1 [
	[ (self interpret: 'Error signal: #anErrorHappened') ]
		on: InterpretationError
		do: [ :err | | originalError |
			originalError := err cause.
			self assert: (originalError isKindOf: Error).
			self assert: originalError messageText equals: #anErrorHappened.
			^ #success ].
	self fail.
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testExceptionCull [

	(self interpret: 'ASTInterpreterTest new should: [ [:x :y | ] cull: 1] raise: Error').
	
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testExceptionHandling [

	self assert: (self interpret: '[ ] on: Error do: [ :err| false ].') = nil.
	self assert: (self interpret: '[ ] on: Error do: [ :err| false ]. true') = true.
	self assert: (self interpret: '[ ] on: Error do: [ :err| ^ false ]. true') = true.
	
	self assert: (self interpret: '[ Error signal ] on: Error do: [ :err| false ]') = false.
	self assert: (self interpret: '[ Error signal ] on: Error do: [ :err| false ]. true') equals: true.
	self assert: (self interpret: '[ Error signal ] on: Error do: [ :err| ^ false ]. true') = false.
	
	self assert: (self interpret: '[[ Error signal ] value ] on: Error do: [ :err| false ]') = false.
	self assert: (self interpret: '[[ Error signal ] value ] on: Error do: [ :err| false ]. true') = true.
	self assert: (self interpret: '[[ Error signal ] value ] on: Error do: [ :err| ^ false ]. true') = false.
	
	self assert: (self interpret: '[self errorBlock value] on: Error do: [:err | false]') equals: false.
	self assert: (self interpret: '[self errorBlock value ] on: Error do: [ :err| false ]. true') = true.
	self assert: (self interpret: '[self errorBlock value ] on: Error do: [ :err| ^ false ]. true') = false.
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testExceptionResume [
	
	self assert: (self interpret: '[ 1 + Exception signal ] on: Exception do: [ :err| err resume: 5 ].') = 6.
	self assert: (self interpret: '[ 1 + Exception signal ] on: Exception do: [ :err| err resume: 5 ]. true') = true.
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testExceptionReturn [
	
	self assert: (self interpret: '[ Error signal ] on: Error do: [ :err| err return: 5 + 1 ].') = 6.
	self assert: (self interpret: '[ Error signal ] on: Error do: [ :err| err return: 5 + 1 ]. true') = true.
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testExternalBlock [
	self assert: (self interpret: 'ASTInterpreterTest new returningTempBlock') equals: ASTInterpreterTest new returningTempBlock.

	
	
	
]

{ #category : #testing }
ASTInterpreterTest >> testGlobals [
	self assert: (self interpret: 'Array') = Array
]

{ #category : #testing }
ASTInterpreterTest >> testInstanceCreation [
	self assert: ((self interpret: 'Array new') isKindOf: Array).
	self assert: ((self interpret: 'Array new: 10') isKindOf: Array).
	self assert: ((self interpret: 'OrderedCollection new') isKindOf: OrderedCollection).
	self assert: ((self interpret: 'Error new') isKindOf: Error).
	self assert: ((self interpret: 'MessageNotUnderstood new') isKindOf: MessageNotUnderstood)
]

{ #category : #testing }
ASTInterpreterTest >> testLazyInitialization [

	self assert: (self interpret: '
		ASTInterpreterTest new lazyInitialization
		') equals: 5.
	
]

{ #category : #testing }
ASTInterpreterTest >> testLookUp [

	self assert: (self interpret: '(ASTInterpreterTest selector: #foo) superSendInNestedBlock') equals: #foo.
	
]

{ #category : #testing }
ASTInterpreterTest >> testLoop [

	self assert: (self interpret: '
		|index|
		index := 1.
		[index := index + 1.
		index = 10 ] whileFalse.
		index
		') equals: 10.
		
	self assert: (self interpret: '
		ASTInterpreterTest new returningBlockInsideLoop
		') equals: ASTInterpreterTest new returningBlockInsideLoop.
		
	self assert: (self interpret: '
		ASTInterpreterTest new returningLoop
		') equals: ASTInterpreterTest new returningLoop.
	
	
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testMethodArguments [
	
	self assert: (self interpret: 'ASTInterpreterTest testMethodArguments: 1') = 1.
	
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testNonLocalReturn [

	self assert: (self interpret: 'false ifTrue: [ ^ 1 ]. ^ 1 + 1') = 2.
	self assert: (self interpret: 'true ifTrue: [ ^ 1 ]. ^ 1 + 1') = 1.
	
	self assert: (self interpret: 'false ifTrue: [ ^ 1 ] ifFalse: [^ 2]. 1 + 1 + 1') = 2.
]

{ #category : #'testing - blocks' }
ASTInterpreterTest >> testNonLocalReturnExternal [

	self assert: (self interpret: 'ASTInterpreterTest new returningBlockValue') 
		equals: ASTInterpreterTest new returningBlockValue
	
	
	
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testNotification [
	self interpret: 'Notification signal'
]

{ #category : #testing }
ASTInterpreterTest >> testPerform [
	self should: [self interpret: '#de perform: #negated'] raise: InterpretationError.
	self assert: (self interpret: '1 perform: #negated') equals: 1 negated.
	self assert: (self interpret: '1 perform: #+ with: 2') equals: 3.
	self assert: (self interpret: '1 perform: #+ withArguments: #(2)') equals: 3.
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testPrimitive [
	self assert: (self interpret: '1 + 1') = 2. "simple"
	self assert: (self interpret: '1 + 1.5') = 2.5. "with fallback"
]

{ #category : #testing }
ASTInterpreterTest >> testProtoObjectMethod [
	"This test works in you move Object>>#class to ProtoObject>>#class 
	I proposed the fix in the bug issue tracker "

	self interpret: 'ProtoObject new flag: #hallo'
]

{ #category : #testing }
ASTInterpreterTest >> testRepeat [
	self assert: (self interpret: '[^5] repeat') equals: 5.
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testSend [
	self assert: (self interpret: '#(1 2) at: 1') = 1.
	self assert: (self interpret: '1 + 2') = 3.
	"this is for future use :)"
	self assert: (self interpret: '123 asString') = '123'.
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testSignalException [
	[ self interpret: 'Exception signal' ]
		on: InterpretationError do: [ :error |
			self assert: (error cause isKindOf: SubclassResponsibility).
			^ self ].
	self fail.
]

{ #category : #'testing - exceptions' }
ASTInterpreterTest >> testSignalHalt [
	[ self interpret: '[1 halt] value' ]
		on: InterpretationError do: [ :error |
			self assert: error cause class equals: Halt.
			^ self ].
	self fail.
]

{ #category : #testing }
ASTInterpreterTest >> testString [
	self assert: (self interpret: 'String withAll: #($h $e $l $l $o)') equals: 'hello'.
	self assert: (self interpret: '$a asSymbol') equals: #a.
	self assert: (self interpret: '''a''') equals: 'a'.
	self assert: (self interpret: '''a'' asSymbol') equals: #a.	
	self assert: (self interpret: '(String withAll: #($h $e $l $l $o)) asSymbol') equals: #hello.
]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testSuperDNU [
	| interpretationError dnu |
	
	[ self interpret: 'InterpreterTest new unknownSuperSend' ]
		on: InterpretationError
		do: [ :err| interpretationError := err ].
	
	dnu := interpretationError cause. 
	self assert: dnu message selector equals: #aSelectorThatDoesNotExist.
	self assert: dnu message arguments isEmpty.
	self assert: (dnu receiver isKindOf: InterpreterTest).
	
	
	[ self interpret: 'InterpreterTest new unknownSuperSendInNestedBlock' ]
		on: InterpretationError
		do: [ :err| interpretationError := err ].
	
	dnu := interpretationError cause. 
	self assert: dnu message selector equals: #aSelectorThatDoesNotExist.
	self assert: dnu message arguments isEmpty.
	self assert: (dnu receiver isKindOf: InterpreterTest).
]

{ #category : #testing }
ASTInterpreterTest >> testThisContext [

	self assert: ((self interpret: 'thisContext') isKindOf: AIRootContext).
	"The home context of a AIRootContext is nil"
	self assert: (self interpret: 'thisContext home') equals: nil.
	self assert: (self interpret: 'thisContext homeContext') equals: nil.
	
	self assert: ((self interpret: 'ASTInterpreterTest new thisContextMethod') isKindOf: AIContext).
	self assert: ((self interpret: 'ASTInterpreterTest new thisContextCopyMethod') isKindOf: AIContext).

]

{ #category : #'testing - message sent' }
ASTInterpreterTest >> testUnarySend [
	self assert: (self interpret: '1 asInteger') = 1.
	self assert: (self interpret: '1 class') = SmallInteger.
]

{ #category : #testing }
ASTInterpreterTest >> testWeakSet [


	self assert: (self interpret: '
		| index start |
		index := start := 4 hash \\ 7 + 1.
		index
		') equals: 4 hash \\ 7 + 1.
	self assert: (self interpret: '
		| index start |
		index := start := 4 hash \\ 7 + 1.
		start
		') equals: 4 hash \\ 7 + 1.
		
	self assert: (self interpret: 'WeakSet new add: 1') equals: (WeakSet new add: 1).
	self assert: (self interpret: 'WeakSet new add: 1; scanFor: 1') equals: (WeakSet new add: 1; scanFor: 1)
	
]
