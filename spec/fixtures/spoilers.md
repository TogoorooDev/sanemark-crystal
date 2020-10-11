# Spoilers

Basic spoiler:

```````````````````````````````` example
>! spoiler text !<
.
<p><span class="spoiler"> spoiler text </span></p>
````````````````````````````````

Inside another block element:

```````````````````````````````` example
* The answer is >! spoiler text !<.
.
<ul>
<li>The answer is <span class="spoiler"> spoiler text </span>.</li>
</ul>
````````````````````````````````

Inline elements inside:

```````````````````````````````` example
>! *image:* ![alt](foo.png) !<
.
<p><span class="spoiler"> <em>image:</em> <img src="foo.png" alt="alt"> </span></p>
````````````````````````````````

Emphasis crossing the boundary:

```````````````````````````````` example
*start italics >! more italics* not italic !<
.
<p><em>start italics <span class="spoiler"> more italics</span></em><span class="spoiler"> not italic </span></p>
````````````````````````````````
