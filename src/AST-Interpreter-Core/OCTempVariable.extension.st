Extension { #name : #OCTempVariable }

{ #category : #'*AST-Interpreter-Core' }
OCTempVariable >> accept: anInterpeter assign: value inNode: aVariableNode [
	self isArg ifTrue: [ 
		self error: 'Arguments cannot be assigned'.
	].
	"If it is not an arg, it is a normal temporary"
	^ anInterpeter write: value temporaryAt: -1 named: name
]

{ #category : #'*AST-Interpreter-Core' }
OCTempVariable >> readWith: anInterpreter inNode: aVariableNode [
	self isArg ifTrue: [ 
		| definingScope argIndex |
		definingScope := aVariableNode binding definingScope.
		argIndex := definingScope node argumentNames indexOf: name.
		^ anInterpreter readArgumentAt: argIndex node: aVariableNode
	].
	"If it is not an arg, it is a normal temporary"
	^ anInterpreter readTemporaryAt: -1 named: name
]
