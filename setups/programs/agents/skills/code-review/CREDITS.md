# Credits

## code-review

[`SKILL.md`](SKILL.md) and `agents/` are copied from the **code-review** skill
by **Matt Pocock**:

<https://github.com/mattpocock/skills/tree/main/skills/engineering/code-review>

What this copy changed: lines were wrapped at 120 characters, and a paragraph
was added for callers that ask for blocking findings only, and a third review
axis, Design, was added beside Standards and Spec. The diff now includes
uncommitted work, and sub-agents read it, the spec and the design sources
from files and run as the client's review agent. The Spec axis also checks
changes to existing input validation and error handling, and the description
no longer restates the axes.

## License

```text
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
