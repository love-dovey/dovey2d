# Code-style

NOTE: keeping your code consistent is more important than following these guidelines.

This style guide is really only valid if you're making Pull Requests as we'd prefer to keep consistency.

---

## Formatting
	- Use Tabs instead of spaces for indentation.
		- HINT: in Sublime Text, you can use the command palette (Ctrl+Shift+P) and look for "Indentation: Convert to Tabs" to reindent your existing code with tabs.
	- Do not leave trailing spaces anywhere.
		- HINT: in Sublime Text, you can use the command palette (Ctrl+Shift+P) and look for "Trim Trailing White Space" to remove all of those.

## Scripting
	- Documentation comments must have 3 dashes
	- Open brackets for tables must happen in the same line as the table
	- Constant variables (even if in a local scope) must use UPPER_SNAKE_CASE
	- Tables or Metatables that get returned must use PascalCase
	- Tables or Metatables that have instance functions must use `self` and not `TableName`
	- Non-constant variables must use camelCase
	- Script names must use camelCase

### Code example:
```lua
local CONSTANT_VALUE = 1
local privateVariable = "I'm private."
--- This is an example.
--- @class CodeStyleExample
local CodeStyleExample = {
	publicVariable = "However, I'm public."
}

--- This function returns a public value defined inside `CodeStyleExample`.
--- @return String
function CodeStyleExample:instanceFunction()
	return self.publicVariable
end

--- This function returns a static string value which is defined within itself.
--- @return String
function CodeStyleExample.staticFunction()
	return "value"
end

-- Non-doc comments can just have 2 dashes instead.
return CodeStyleExample
```

---

This file may be updated in the future.
