# Regression tests

Eating a character after a partially consumed tab.

```````````````````````````````` example
* foo
→bar
.
<ul>
<li>foo
bar</li>
</ul>
````````````````````````````````

Issue #108 - Chinese punctuation not recognized

```````````````````````````````` example
**。**话
.
<p>**。**话</p>
````````````````````````````````

Issue jgm/cmark#177 - incorrect emphasis parsing

```````````````````````````````` example
a***b* c*
.
<p>a*<em><em>b</em> c</em></p>
````````````````````````````````

Issue jgm/CommonMark#468 - backslash at end of link definition

```````````````````````````````` example
[\]: test
.
<p>[]: test</p>
````````````````````````````````
