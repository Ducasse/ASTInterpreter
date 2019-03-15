Extension { #name : #OCSlotVariable }

{ #category : #'*AST-Interpreter-Core' }
OCSlotVariable >> accept: anInterpreter assign: aValue inNode: aVariableNode [
	^slot accept: anInterpreter assign: aValue inNode: aVariableNode
]

{ #category : #'*AST-Interpreter-Core' }
OCSlotVariable >> readWith: anInterpreter inNode: aVariableNode [ 
	^slot readWith: anInterpreter inNode: aVariableNode
]
