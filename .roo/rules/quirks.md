# Quirks

* nil checks should always be explicit. for example, never do `if something then`, and always do `if something ~= nil then`. The same goes for true and false values -- always be explicit in if checks, i.e. `if something == true` or `if something == false`.