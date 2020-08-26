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

```````````````````````````````` example
a***b* c*
.
<p>a**<em>b</em> c*</p>
````````````````````````````````

Issue jgm/CommonMark#468 - backslash at end of link definition

```````````````````````````````` example
[\]: test
.
<p>[]: test</p>
````````````````````````````````
