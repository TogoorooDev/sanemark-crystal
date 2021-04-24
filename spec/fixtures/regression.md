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

Unicode messing up inline HTML when HTML is allowed.
```````````````````````````````` example
<span>ɑ</span>
.
<p><span>ɑ</span></p>
````````````````````````````````

Multiple spoilers.
```````````````````````````````` example
>! a !<
>! b !<
````````````````````````````````
