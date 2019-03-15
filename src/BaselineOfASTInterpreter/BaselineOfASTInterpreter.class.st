Class {
	#name : #BaselineOfASTInterpreter,
	#superclass : #BaselineOf,
	#category : #BaselineOfASTInterpreter
}

{ #category : #baselines }
BaselineOfASTInterpreter >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: #'AST-Interpreter-Core';
				package: #'AST-Interpreter-Extension';
				package: #'AST-Interpreter-Test' ]
]
