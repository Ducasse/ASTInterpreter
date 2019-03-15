Extension { #name : #OCLiteralVariable }

{ #category : #'*AST-Interpreter-Core' }
OCLiteralVariable >> accept: aVisitor assign: aValue inNode: aVariableNode [
	^self assoc value: aValue
]

{ #category : #'*AST-Interpreter-Core' }
OCLiteralVariable >> readWith: anInterpreter inNode: aVariableNode [ 
	^ self value
]
