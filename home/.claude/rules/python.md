* Always include typehints using modern type hint syntax if the python version allows it. This means using, e.g., `list[int]` instead of importing `List` from typing, and using `|` instead of `Optional`.
* When you write one-off scripts assume that an appropriate python environment exists, you don't need to verify that packages you want to use are available, leave that to me.
* When working on python packages always assume we're using `uv` for our venvs and, `ruff` for linting and `ty` for typechecking unless instructed otherwise.
