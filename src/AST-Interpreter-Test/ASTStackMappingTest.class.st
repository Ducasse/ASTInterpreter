"
SUnit tests for stack mapping
"
Class {
	#name : #ASTStackMappingTest,
	#superclass : #TestCase,
	#instVars : [
		'methodContext',
		'blockContext'
	],
	#category : #'AST-Interpreter-Test-Tests'
}

{ #category : #accessing }
ASTStackMappingTest >> blockContext [
	^ blockContext
]

{ #category : #methods }
ASTStackMappingTest >> foo: anArg [
	|a|
	a := anArg.
	^thisContext copy asASTInterpreterContext.
]

{ #category : #methods }
ASTStackMappingTest >> fooAdd2: foo [
	^foo + 2
]

{ #category : #accessing }
ASTStackMappingTest >> methodContext [
	^ methodContext
]

{ #category : #running }
ASTStackMappingTest >> setUp [
	blockContext := [] asContext.
	methodContext := thisContext copy.
]

{ #category : #testing }
ASTStackMappingTest >> testBlockTemporaries [
	|blockCtx|
	
	[ :x :y | x+y. blockCtx := thisContext copy asASTInterpreterContext ] value: 5 value: 7.

	self assert: (blockCtx temporaries at: 'x') = 5.
	self assert: (blockCtx temporaries at: 'y') = 7.
	
	
]

{ #category : #testing }
ASTStackMappingTest >> testConvertBlockContext [
	| aSTBlockContext |
	aSTBlockContext := self blockContext asASTInterpreterContext.
	self assert: self blockContext home asASTInterpreterContext = aSTBlockContext homeContext.
	
	self assert: self blockContext outerContext asASTInterpreterContext equals: aSTBlockContext outerContext.
	self assert: self blockContext closure asASTBlockClosure equals: aSTBlockContext closure.
	self assert: self blockContext tempNames equals: aSTBlockContext temporaries keys.
	self assert: self blockContext arguments equals: aSTBlockContext arguments.
	
]

{ #category : #testing }
ASTStackMappingTest >> testConvertMethodContext [
	| aSTMethodContext |
	aSTMethodContext := self methodContext asASTInterpreterContext.
	
	self assert: self methodContext outerContext asASTInterpreterContext equals: aSTMethodContext outerContext.
	self assert: self methodContext method = aSTMethodContext closure.
	self assert: self methodContext tempNames  = aSTMethodContext temporaries keys.
	self assert: self methodContext arguments  = aSTMethodContext arguments.
	self assert: self methodContext receiver = aSTMethodContext receiver.
]

{ #category : #testing }
ASTStackMappingTest >> testException [
	|exceptionBlock blockCtx astBlockCtx|
	
	exceptionBlock := [ Transcript show: 'banana' ].
	
	[ blockCtx :=  thisContext copy.
	astBlockCtx := blockCtx asASTInterpreterContext. 
	Error signal] on: Error do: exceptionBlock.
	
	self assert: astBlockCtx exceptionHandler exception equals: Error.
	self assert: astBlockCtx exceptionHandler block equals:  exceptionBlock.
]

{ #category : #testing }
ASTStackMappingTest >> testInterpret [
	|foo bar|
	
	"will fail : goal"
	<expectedFailure>
	
	foo := 1.
	foo := foo + 1.
	self assert: foo = 2.
	self assert: (thisContext copy isKindOf: Context).
	Smalltalk switchInterpreterTo: thisContext copy asASTInterpreterContext.
	foo := foo + 2.
	self assert: foo = 4.
	self assert: (thisContext copy isKindOf: AIContext).
]

{ #category : #testing }
ASTStackMappingTest >> testInterpretBasic [
	|ctx result block |
	
	<expectedFailure>
	
	block := [ctx := thisContext copy.self fooAdd2: 4 ].
	block value.
	result := ASTInterpreter interpretVMContext: ctx.
	"self assert: (result isKindOf: ASTBlockClosure).
	self assert: (result homeContext tempNamed: #tmp) equals: block value."
	self assert: result equals: 6.
]

{ #category : #testing }
ASTStackMappingTest >> testMethodArgs [
	|methodCtx|
	
	"foo: anArg
	|a|
	a := anArg.
	^thisContext copy asASTInterpreterContext."
	methodCtx := self foo: 'bar'.
	
	self assert: (methodCtx arguments includes: 'bar').
	self assert: (methodCtx temporaries at: 'a') =  'bar'.
	self assert: (methodCtx temporaries at: 'anArg') =  'bar'.
]

{ #category : #testing }
ASTStackMappingTest >> testTemporaries [
	| a b c ctx blockCtx|
	a := 1.
	b := True .
	c := 'guineaPig'.
	
	ctx := thisContext copy asASTInterpreterContext.
	
	self assert: (ctx temporaries at: 'a') = 1.
	self assert: (ctx temporaries at: 'b') = True.
	self assert: (ctx temporaries at: 'c') = 'guineaPig'.
	
	
]
