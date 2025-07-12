# Architecture

First and foremost, Moonlight is built from the ground up to be verifiable and correct. At no time is any code allowed to be submitted to the code repository if it contains an linting error of any sort.

All functions and all types are always meticulously annotated as if it were written in a typed language. This focus on correctness ensures a minimal amount of bugs due to null references, missing table definitions, and other difficult to debug issues.

Moonlight does not use any external libraries at all, with the exception of LibStub if required to plugin or interface with other addons. This means a complete and total custom code base that is fully under Moonlight's control is a primary goal of Moonlight.

All rendered windows are abstractions of a base window feature. Window's can have themes and decorators, and other features, irrespective of what they are displaying. This uniform method of drawing windows is critical for a uniform feel to all content.