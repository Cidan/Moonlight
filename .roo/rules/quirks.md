# Quirks

* nil checks should always be explicit. for example, never do `if something then`, and always do `if something ~= nil then`. The same goes for true and false values -- always be explicit in if checks, i.e. `if something == true` or `if something == false`.

* generally speaking, a file called `types.lua` is never actually executed in the game environment and is meant only for type checking. Do not store tables, enums, variables, etc in a `types.lua` file unless it is only comments/annotations.