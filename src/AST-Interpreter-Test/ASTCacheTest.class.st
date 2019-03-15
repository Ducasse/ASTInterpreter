"
SUnit tests for ASTCache
"
Class {
	#name : #ASTCacheTest,
	#superclass : #TestCase,
	#instVars : [
		'cache',
		'compiledMethod'
	],
	#category : #'AST-Interpreter-Test-Tests'
}

{ #category : #running }
ASTCacheTest >> setUp [
	ASTCache reset.
	compiledMethod := ASTCacheTest >> #setUp.
]

{ #category : #tests }
ASTCacheTest >> testInCache [
	self deny: (ASTCache default includesKey: compiledMethod).
	
	compiledMethod ast.
	
	self assert: (ASTCache default includesKey: compiledMethod).
]

{ #category : #tests }
ASTCacheTest >> testRecompile [
	compiledMethod ast.
	
	self assert: (ASTCache default includesKey: compiledMethod).
	
	"recompile the test method and avoid referring to the old method"
	compiledMethod := compiledMethod recompile.
	"trigger garbage collection to free the ASTCache"
	Smalltalk garbageCollect.
	
	self deny: (ASTCache default includesKey: compiledMethod).
]

{ #category : #tests }
ASTCacheTest >> testReset [
	compiledMethod ast.
	
	self assert: (ASTCache default includesKey: compiledMethod).
	
	ASTCache reset.
	
	self deny: (ASTCache default includesKey: compiledMethod).
]
