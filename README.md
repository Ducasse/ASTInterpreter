# ASTInterpreter
Basic AST interpreter for Pharo

## Example

```smalltalk
interpreter := ASTInterpreter new.
context := AIRootContext new.
interpreter resetContext: context.

compiledCode := interpreter compile: '1+1'.
interpreter interpretDoIt: compiledCode.
```
