In the examples, the `→` character is used to represent tabs.

## Tabs

Tabs in lines are not expanded to spaces. However,
in contexts where whitespace helps to define block structure,
tabs are equivalent to 4 spaces.

Thus, for example, a tab can be used instead of four spaces
in an indented code block. (Note, however, that internal
tabs are passed through as literal tabs, not expanded to
spaces.)

```````````````````````````````` example
→foo→baz→→bim
.
<pre><code>foo→baz→→bim
</code></pre>
````````````````````````````````

```````````````````````````````` example
  →foo→baz→→bim
.
<pre><code>foo→baz→→bim
</code></pre>
````````````````````````````````

```````````````````````````````` example
    a→a
    ὐ→a
.
<pre><code>a→a
ὐ→a
</code></pre>
````````````````````````````````

In the following example, a continuation paragraph of a list
item is indented with a tab; this has exactly the same effect
as indentation with four spaces would:

```````````````````````````````` example
  - foo

→bar
.
<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
````````````````````````````````

TODO The following behavior makes no bloody sense, but I haven't ripped it out yet:

```````````````````````````````` example
- foo

→→bar
.
<ul>
<li>
<p>foo</p>
<pre><code>  bar
</code></pre>
</li>
</ul>
````````````````````````````````

Normally the `>` that begins a block quote may be followed
optionally by a space, which is not considered part of the
content. In the following case `>` is followed by a tab,
which is treated as if it were expanded into spaces.
Since one of theses spaces is considered part of the
delimiter, `foo` is considered to be indented six spaces
inside the block quote context, so we get an indented
code block starting with two spaces.

```````````````````````````````` example
>→→foo
.
<blockquote>
<pre><code>  foo
</code></pre>
</blockquote>
````````````````````````````````

```````````````````````````````` example
-→→foo
.
<ul>
<li>
<pre><code>  foo
</code></pre>
</li>
</ul>
````````````````````````````````


```````````````````````````````` example
    foo
→bar
.
<pre><code>foo
bar
</code></pre>
````````````````````````````````

```````````````````````````````` example
 - foo
   - bar
→ - baz
.
<ul>
<li>foo
<ul>
<li>bar
<ul>
<li>baz</li>
</ul>
</li>
</ul>
</li>
</ul>
````````````````````````````````

# Blocks and inlines

We can think of a document as a sequence of
**blocks**---structural elements like paragraphs, block
quotations, lists, headings, rules, and code blocks. Some blocks (like
block quotes and list items) contain other blocks; others (like
headings and paragraphs) contain **inline** content---text,
links, emphasized text, images, code, and so on.

## Precedence

Indicators of block structure always take precedence over indicators
of inline structure. So, for example, the following is a list with
two items, not a list with one item containing a code span:

```````````````````````````````` example
- `one
- two`
.
<ul>
<li>`one</li>
<li>two`</li>
</ul>
````````````````````````````````

This means that parsing can proceed in two steps:  first, the block structure of the document can be discerned; second, text lines inside paragraphs, headings, and other block constructs can be parsed for inline structure. Note that the first step requires processing lines in sequence, but the second can be parallelized, since the inline parsing of one block element does not affect the inline parsing of any other.

## Container blocks and leaf blocks

We can divide blocks into two types: **container block**s, which can contain other blocks, and **leaf block**s, which cannot.

# Leaf blocks

## Thematic breaks

A line consisting of three or more matching `-` or `*` characters and nothing else forms a **thematic break**.

```````````````````````````````` example
***
---
.
<hr>
<hr>
````````````````````````````````

Not enough characters:

```````````````````````````````` example
--
**
.
<p>--
**</p>
````````````````````````````````

Thematic breaks cannot be indented:

```````````````````````````````` example
 ***
.
<p>***</p>
````````````````````````````````

More than three characters may be used:

```````````````````````````````` example
-------------------------------------
.
<hr>
````````````````````````````````

It is required that all of the non-whitespace characters be the same.
So, this is not a thematic break:

```````````````````````````````` example
*-*
.
<p><em>-</em></p>
````````````````````````````````

Thematic breaks do not need blank lines before or after:

```````````````````````````````` example
- foo
***
- bar
.
<ul>
<li>foo</li>
</ul>
<hr>
<ul>
<li>bar</li>
</ul>
````````````````````````````````

Thematic breaks can interrupt a paragraph:

```````````````````````````````` example
Foo
***
bar
.
<p>Foo</p>
<hr>
<p>bar</p>
````````````````````````````````

When both a thematic break and a list item are possible
interpretations of a line, the thematic break takes precedence:

```````````````````````````````` example
* Foo
***
* Bar
.
<ul>
<li>Foo</li>
</ul>
<hr>
<ul>
<li>Bar</li>
</ul>
````````````````````````````````

If you want a thematic break in a list item, use a different bullet:

```````````````````````````````` example
- Foo
- ***
.
<ul>
<li>Foo</li>
<li>
<hr>
</li>
</ul>
````````````````````````````````

## Headings

A **heading** consists of a string of characters, parsed as inline content, after an opening sequence of 1--6 unescaped `#` characters followed by a space. The heading level is equal to the number of `#` characters in the opening sequence.

Simple headings:

```````````````````````````````` example
# foo
## foo
### foo
#### foo
##### foo
###### foo
.
<h1>foo</h1>
<h2>foo</h2>
<h3>foo</h3>
<h4>foo</h4>
<h5>foo</h5>
<h6>foo</h6>
````````````````````````````````


More than six `#` characters is not a heading:

```````````````````````````````` example
####### foo
.
<p>####### foo</p>
````````````````````````````````

At least one space is required after the `#` characters. This helps prevent things like the following from being parsed as headings:

```````````````````````````````` example
#5 bolt

#hashtag
.
<p>#5 bolt</p>
<p>#hashtag</p>
````````````````````````````````

This is not a heading, because the first `#` is escaped:

```````````````````````````````` example
\## foo
.
<p>## foo</p>
````````````````````````````````

Contents are parsed as inlines:

```````````````````````````````` example
# foo *bar* \*baz\*
.
<h1>foo <em>bar</em> *baz*</h1>
````````````````````````````````

Leading and trailing blanks are ignored in parsing inline content (except where part of the grammar):

```````````````````````````````` example
#  foo 
.
<h1> foo </h1>
````````````````````````````````

Heading markers must be at the beginning of the line:

```````````````````````````````` example
 # foo
.
<p># foo</p>
````````````````````````````````

Headings need not be separated from surrounding content by blank lines, and they can interrupt paragraphs:

```````````````````````````````` example
****
## foo
****
.
<hr>
<h2>foo</h2>
<hr>
````````````````````````````````

```````````````````````````````` example
Foo bar
# baz
Bar foo
.
<p>Foo bar</p>
<h1>baz</h1>
<p>Bar foo</p>
````````````````````````````````

Since the space after the `#` characters is part of the heading marker, an empty heading is possible but requires an invisible trailing space:

```````````````````````````````` example
# 
#
.
<h1></h1>
<p>#</p>
````````````````````````````````

## Indented code blocks

An **indented code block** is composed of one or more
indented chunks separated by blank lines.
An **indented chunk** is a sequence of non-blank lines,
each indented four or more spaces. The contents of the code block are
the literal contents of the lines, including trailing
line endings, minus four spaces of indentation.
An indented code block has no info string.

An indented code block cannot interrupt a paragraph, so there must be
a blank line between a paragraph and a following indented code block.
(A blank line is not needed, however, between a code block and a following
paragraph.)

```````````````````````````````` example
    a simple
      indented code block
.
<pre><code>a simple
  indented code block
</code></pre>
````````````````````````````````


If there is any ambiguity between an interpretation of indentation
as a code block and as indicating that material belongs to a [list
item]list items, the list item interpretation takes precedence:

```````````````````````````````` example
  - foo

    bar
.
<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
````````````````````````````````


```````````````````````````````` example
1.  foo

    - bar
.
<ol>
<li>
<p>foo</p>
<ul>
<li>bar</li>
</ul>
</li>
</ol>
````````````````````````````````



The contents of a code block are literal text, and do not get parsed
as Markdown:

```````````````````````````````` example
    <a/>
    *hi*

    - one
.
<pre><code>&lt;a/&gt;
*hi*

- one
</code></pre>
````````````````````````````````


Here we have three chunks separated by blank lines:

```````````````````````````````` example
    chunk1

    chunk2
  
 
 
    chunk3
.
<pre><code>chunk1

chunk2



chunk3
</code></pre>
````````````````````````````````


Any initial spaces beyond four will be included in the content, even
in interior blank lines:

```````````````````````````````` example
    chunk1
      
      chunk2
.
<pre><code>chunk1
  
  chunk2
</code></pre>
````````````````````````````````


An indented code block cannot interrupt a paragraph. (This
allows hanging indents and the like.)

```````````````````````````````` example
Foo
    bar

.
<p>Foo
bar</p>
````````````````````````````````


However, any non-blank line with fewer than four leading spaces ends
the code block immediately. So a paragraph may occur immediately
after indented code:

```````````````````````````````` example
    foo
bar
.
<pre><code>foo
</code></pre>
<p>bar</p>
````````````````````````````````


And indented code can occur immediately before and after other kinds of
blocks:

```````````````````````````````` example
# Heading
    foo
----
.
<h1>Heading</h1>
<pre><code>foo
</code></pre>
<hr>
````````````````````````````````


The first line can be indented more than four spaces:

```````````````````````````````` example
        foo
    bar
.
<pre><code>    foo
bar
</code></pre>
````````````````````````````````


Blank lines preceding or following an indented code block
are not included in it:

```````````````````````````````` example

    
    foo
    

.
<pre><code>foo
</code></pre>
````````````````````````````````


Trailing spaces are included in the code block's content:

```````````````````````````````` example
    foo  
.
<pre><code>foo  
</code></pre>
````````````````````````````````



## Fenced code blocks

A **code fence** is a sequence
of at least three consecutive backtick characters (`` ` ``) or
tildes (`~`). (Tildes and backticks cannot be mixed.)
A **fenced code block**
begins with a code fence, indented no more than three spaces.

The line with the opening code fence may optionally contain some text
following the code fence; this is trimmed of leading and trailing
spaces and called the **info string**.
The info string may not contain any backtick
characters. (The reason for this restriction is that otherwise
some inline code would be incorrectly interpreted as the
beginning of a fenced code block.)

The content of the code block consists of all subsequent lines, until
a closing code fence of the same type as the code block
began with (backticks or tildes), and with at least as many backticks
or tildes as the opening code fence. If the leading code fence is
indented N spaces, then up to N spaces of indentation are removed from
each line of the content (if present). (If a content line is not
indented, it is preserved unchanged. If it is indented less than N
spaces, all of the indentation is removed.)

The closing code fence may be indented up to three spaces, and may be
followed only by spaces, which are ignored. If the end of the
containing block (or document) is reached and no closing code fence
has been found, the code block contains all of the lines after the
opening code fence until the end of the containing block (or
document). (An alternative spec would require backtracking in the
event that a closing code fence is not found. But this makes parsing
much less efficient, and there seems to be no real down side to the
behavior described here.)

A fenced code block may interrupt a paragraph, and does not require
a blank line either before or after.

The content of a code fence is treated as literal text, not parsed
as inlines. The first word of the info string is typically used to
specify the language of the code sample, and rendered in the `class`
attribute of the `code` tag. However, this spec does not mandate any
particular treatment of the info string.

Here is a simple example with backticks:

```````````````````````````````` example
```
<
 >
```
.
<pre><code>&lt;
 &gt;
</code></pre>
````````````````````````````````


With tildes:

```````````````````````````````` example
~~~
<
 >
~~~
.
<pre><code>&lt;
 &gt;
</code></pre>
````````````````````````````````


The closing code fence must use the same character as the opening
fence:

```````````````````````````````` example
```
aaa
~~~
```
.
<pre><code>aaa
~~~
</code></pre>
````````````````````````````````


```````````````````````````````` example
~~~
aaa
```
~~~
.
<pre><code>aaa
```
</code></pre>
````````````````````````````````

The closing code fence must be exactly as long as the opening fence:

```````````````````````````````` example
````
aaa
```
.
<pre><code>aaa
```
</code></pre>
````````````````````````````````

```````````````````````````````` example
```
aaa
````
.
<pre><code>aaa
````
</code></pre>
````````````````````````````````

```````````````````````````````` example
~~~~
aaa
~~~
~~~~
.
<pre><code>aaa
~~~
</code></pre>
````````````````````````````````

Unclosed code blocks are closed by the end of the document
(or the enclosing block quote or list item):

```````````````````````````````` example
```
.
<pre><code></code></pre>
````````````````````````````````

```````````````````````````````` example
`````

```
aaa
.
<pre><code>
```
aaa
</code></pre>
````````````````````````````````

```````````````````````````````` example
> ```
> aaa

bbb
.
<blockquote>
<pre><code>aaa
</code></pre>
</blockquote>
<p>bbb</p>
````````````````````````````````

A code block can have all empty lines as its content:

```````````````````````````````` example
```

  
```
.
<pre><code>
  
</code></pre>
````````````````````````````````

A code block can be empty:

```````````````````````````````` example
```
```
.
<pre><code></code></pre>
````````````````````````````````

The fences must be at the start of the line:

```````````````````````````````` example
 ```
 aaa
 ```
.
<p>``<code> aaa </code>``</p>
````````````````````````````````

Code fences (opening and closing) cannot contain internal spaces:

```````````````````````````````` example
``` ```
aaa
.
<p>``<code> </code>``
aaa</p>
````````````````````````````````


```````````````````````````````` example
~~~~~~
aaa
~~~ ~~
.
<pre><code>aaa
~~~ ~~
</code></pre>
````````````````````````````````


Fenced code blocks can interrupt paragraphs, and can be followed
directly by paragraphs, without a blank line between:

```````````````````````````````` example
foo
```
bar
```
baz
.
<p>foo</p>
<pre><code>bar
</code></pre>
<p>baz</p>
````````````````````````````````


An info string can be provided after the opening code fence.
Opening and closing spaces will be stripped, and the first word, prefixed
with `language-`, is used as the value for the `class` attribute of the
`code` element within the enclosing `pre` element.

```````````````````````````````` example
```ruby
def foo(x)
  return 3
end
```
.
<pre><code class="language-ruby">def foo(x)
  return 3
end
</code></pre>
````````````````````````````````


```````````````````````````````` example
~~~~    ruby startline=3 $%@#$
def foo(x)
  return 3
end
~~~~
.
<pre><code class="language-ruby">def foo(x)
  return 3
end
</code></pre>
````````````````````````````````


```````````````````````````````` example
````;
````
.
<pre><code class="language-;"></code></pre>
````````````````````````````````


Info strings for backtick code blocks cannot contain backticks:

```````````````````````````````` example
``` aa ```
foo
.
<p>``<code> aa </code>``
foo</p>
````````````````````````````````


Closing code fences cannot have info strings:

```````````````````````````````` example
```
``` aaa
```
.
<pre><code>``` aaa
</code></pre>
````````````````````````````````


## HTML blocks

When HTML escaping is not enabled, certain HTML blocks will not be processed as Markdown text: `<script>`, `<style>`, `<pre>`, HTML comments, and declarations like `<!DOCTYPE html>`.

The end tag can occur on the same line as the start tag:

```````````````````````````````` example
<style>p{color:red;}</style>
*foo*
.
<style>p{color:red;}</style>
<p><em>foo</em></p>
````````````````````````````````


```````````````````````````````` example
<!-- foo -->*bar*
*baz*
.
<!-- foo -->*bar*
<p><em>baz</em></p>
````````````````````````````````


Note that anything on the last line after the
end tag will be included in the HTML block:

```````````````````````````````` example
<script>
foo
</script>1. *bar*
.
<script>
foo
</script>1. *bar*
````````````````````````````````


A comment:

```````````````````````````````` example
<!-- Foo

bar
   baz -->
okay
.
<!-- Foo

bar
   baz -->
<p>okay</p>
````````````````````````````````

A declaration:

```````````````````````````````` example
<!DOCTYPE html>
.
<!DOCTYPE html>
````````````````````````````````

HTML tags other than these will be treated as inline, meaning their contents are processed as Markdown and they will create a paragraph:

```````````````````````````````` example
<div>*foo*</div>
.
<p><div><em>foo</em></div></p>
````````````````````````````````

```````````````````````````````` example
<div>
*foo*
</div>
.
<div>
<p><em>foo</em></p>
</div>
````````````````````````````````

Blank lines don't affect the above rule:

```````````````````````````````` example
<div>

*foo*

</div>
.
<div>
<p><em>foo</em></p>
</div>
````````````````````````````````

To prevent all Markdown processing for an HTML element other than the special ones listed above, there is one more special tag: `nomd`:

```````````````````````````````` example
<nomd>

<div>*foo*</div>

</nomd>
.
<div>*foo*</div>
````````````````````````````````

## Paragraphs

A sequence of non-blank lines that cannot be interpreted as other
kinds of blocks forms a **paragraph**.
The contents of the paragraph are the result of parsing the
paragraph's raw content as inlines. The paragraph's raw content
is formed by concatenating the lines and removing initial and final
whitespace.

A simple example with two paragraphs:

```````````````````````````````` example
aaa

bbb
.
<p>aaa</p>
<p>bbb</p>
````````````````````````````````


Paragraphs can contain multiple lines, but no blank lines:

```````````````````````````````` example
aaa
bbb

ccc
ddd
.
<p>aaa
bbb</p>
<p>ccc
ddd</p>
````````````````````````````````


Multiple blank lines between paragraph have no effect:

```````````````````````````````` example
aaa


bbb
.
<p>aaa</p>
<p>bbb</p>
````````````````````````````````


Leading spaces are skipped:

```````````````````````````````` example
  aaa
 bbb
.
<p>aaa
bbb</p>
````````````````````````````````


Lines after the first may be indented any amount, since indented
code blocks cannot interrupt paragraphs.

```````````````````````````````` example
aaa
             bbb
                                       ccc
.
<p>aaa
bbb
ccc</p>
````````````````````````````````


However, the first line may be indented at most three spaces,
or an indented code block will be triggered:

```````````````````````````````` example
   aaa
bbb
.
<p>aaa
bbb</p>
````````````````````````````````


```````````````````````````````` example
    aaa
bbb
.
<pre><code>aaa
</code></pre>
<p>bbb</p>
````````````````````````````````

## Blank lines

Blank lines between block-level elements are ignored,
except for the role they play in determining whether a list
is tight or loose.

Blank lines at the beginning and end of the document are also ignored.

```````````````````````````````` example
  

aaa
  

# aaa

  
.
<p>aaa</p>
<h1>aaa</h1>
````````````````````````````````



# Container blocks

A container block is a block that has other
blocks as its contents. There are two basic kinds of container blocks:
block quotes and list items.
Lists are meta-containers for list items.

We define the syntax for container blocks recursively. The general
form of the definition is:

> If X is a sequence of blocks, then the result of
> transforming X in such-and-such a way is a container of type Y
> with these blocks as its content.

So, we explain what counts as a block quote or list item by explaining
how these can be *generated* from their contents. This should suffice
to define the syntax, although it does not give a recipe for *parsing*
these constructions.

## Block quotes

A **block quote marker**
consists of 0-3 spaces of initial indent, plus (a) the character `>` together
with a following space, or (b) a single character `>` not followed by a space.

The following rules define block quotes:

1.  **Basic case.**  If a string of lines *Ls* constitute a sequence
    of blocks *Bs*, then the result of prepending a [block quote
    marker] to the beginning of each line in *Ls*
    is a block quote containing *Bs*.

2.  **Laziness.**  If a string of lines *Ls* constitute a block
    quote with contents *Bs*, then the result of deleting
    the initial block quote marker from one or
    more lines in which the next non-whitespace character after the [block
    quote marker] is [paragraph continuation
    text] is a block quote with *Bs* as its content.
    **Paragraph continuation text** is text
    that will be parsed as part of the content of a paragraph, but does
    not occur at the beginning of the paragraph.

3.  **Consecutiveness.**  A document cannot contain two block
    quotes in a row unless there is a blank line between them.

Here is a simple example:

```````````````````````````````` example
> # Foo
> bar
> baz
.
<blockquote>
<h1>Foo</h1>
<p>bar
baz</p>
</blockquote>
````````````````````````````````


The spaces after the `>` characters can be omitted:

```````````````````````````````` example
># Foo
>bar
> baz
.
<blockquote>
<h1>Foo</h1>
<p>bar
baz</p>
</blockquote>
````````````````````````````````


The `>` characters cannot be indented:

```````````````````````````````` example
 > Foo
.
<p>&gt; Foo</p>
````````````````````````````````

The Laziness clause allows us to omit the `>` before
paragraph continuation text:

```````````````````````````````` example
> # Foo
> bar
baz
.
<blockquote>
<h1>Foo</h1>
<p>bar
baz</p>
</blockquote>
````````````````````````````````


A block quote can contain some lazy and some non-lazy
continuation lines:

```````````````````````````````` example
> bar
baz
> foo
.
<blockquote>
<p>bar
baz
foo</p>
</blockquote>
````````````````````````````````


Laziness only applies to lines that would have been continuations of
paragraphs had they been prepended with block quote markers.
For example, the `> ` cannot be omitted in the second line of

``` markdown
> foo
> ---
```

without changing the meaning:

```````````````````````````````` example
> foo
---
.
<blockquote>
<p>foo</p>
</blockquote>
<hr>
````````````````````````````````


Similarly, if we omit the `> ` in the second line of

``` markdown
> - foo
> - bar
```

then the block quote ends after the first line:

```````````````````````````````` example
> - foo
- bar
.
<blockquote>
<ul>
<li>foo</li>
</ul>
</blockquote>
<ul>
<li>bar</li>
</ul>
````````````````````````````````


For the same reason, we can't omit the `> ` in front of
subsequent lines of an indented or fenced code block:

```````````````````````````````` example
>     foo
    bar
.
<blockquote>
<pre><code>foo
</code></pre>
</blockquote>
<pre><code>bar
</code></pre>
````````````````````````````````


```````````````````````````````` example
> ```
foo
```
.
<blockquote>
<pre><code></code></pre>
</blockquote>
<p>foo</p>
<pre><code></code></pre>
````````````````````````````````


Note that in the following case, we have a lazy
continuation line:

```````````````````````````````` example
> foo
    - bar
.
<blockquote>
<p>foo
- bar</p>
</blockquote>
````````````````````````````````


To see why, note that in

```markdown
> foo
>     - bar
```

the `- bar` is indented too far to start a list, and can't
be an indented code block because indented code blocks cannot
interrupt paragraphs, so it is paragraph continuation text.

A block quote can be empty:

```````````````````````````````` example
>
.
<blockquote>
</blockquote>
````````````````````````````````


```````````````````````````````` example
>
>  
> 
.
<blockquote>
</blockquote>
````````````````````````````````


A block quote can have initial or final blank lines:

```````````````````````````````` example
>
> foo
>  
.
<blockquote>
<p>foo</p>
</blockquote>
````````````````````````````````


A blank line always separates block quotes:

```````````````````````````````` example
> foo

> bar
.
<blockquote>
<p>foo</p>
</blockquote>
<blockquote>
<p>bar</p>
</blockquote>
````````````````````````````````


(Most current Markdown implementations, including John Gruber's
original `Markdown.pl`, will parse this example as a single block quote
with two paragraphs. But it seems better to allow the author to decide
whether two block quotes or one are wanted.)

Consecutiveness means that if we put these block quotes together,
we get a single block quote:

```````````````````````````````` example
> foo
> bar
.
<blockquote>
<p>foo
bar</p>
</blockquote>
````````````````````````````````


To get a block quote with two paragraphs, use:

```````````````````````````````` example
> foo
>
> bar
.
<blockquote>
<p>foo</p>
<p>bar</p>
</blockquote>
````````````````````````````````


Block quotes can interrupt paragraphs:

```````````````````````````````` example
foo
> bar
.
<p>foo</p>
<blockquote>
<p>bar</p>
</blockquote>
````````````````````````````````


In general, blank lines are not needed before or after block
quotes:

```````````````````````````````` example
> aaa
***
> bbb
.
<blockquote>
<p>aaa</p>
</blockquote>
<hr>
<blockquote>
<p>bbb</p>
</blockquote>
````````````````````````````````


However, because of laziness, a blank line is needed between
a block quote and a following paragraph:

```````````````````````````````` example
> bar
baz
.
<blockquote>
<p>bar
baz</p>
</blockquote>
````````````````````````````````


```````````````````````````````` example
> bar

baz
.
<blockquote>
<p>bar</p>
</blockquote>
<p>baz</p>
````````````````````````````````


```````````````````````````````` example
> bar
>
baz
.
<blockquote>
<p>bar</p>
</blockquote>
<p>baz</p>
````````````````````````````````


It is a consequence of the Laziness rule that any number
of initial `>`s may be omitted on a continuation line of a
nested block quote:

```````````````````````````````` example
> > > foo
bar
.
<blockquote>
<blockquote>
<blockquote>
<p>foo
bar</p>
</blockquote>
</blockquote>
</blockquote>
````````````````````````````````


```````````````````````````````` example
>>> foo
> bar
>>baz
.
<blockquote>
<blockquote>
<blockquote>
<p>foo
bar
baz</p>
</blockquote>
</blockquote>
</blockquote>
````````````````````````````````


When including an indented code block in a block quote,
remember that the block quote marker includes
both the `>` and a following space. So *five spaces* are needed after
the `>`:

```````````````````````````````` example
>     code

>    not code
.
<blockquote>
<pre><code>code
</code></pre>
</blockquote>
<blockquote>
<p>not code</p>
</blockquote>
````````````````````````````````



## List items

A **list marker** is a
bullet list marker or an ordered list marker.

A **bullet list marker**
is a `-`, `+`, or `*` character.

An **ordered list marker**
is a sequence of 1--9 arabic digits (`0-9`), followed by either a
`.` character or a `)` character. (The reason for the length
limit is that with 10 digits we start seeing integer overflows
in some browsers.)

The following rules define list items:

1.  **Basic case.**  If a sequence of lines *Ls* constitute a sequence of
    blocks *Bs* starting with a non-whitespace character and not separated
    from each other by more than one blank line, and *M* is a list
    marker of width *W* followed by 1 ≤ *N* ≤ 4 spaces, then the result
    of prepending *M* and the following spaces to the first line of
    *Ls*, and indenting subsequent lines of *Ls* by *W + N* spaces, is a
    list item with *Bs* as its contents. The type of the list item
    (bullet or ordered) is determined by the type of its list marker.
    If the list item is ordered, then it is also assigned a start
    number, based on the ordered list marker.

    Exceptions: When the first list item in a list interrupts
    a paragraph---that is, when it starts on a line that would
    otherwise count as paragraph continuation text---then (a)
    the lines *Ls* must not begin with a blank line, and (b) if
    the list item is ordered, the start number must be 1.

For example, let *Ls* be the lines

```````````````````````````````` example
A paragraph
with two lines.

    indented code

> A block quote.
.
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
````````````````````````````````


And let *M* be the marker `1.`, and *N* = 2. Then rule #1 says
that the following is an ordered list item with start number 1,
and the same contents as *Ls*:

```````````````````````````````` example
1.  A paragraph
    with two lines.

        indented code

    > A block quote.
.
<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
````````````````````````````````


The most important thing to notice is that the position of
the text after the list marker determines how much indentation
is needed in subsequent blocks in the list item. If the list
marker takes up two spaces, and there are three spaces between
the list marker and the next non-whitespace character, then blocks
must be indented five spaces in order to fall under the list
item.

Here are some examples showing how far content must be indented to be
put under the list item:

```````````````````````````````` example
- one

 two
.
<ul>
<li>one</li>
</ul>
<p>two</p>
````````````````````````````````


```````````````````````````````` example
- one

  two
.
<ul>
<li>
<p>one</p>
<p>two</p>
</li>
</ul>
````````````````````````````````


```````````````````````````````` example
 -    one

     two
.
<ul>
<li>one</li>
</ul>
<pre><code> two
</code></pre>
````````````````````````````````


```````````````````````````````` example
 -    one

      two
.
<ul>
<li>
<p>one</p>
<p>two</p>
</li>
</ul>
````````````````````````````````


It is tempting to think of this in terms of columns:  the continuation
blocks must be indented at least to the column of the first
non-whitespace character after the list marker. However, that is not quite right.
The spaces after the list marker determine how much relative indentation
is needed. Which column this indentation reaches will depend on
how the list item is embedded in other constructions, as shown by
this example:

```````````````````````````````` example
> > 1.  one
>>
>>     two
.
<blockquote>
<blockquote>
<ol>
<li>
<p>one</p>
<p>two</p>
</li>
</ol>
</blockquote>
</blockquote>
````````````````````````````````


Here `two` occurs in the same column as the list marker `1.`,
but is actually contained in the list item, because there is
sufficient indentation after the last containing blockquote marker.

The converse is also possible. In the following example, the word `two`
occurs far to the right of the initial text of the list item, `one`, but
it is not considered part of the list item, because it is not indented
far enough past the blockquote marker:

```````````````````````````````` example
>>- one
>>
> > two
.
<blockquote>
<blockquote>
<ul>
<li>one</li>
</ul>
<p>two</p>
</blockquote>
</blockquote>
````````````````````````````````


Note that at least one space is needed between the list marker and
any following content, so these are not list items:

```````````````````````````````` example
-one

2.two
.
<p>-one</p>
<p>2.two</p>
````````````````````````````````


A list item may contain blocks that are separated by more than
one blank line.

```````````````````````````````` example
- foo


  bar
.
<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
````````````````````````````````


A list item may contain any kind of block:

```````````````````````````````` example
1.  foo

    ```
    bar
    ```

    baz

    > bam
.
<ol>
<li>
<p>foo</p>
<pre><code>bar
</code></pre>
<p>baz</p>
<blockquote>
<p>bam</p>
</blockquote>
</li>
</ol>
````````````````````````````````


A list item that contains an indented code block will preserve
empty lines within the code block verbatim.

```````````````````````````````` example
- Foo

      bar


      baz
.
<ul>
<li>
<p>Foo</p>
<pre><code>bar


baz
</code></pre>
</li>
</ul>
````````````````````````````````

Note that ordered list start numbers must be nine digits or less:

```````````````````````````````` example
123456789. ok
.
<ol start="123456789">
<li>ok</li>
</ol>
````````````````````````````````


```````````````````````````````` example
1234567890. not ok
.
<p>1234567890. not ok</p>
````````````````````````````````


A start number may begin with 0s:

```````````````````````````````` example
0. ok
.
<ol start="0">
<li>ok</li>
</ol>
````````````````````````````````


```````````````````````````````` example
003. ok
.
<ol start="3">
<li>ok</li>
</ol>
````````````````````````````````


A start number may not be negative:

```````````````````````````````` example
-1. not ok
.
<p>-1. not ok</p>
````````````````````````````````



2.  **Item starting with indented code.**  If a sequence of lines *Ls*
    constitute a sequence of blocks *Bs* starting with an indented code
    block and not separated from each other by more than one blank line,
    and *M* is a list marker of width *W* followed by
    one space, then the result of prepending *M* and the following
    space to the first line of *Ls*, and indenting subsequent lines of
    *Ls* by *W + 1* spaces, is a list item with *Bs* as its contents.
    If a line is empty, then it need not be indented. The type of the
    list item (bullet or ordered) is determined by the type of its list
    marker. If the list item is ordered, then it is also assigned a
    start number, based on the ordered list marker.

An indented code block will have to be indented four spaces beyond
the edge of the region where text will be included in the list item.
In the following case that is 6 spaces:

```````````````````````````````` example
- foo

      bar
.
<ul>
<li>
<p>foo</p>
<pre><code>bar
</code></pre>
</li>
</ul>
````````````````````````````````


And in this case it is 11 spaces:

```````````````````````````````` example
  10.  foo

           bar
.
<ol start="10">
<li>
<p>foo</p>
<pre><code>bar
</code></pre>
</li>
</ol>
````````````````````````````````


If the *first* block in the list item is an indented code block,
then by rule #2, the contents must be indented *one* space after the
list marker:

```````````````````````````````` example
    indented code

paragraph

    more code
.
<pre><code>indented code
</code></pre>
<p>paragraph</p>
<pre><code>more code
</code></pre>
````````````````````````````````


```````````````````````````````` example
1.     indented code

   paragraph

       more code
.
<ol>
<li>
<pre><code>indented code
</code></pre>
<p>paragraph</p>
<pre><code>more code
</code></pre>
</li>
</ol>
````````````````````````````````


Note that an additional space indent is interpreted as space
inside the code block:

```````````````````````````````` example
1.      indented code

   paragraph

       more code
.
<ol>
<li>
<pre><code> indented code
</code></pre>
<p>paragraph</p>
<pre><code>more code
</code></pre>
</li>
</ol>
````````````````````````````````


Note that rules #1 and #2 only apply to two cases:  (a) cases
in which the lines to be included in a list item begin with a
non-whitespace character, and (b) cases in which
they begin with an indented code
block. In a case like the following, where the first block begins with
a three-space indent, the rules do not allow us to form a list item by
indenting the whole thing and prepending a list marker:

```````````````````````````````` example
   foo

bar
.
<p>foo</p>
<p>bar</p>
````````````````````````````````


```````````````````````````````` example
-    foo

  bar
.
<ul>
<li>foo</li>
</ul>
<p>bar</p>
````````````````````````````````


This is not a significant restriction, because when a block begins
with 1-3 spaces indent, the indentation can always be removed without
a change in interpretation, allowing rule #1 to be applied. So, in
the above case:

```````````````````````````````` example
-  foo

   bar
.
<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
````````````````````````````````


3.  **Item starting with a blank line.**  If a sequence of lines *Ls*
    starting with a single blank line constitute a (possibly empty)
    sequence of blocks *Bs*, not separated from each other by more than
    one blank line, and *M* is a list marker of width *W*,
    then the result of prepending *M* to the first line of *Ls*, and
    indenting subsequent lines of *Ls* by *W + 1* spaces, is a list
    item with *Bs* as its contents.
    If a line is empty, then it need not be indented. The type of the
    list item (bullet or ordered) is determined by the type of its list
    marker. If the list item is ordered, then it is also assigned a
    start number, based on the ordered list marker.

Here are some list items that start with a blank line but are not empty:

```````````````````````````````` example
-
  foo
-
  ```
  bar
  ```
-
      baz
.
<ul>
<li>foo</li>
<li>
<pre><code>bar
</code></pre>
</li>
<li>
<pre><code>baz
</code></pre>
</li>
</ul>
````````````````````````````````

When the list item starts with a blank line, the number of spaces
following the list marker doesn't change the required indentation:

```````````````````````````````` example
-   
  foo
.
<ul>
<li>foo</li>
</ul>
````````````````````````````````


A list item can begin with at most one blank line.
In the following example, `foo` is not part of the list
item:

```````````````````````````````` example
-

  foo
.
<ul>
<li></li>
</ul>
<p>foo</p>
````````````````````````````````


Here is an empty bullet list item:

```````````````````````````````` example
- foo
-
- bar
.
<ul>
<li>foo</li>
<li></li>
<li>bar</li>
</ul>
````````````````````````````````


It does not matter whether there are spaces following the list marker:

```````````````````````````````` example
- foo
-   
- bar
.
<ul>
<li>foo</li>
<li></li>
<li>bar</li>
</ul>
````````````````````````````````


Here is an empty ordered list item:

```````````````````````````````` example
1. foo
2.
3. bar
.
<ol>
<li>foo</li>
<li></li>
<li>bar</li>
</ol>
````````````````````````````````


A list may start or end with an empty list item:

```````````````````````````````` example
*
.
<ul>
<li></li>
</ul>
````````````````````````````````

However, an empty list item cannot interrupt a paragraph:

```````````````````````````````` example
foo
*

foo
1.
.
<p>foo
*</p>
<p>foo
1.</p>
````````````````````````````````


4.  **Indentation.**  If a sequence of lines *Ls* constitutes a list item
    according to rule #1, #2, or #3, then the result of indenting each line
    of *Ls* by 1-3 spaces (the same for each line) also constitutes a
    list item with the same contents and attributes. If a line is
    empty, then it need not be indented.

Indented one space:

```````````````````````````````` example
 1.  A paragraph
     with two lines.

         indented code

     > A block quote.
.
<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
````````````````````````````````


Indented two spaces:

```````````````````````````````` example
  1.  A paragraph
      with two lines.

          indented code

      > A block quote.
.
<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
````````````````````````````````


Indented three spaces:

```````````````````````````````` example
   1.  A paragraph
       with two lines.

           indented code

       > A block quote.
.
<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
````````````````````````````````


Four spaces indent gives a code block:

```````````````````````````````` example
    1.  A paragraph
        with two lines.

            indented code

        > A block quote.
.
<pre><code>1.  A paragraph
    with two lines.

        indented code

    &gt; A block quote.
</code></pre>
````````````````````````````````



5.  **Laziness.**  If a string of lines *Ls* constitute a [list
    item](#list-items) with contents *Bs*, then the result of deleting
    some or all of the indentation from one or more lines in which the
    next non-whitespace character after the indentation is
    paragraph continuation text is a
    list item with the same contents and attributes. The unindented
    lines are called
    **lazy continuation line**s.

Here is an example with lazy continuation lines:

```````````````````````````````` example
  1.  A paragraph
with two lines.

          indented code

      > A block quote.
.
<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
````````````````````````````````


Indentation can be partially deleted:

```````````````````````````````` example
  1.  A paragraph
    with two lines.
.
<ol>
<li>A paragraph
with two lines.</li>
</ol>
````````````````````````````````


These examples show how laziness can work in nested structures:

```````````````````````````````` example
> 1. > Blockquote
continued here.
.
<blockquote>
<ol>
<li>
<blockquote>
<p>Blockquote
continued here.</p>
</blockquote>
</li>
</ol>
</blockquote>
````````````````````````````````


```````````````````````````````` example
> 1. > Blockquote
> continued here.
.
<blockquote>
<ol>
<li>
<blockquote>
<p>Blockquote
continued here.</p>
</blockquote>
</li>
</ol>
</blockquote>
````````````````````````````````



6.  **That's all.** Nothing that is not counted as a list item by rules
    #1--5 counts as a list item.

The rules for sublists follow from the general rules above. A sublist
must be indented the same number of spaces a paragraph would need to be
in order to be included in the list item.

So, in this case we need two spaces indent:

```````````````````````````````` example
- foo
  - bar
    - baz
      - boo
.
<ul>
<li>foo
<ul>
<li>bar
<ul>
<li>baz
<ul>
<li>boo</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
````````````````````````````````


One is not enough:

```````````````````````````````` example
- foo
 - bar
  - baz
   - boo
.
<ul>
<li>foo</li>
<li>bar</li>
<li>baz</li>
<li>boo</li>
</ul>
````````````````````````````````


Here we need four, because the list marker is wider:

```````````````````````````````` example
10) foo
    - bar
.
<ol start="10">
<li>foo
<ul>
<li>bar</li>
</ul>
</li>
</ol>
````````````````````````````````


Three is not enough:

```````````````````````````````` example
10) foo
   - bar
.
<ol start="10">
<li>foo</li>
</ol>
<ul>
<li>bar</li>
</ul>
````````````````````````````````


A list may be the first block in a list item:

```````````````````````````````` example
- - foo
.
<ul>
<li>
<ul>
<li>foo</li>
</ul>
</li>
</ul>
````````````````````````````````


```````````````````````````````` example
1. - 2. foo
.
<ol>
<li>
<ul>
<li>
<ol start="2">
<li>foo</li>
</ol>
</li>
</ul>
</li>
</ol>
````````````````````````````````


A list item can contain a heading:

```````````````````````````````` example
- # Foo

    Bar
.
<ul>
<li>
<h1>Foo</h1>
<p>Bar</p>
</li>
</ul>
````````````````````````````````


### Motivation

John Gruber's Markdown spec says the following about list items:

1. "List markers typically start at the left margin, but may be indented
   by up to three spaces. List markers must be followed by one or more
   spaces or a tab."

2. "To make lists look nice, you can wrap items with hanging indents....
   But if you don't want to, you don't have to."

3. "List items may consist of multiple paragraphs. Each subsequent
   paragraph in a list item must be indented by either 4 spaces or one
   tab."

4. "It looks nice if you indent every line of the subsequent paragraphs,
   but here again, Markdown will allow you to be lazy."

5. "To put a blockquote within a list item, the blockquote's `>`
   delimiters need to be indented."

6. "To put a code block within a list item, the code block needs to be
   indented twice — 8 spaces or two tabs."

These rules specify that a paragraph under a list item must be indented
four spaces (presumably, from the left margin, rather than the start of
the list marker, but this is not said), and that code under a list item
must be indented eight spaces instead of the usual four. They also say
that a block quote must be indented, but not by how much; however, the
example given has four spaces indentation. Although nothing is said
about other kinds of block-level content, it is certainly reasonable to
infer that *all* block elements under a list item, including other
lists, must be indented four spaces. This principle has been called the
*four-space rule*.

The four-space rule is clear and principled, and if the reference
implementation `Markdown.pl` had followed it, it probably would have
become the standard. However, `Markdown.pl` allowed paragraphs and
sublists to start with only two spaces indentation, at least on the
outer level. Worse, its behavior was inconsistent: a sublist of an
outer-level list needed two spaces indentation, but a sublist of this
sublist needed three spaces. It is not surprising, then, that different
implementations of Markdown have developed very different rules for
determining what comes under a list item. (Pandoc and python-Markdown,
for example, stuck with Gruber's syntax description and the four-space
rule, while discount, redcarpet, marked, PHP Markdown, and others
followed `Markdown.pl`'s behavior more closely.)

Unfortunately, given the divergences between implementations, there
is no way to give a spec for list items that will be guaranteed not
to break any existing documents. However, the spec given here should
correctly handle lists formatted with either the four-space rule or
the more forgiving `Markdown.pl` behavior, provided they are laid out
in a way that is natural for a human to read.

The strategy here is to let the width and indentation of the list marker
determine the indentation necessary for blocks to fall under the list
item, rather than having a fixed and arbitrary number. The writer can
think of the body of the list item as a unit which gets indented to the
right enough to fit the list marker (and any indentation on the list
marker). (The laziness rule, #5, then allows continuation lines to be
unindented if needed.)

This rule is superior, we claim, to any rule requiring a fixed level of
indentation from the margin. The four-space rule is clear but
unnatural. It is quite unintuitive that

``` markdown
- foo

  bar

  - baz
```

should be parsed as two lists with an intervening paragraph,

``` html
<ul>
<li>foo</li>
</ul>
<p>bar</p>
<ul>
<li>baz</li>
</ul>
```

as the four-space rule demands, rather than a single list,

``` html
<ul>
<li>
<p>foo</p>
<p>bar</p>
<ul>
<li>baz</li>
</ul>
</li>
</ul>
```

The choice of four spaces is arbitrary. It can be learned, but it is
not likely to be guessed, and it trips up beginners regularly.

Would it help to adopt a two-space rule?  The problem is that such
a rule, together with the rule allowing 1--3 spaces indentation of the
initial list marker, allows text that is indented *less than* the
original list marker to be included in the list item. For example,
`Markdown.pl` parses

``` markdown
   - one

  two
```

as a single list item, with `two` a continuation paragraph:

``` html
<ul>
<li>
<p>one</p>
<p>two</p>
</li>
</ul>
```

and similarly

``` markdown
>   - one
>
>  two
```

as

``` html
<blockquote>
<ul>
<li>
<p>one</p>
<p>two</p>
</li>
</ul>
</blockquote>
```

This is extremely unintuitive.

Rather than requiring a fixed indent from the margin, we could require
a fixed indent (say, two spaces, or even one space) from the list marker (which
may itself be indented). This proposal would remove the last anomaly
discussed. Unlike the spec presented above, it would count the following
as a list item with a subparagraph, even though the paragraph `bar`
is not indented as far as the first paragraph `foo`:

``` markdown
 10. foo

   bar  
```

Arguably this text does read like a list item with `bar` as a subparagraph,
which may count in favor of the proposal. However, on this proposal indented
code would have to be indented six spaces after the list marker. And this
would break a lot of existing Markdown, which has the pattern:

``` markdown
1.  foo

        indented code
```

where the code is indented eight spaces. The spec above, by contrast, will
parse this text as expected, since the code block's indentation is measured
from the beginning of `foo`.

The one case that needs special treatment is a list item that *starts*
with indented code. How much indentation is required in that case, since
we don't have a "first paragraph" to measure from?  Rule #2 simply stipulates
that in such cases, we require one space indentation from the list marker
(and then the normal four spaces for the indented code). This will match the
four-space rule in cases where the list marker plus its initial indentation
takes four spaces (a common case), but diverge in other cases.

## Lists

A **list** is a sequence of one or more
list items of the same type. The list items
may be separated by any number of blank lines.

Two list items are **of the same type**
if they begin with a list marker of the same type.
Two list markers are of the
same type if (a) they are bullet list markers using the same character
(`-`, `+`, or `*`) or (b) they are ordered list numbers with the same
delimiter (either `.` or `)`).

A list is an **ordered list**
if its constituent list items begin with
ordered list markers, and a
**bullet list** if its constituent list
items begin with bullet list markers.

The **start number**
of an ordered list is determined by the list number of
its initial list item. The numbers of subsequent list items are
disregarded.

A list is **loose** if any of its constituent
list items are separated by blank lines, or if any of its constituent
list items directly contain two block-level elements with a blank line
between them. Otherwise a list is **tight**.
(The difference in HTML output is that paragraphs in a loose list are
wrapped in `<p>` tags, while paragraphs in a tight list are not.)

Changing the bullet or ordered list delimiter starts a new list:

```````````````````````````````` example
- foo
- bar
+ baz
.
<ul>
<li>foo</li>
<li>bar</li>
</ul>
<ul>
<li>baz</li>
</ul>
````````````````````````````````


```````````````````````````````` example
1. foo
2. bar
3) baz
.
<ol>
<li>foo</li>
<li>bar</li>
</ol>
<ol start="3">
<li>baz</li>
</ol>
````````````````````````````````


In Sanemark, a list can interrupt a paragraph. That is,
no blank line is needed to separate a paragraph from a following
list:

```````````````````````````````` example
Foo
- bar
- baz
.
<p>Foo</p>
<ul>
<li>bar</li>
<li>baz</li>
</ul>
````````````````````````````````

`Markdown.pl` does not allow this, through fear of triggering a list
via a numeral in a hard-wrapped line:

``` markdown
The number of windows in my house is
14.  The number of doors is 6.
```

Oddly, though, `Markdown.pl` *does* allow a blockquote to
interrupt a paragraph, even though the same considerations might
apply.

In Sanemark, we do allow lists to interrupt paragraphs, for
two reasons. First, it is natural and not uncommon for people
to start lists without blank lines:

``` markdown
I need to buy
- new shoes
- a coat
- a plane ticket
```

Second, we are attracted to a

> **principle of uniformity**:
> if a chunk of text has a certain
> meaning, it will continue to have the same meaning when put into a
> container block (such as a list item or blockquote).

(Indeed, the spec for list items and block quotes presupposes
this principle.) This principle implies that if

``` markdown
  * I need to buy
    - new shoes
    - a coat
    - a plane ticket
```

is a list item containing a paragraph followed by a nested sublist,
as all Markdown implementations agree it is (though the paragraph
may be rendered without `<p>` tags, since the list is "tight"),
then

``` markdown
I need to buy
- new shoes
- a coat
- a plane ticket
```

by itself should be a paragraph followed by a nested sublist.

Since it is well established Markdown practice to allow lists to
interrupt paragraphs inside list items, the [principle of
uniformity] requires us to allow this outside list items as
well. ([reStructuredText](http://docutils.sourceforge.net/rst.html)
takes a different approach, requiring blank lines before lists
even inside other list items.)

In order to solve of unwanted lists in paragraphs with
hard-wrapped numerals, we allow only lists starting with `1` to
interrupt paragraphs. Thus,

```````````````````````````````` example
The number of windows in my house is
14.  The number of doors is 6.
.
<p>The number of windows in my house is
14.  The number of doors is 6.</p>
````````````````````````````````

We may still get an unintended result in cases like

```````````````````````````````` example
The number of windows in my house is
1.  The number of doors is 6.
.
<p>The number of windows in my house is</p>
<ol>
<li>The number of doors is 6.</li>
</ol>
````````````````````````````````

but this rule should prevent most spurious list captures.

There can be any number of blank lines between items:

```````````````````````````````` example
- foo

- bar


- baz
.
<ul>
<li>
<p>foo</p>
</li>
<li>
<p>bar</p>
</li>
<li>
<p>baz</p>
</li>
</ul>
````````````````````````````````

```````````````````````````````` example
- foo
  - bar
    - baz


      bim
.
<ul>
<li>foo
<ul>
<li>bar
<ul>
<li>
<p>baz</p>
<p>bim</p>
</li>
</ul>
</li>
</ul>
</li>
</ul>
````````````````````````````````


To separate consecutive lists of the same type, or to separate a
list from an indented code block that would otherwise be parsed
as a subparagraph of the final list item, you can insert a blank HTML
comment:

```````````````````````````````` example
- foo
- bar

<!-- -->

- baz
- bim
.
<ul>
<li>foo</li>
<li>bar</li>
</ul>
<!-- -->
<ul>
<li>baz</li>
<li>bim</li>
</ul>
````````````````````````````````


```````````````````````````````` example
-   foo

    notcode

-   foo

<!-- -->

    code
.
<ul>
<li>
<p>foo</p>
<p>notcode</p>
</li>
<li>
<p>foo</p>
</li>
</ul>
<!-- -->
<pre><code>code
</code></pre>
````````````````````````````````


List items need not be indented to the same level. The following
list items will be treated as items at the same list level,
since none is indented enough to belong to the previous list
item:

```````````````````````````````` example
- a
 - b
  - c
   - d
    - e
   - f
  - g
 - h
- i
.
<ul>
<li>a</li>
<li>b</li>
<li>c</li>
<li>d</li>
<li>e</li>
<li>f</li>
<li>g</li>
<li>h</li>
<li>i</li>
</ul>
````````````````````````````````


```````````````````````````````` example
1. a

  2. b

    3. c
.
<ol>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
</li>
<li>
<p>c</p>
</li>
</ol>
````````````````````````````````


This is a loose list, because there is a blank line between
two of the list items:

```````````````````````````````` example
- a
- b

- c
.
<ul>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
</li>
<li>
<p>c</p>
</li>
</ul>
````````````````````````````````


So is this, with a empty second item:

```````````````````````````````` example
* a
*

* c
.
<ul>
<li>
<p>a</p>
</li>
<li></li>
<li>
<p>c</p>
</li>
</ul>
````````````````````````````````


These are loose lists, even though there is no space between the items,
because one of the items directly contains two block-level elements
with a blank line between them:

```````````````````````````````` example
- a
- b

  c
- d
.
<ul>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
<p>c</p>
</li>
<li>
<p>d</p>
</li>
</ul>
````````````````````````````````


```````````````````````````````` example
- a
- b

  [ref]: /url
- d
.
<ul>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
</li>
<li>
<p>d</p>
</li>
</ul>
````````````````````````````````


This is a tight list, because the blank lines are in a code block:

```````````````````````````````` example
- a
- ```
  b


  ```
- c
.
<ul>
<li>a</li>
<li>
<pre><code>b


</code></pre>
</li>
<li>c</li>
</ul>
````````````````````````````````


This is a tight list, because the blank line is between two
paragraphs of a sublist. So the sublist is loose while
the outer list is tight:

```````````````````````````````` example
- a
  - b

    c
- d
.
<ul>
<li>a
<ul>
<li>
<p>b</p>
<p>c</p>
</li>
</ul>
</li>
<li>d</li>
</ul>
````````````````````````````````


This is a tight list, because the blank line is inside the
block quote:

```````````````````````````````` example
* a
  > b
  >
* c
.
<ul>
<li>a
<blockquote>
<p>b</p>
</blockquote>
</li>
<li>c</li>
</ul>
````````````````````````````````


This list is tight, because the consecutive block elements
are not separated by blank lines:

```````````````````````````````` example
- a
  > b
  ```
  c
  ```
- d
.
<ul>
<li>a
<blockquote>
<p>b</p>
</blockquote>
<pre><code>c
</code></pre>
</li>
<li>d</li>
</ul>
````````````````````````````````


A single-paragraph list is tight:

```````````````````````````````` example
- a
.
<ul>
<li>a</li>
</ul>
````````````````````````````````


```````````````````````````````` example
- a
  - b
.
<ul>
<li>a
<ul>
<li>b</li>
</ul>
</li>
</ul>
````````````````````````````````


This list is loose, because of the blank line between the
two block elements in the list item:

```````````````````````````````` example
1. ```
   foo
   ```

   bar
.
<ol>
<li>
<pre><code>foo
</code></pre>
<p>bar</p>
</li>
</ol>
````````````````````````````````


Here the outer list is loose, the inner list tight:

```````````````````````````````` example
* foo
  * bar

  baz
.
<ul>
<li>
<p>foo</p>
<ul>
<li>bar</li>
</ul>
<p>baz</p>
</li>
</ul>
````````````````````````````````


```````````````````````````````` example
- a
  - b
  - c

- d
  - e
  - f
.
<ul>
<li>
<p>a</p>
<ul>
<li>b</li>
<li>c</li>
</ul>
</li>
<li>
<p>d</p>
<ul>
<li>e</li>
<li>f</li>
</ul>
</li>
</ul>
````````````````````````````````


# Inlines

Inlines are parsed sequentially from the beginning of the character
stream to the end (left to right, in left-to-right languages).
Thus, for example, in

```````````````````````````````` example
`hi`lo`
.
<p><code>hi</code>lo`</p>
````````````````````````````````


`hi` is parsed as code, leaving the backtick at the end as a literal
backtick.

## Backslash escapes

Any ASCII punctuation character may be backslash-escaped:

```````````````````````````````` example
\!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~
.
<p>!&quot;#$%&amp;'()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</p>
````````````````````````````````


Backslashes before other characters are treated as literal
backslashes:

```````````````````````````````` example
\→\A\a\ \3\φ\«
.
<p>\→\A\a\ \3\φ\«</p>
````````````````````````````````


Escaped characters are treated as regular characters and do
not have their usual Markdown meanings:

```````````````````````````````` example
\*not emphasized*
\<br/> not a tag
\[not a link](/foo)
\`not code`
1\. not a list
\* not a list
\# not a heading
.
<p>*not emphasized*
&lt;br/&gt; not a tag
[not a link](/foo)
`not code`
1. not a list
* not a list
# not a heading</p>
````````````````````````````````


If a backslash is itself escaped, the following character is not:

```````````````````````````````` example
\\*emphasis*
.
<p>\<em>emphasis</em></p>
````````````````````````````````

Backslash escapes do not work in code blocks or HTML:

```````````````````````````````` example
    \[\]
.
<pre><code>\[\]
</code></pre>
````````````````````````````````

```````````````````````````````` example
~~~
\[\]
~~~
.
<pre><code>\[\]
</code></pre>
````````````````````````````````

```````````````````````````````` example
<a href="/bar\/)">
.
<a href="/bar\/)">
````````````````````````````````

But they work in all other contexts, including URLs:

```````````````````````````````` example
[foo](/bar\*)
.
<p><a href="/bar*">foo</a></p>
````````````````````````````````

## Code spans

A **code span** begins and ends with an unescaped backtick (`\``).

This is a simple code span:

```````````````````````````````` example
`foo`
.
<p><code>foo</code></p>
````````````````````````````````

Whitespace is not tampered with:

```````````````````````````````` example
` foo  bar `
.
<p><code> foo  bar </code></p>
````````````````````````````````

For the sake of those who use hard wrapping, Line endings are treated like spaces:

```````````````````````````````` example
`
foo
`
.
<p><code> foo </code></p>
````````````````````````````````

Inside code spans, backslashes have no special meaning except before `\\` and `\``:

```````````````````````````````` example
`\*foo\*`
`\\`
`\``
.
<p><code>\*foo\*</code>
<code>\</code>
<code>`</code></p>
````````````````````````````````

Code spans cannot be empty; this causes both backticks to be taken literally:
```````````````````````````````` example
`` foo`
.
<p>`` foo`</p>
````````````````````````````````

Code span backticks have higher precedence than any other inline constructs except HTML tags. Thus, for example, this is not parsed as emphasized text, since the second `*` is part of a code span:

```````````````````````````````` example
*foo`*`
.
<p>*foo<code>*</code></p>
````````````````````````````````

And this is not parsed as a link:

```````````````````````````````` example
[not a `link](/foo`)
.
<p>[not a <code>link](/foo</code>)</p>
````````````````````````````````

Code spans and HTML tags have the same precedence. Thus, this is code:

```````````````````````````````` example
`<a href="`">`
.
<p><code>&lt;a href=&quot;</code>&quot;&gt;`</p>
````````````````````````````````

But this is an HTML tag:

```````````````````````````````` example
<a href="`">`
.
<p><a href="`">`</p>
````````````````````````````````

When a backtick is not closed, we just have a literal backtick:

```````````````````````````````` example
`foo
.
<p>`foo</p>
````````````````````````````````

## Emphasis and strong emphasis

John Gruber's original [Markdown syntax
description](http://daringfireball.net/projects/markdown/syntax#em) says:

> Markdown treats asterisks (`*`) and underscores (`_`) as indicators of
> emphasis. Text wrapped with one `*` or `_` will be wrapped with an HTML
> `<em>` tag; double `*`'s or `_`'s will be wrapped with an HTML `<strong>`
> tag.

This is enough for most users, but these rules leave much undecided,
especially when it comes to nested emphasis. The original
`Markdown.pl` test suite makes it clear that triple `***` and
`___` delimiters can be used for strong emphasis, and most
implementations have also allowed the following patterns:

``` markdown
***strong emph***
***strong** in emph*
***emph* in strong**
**in strong *emph***
*in emph **strong***
```

The following patterns are less widely supported, but the intent
is clear and they are useful (especially in contexts like bibliography
entries):

``` markdown
*emph *with emph* in it*
**strong **with strong** in it**
```

Many implementations have also restricted intraword emphasis to
the `*` forms, to avoid unwanted emphasis in words containing
internal underscores. (It is best practice to put these in code
spans, but users often do not.)

``` markdown
internal emphasis: foo*bar*baz
no emphasis: foo_bar_baz
```

The rules given below capture all of these patterns, while allowing
for efficient parsing strategies that do not backtrack.

First, some definitions. A **delimiter run** is either
a sequence of one or more `*` characters that is not preceded or
followed by a `*` character, or a sequence of one or more `_`
characters that is not preceded or followed by a `_` character.

A **left-flanking delimiter run** is
a delimiter run that is (a) not followed by Unicode whitespace,
and (b) either not followed by a punctuation character, or
preceded by Unicode whitespace or a punctuation character.
For purposes of this definition, the beginning and the end of
the line count as Unicode whitespace.

A **right-flanking delimiter run** is
a delimiter run that is (a) not preceded by Unicode whitespace,
and (b) either not preceded by a punctuation character, or
followed by Unicode whitespace or a punctuation character.
For purposes of this definition, the beginning and the end of
the line count as Unicode whitespace.

Here are some examples of delimiter runs.

  - left-flanking but not right-flanking:

    ```
    ***abc
      _abc
    **"abc"
     _"abc"
    ```

  - right-flanking but not left-flanking:

    ```
     abc***
     abc_
    "abc"**
    "abc"_
    ```

  - Both left and right-flanking:

    ```
     abc***def
    "abc"_"def"
    ```

  - Neither left nor right-flanking:

    ```
    abc *** def
    a _ b
    ```

(The idea of distinguishing left-flanking and right-flanking
delimiter runs based on the character before and the character
after comes from Roopesh Chander's
[vfmd](http://www.vfmd.org/vfmd-spec/specification/#procedure-for-identifying-emphasis-tags).
vfmd uses the terminology "emphasis indicator string" instead of "delimiter
run," and its rules for distinguishing left- and right-flanking runs
are a bit more complex than the ones given here.)

The following rules define emphasis and strong emphasis:

1.  A single `*` character **can open emphasis**
    iff (if and only if) it is part of a left-flanking delimiter run.

2.  A single `_` character can open emphasis iff
    it is part of a left-flanking delimiter run
    and either (a) not part of a right-flanking delimiter run
    or (b) part of a right-flanking delimiter run
    preceded by punctuation.

3.  A single `*` character **can close emphasis**
    iff it is part of a right-flanking delimiter run.

4.  A single `_` character can close emphasis iff
    it is part of a right-flanking delimiter run
    and either (a) not part of a left-flanking delimiter run
    or (b) part of a left-flanking delimiter run
    followed by punctuation.

5.  A double `**` **can open strong emphasis**
    iff it is part of a left-flanking delimiter run.

6.  A double `__` can open strong emphasis iff
    it is part of a left-flanking delimiter run
    and either (a) not part of a right-flanking delimiter run
    or (b) part of a right-flanking delimiter run
    preceded by punctuation.

7.  A double `**` **can close strong emphasis**
    iff it is part of a right-flanking delimiter run.

8.  A double `__` can close strong emphasis
    it is part of a right-flanking delimiter run
    and either (a) not part of a left-flanking delimiter run
    or (b) part of a left-flanking delimiter run
    followed by punctuation.

9.  Emphasis begins with a delimiter that can open emphasis and ends
    with a delimiter that can close emphasis, and that uses the same
    character (`_` or `*`) as the opening delimiter.  The
    opening and closing delimiters must belong to separate
    delimiter runs.  If one of the delimiters can both
    open and close emphasis, then the sum of the lengths of the
    delimiter runs containing the opening and closing delimiters
    must not be a multiple of 3.

10. Strong emphasis begins with a delimiter that
    can open strong emphasis and ends with a delimiter that
    can close strong emphasis, and that uses the same character
    (`_` or `*`) as the opening delimiter.  The
    opening and closing delimiters must belong to separate
    delimiter runs.  If one of the delimiters can both open
    and close strong emphasis, then the sum of the lengths of
    the delimiter runs containing the opening and closing
    delimiters must not be a multiple of 3.

11. A literal `*` character cannot occur at the beginning or end of
    `*`-delimited emphasis or `**`-delimited strong emphasis, unless it
    is backslash-escaped.

12. A literal `_` character cannot occur at the beginning or end of
    `_`-delimited emphasis or `__`-delimited strong emphasis, unless it
    is backslash-escaped.

Where rules 1--12 above are compatible with multiple parsings,
the following principles resolve ambiguity:

13. The number of nestings should be minimized. Thus, for example,
    an interpretation `<strong>...</strong>` is always preferred to
    `<em><em>...</em></em>`.

14. An interpretation `<em><strong>...</strong></em>` is always
    preferred to `<strong><em>..</em></strong>`.

15. When two potential emphasis or strong emphasis spans overlap,
    so that the second begins before the first ends and ends after
    the first ends, the first takes precedence. Thus, for example,
    `*foo _bar* baz_` is parsed as `<em>foo _bar</em> baz_` rather
    than `*foo <em>bar* baz</em>`.

16. When there are two potential emphasis or strong emphasis spans
    with the same closing delimiter, the shorter one (the one that
    opens later) takes precedence. Thus, for example,
    `**foo **bar baz**` is parsed as `**foo <strong>bar baz</strong>`
    rather than `<strong>foo **bar baz</strong>`.

17. Inline code spans, links, images, and HTML tags group more tightly
    than emphasis.  So, when there is a choice between an interpretation
    that contains one of these elements and one that does not, the
    former always wins.  Thus, for example, `*[foo*](bar)` is
    parsed as `*<a href="bar">foo*</a>` rather than as
    `<em>[foo</em>](bar)`.

These rules can be illustrated through a series of examples.

Rule 1:

```````````````````````````````` example
*foo bar*
.
<p><em>foo bar</em></p>
````````````````````````````````


This is not emphasis, because the opening `*` is followed by
whitespace, and hence not part of a left-flanking delimiter run:

```````````````````````````````` example
a * foo bar*
.
<p>a * foo bar*</p>
````````````````````````````````


This is not emphasis, because the opening `*` is preceded
by an alphanumeric and followed by punctuation, and hence
not part of a left-flanking delimiter run:

```````````````````````````````` example
a*"foo"*
.
<p>a*&quot;foo&quot;*</p>
````````````````````````````````


Unicode nonbreaking spaces count as whitespace, too:

```````````````````````````````` example
* a *
.
<p>* a *</p>
````````````````````````````````


Intraword emphasis with `*` is permitted:

```````````````````````````````` example
foo*bar*
.
<p>foo<em>bar</em></p>
````````````````````````````````


```````````````````````````````` example
5*6*78
.
<p>5<em>6</em>78</p>
````````````````````````````````


Rule 2:

```````````````````````````````` example
_foo bar_
.
<p><em>foo bar</em></p>
````````````````````````````````


This is not emphasis, because the opening `_` is followed by
whitespace:

```````````````````````````````` example
_ foo bar_
.
<p>_ foo bar_</p>
````````````````````````````````


This is not emphasis, because the opening `_` is preceded
by an alphanumeric and followed by punctuation:

```````````````````````````````` example
a_"foo"_
.
<p>a_&quot;foo&quot;_</p>
````````````````````````````````


Emphasis with `_` is not allowed inside words:

```````````````````````````````` example
foo_bar_
.
<p>foo_bar_</p>
````````````````````````````````


```````````````````````````````` example
5_6_78
.
<p>5_6_78</p>
````````````````````````````````


```````````````````````````````` example
пристаням_стремятся_
.
<p>пристаням_стремятся_</p>
````````````````````````````````


Here `_` does not generate emphasis, because the first delimiter run
is right-flanking and the second left-flanking:

```````````````````````````````` example
aa_"bb"_cc
.
<p>aa_&quot;bb&quot;_cc</p>
````````````````````````````````


This is emphasis, even though the opening delimiter is
both left- and right-flanking, because it is preceded by
punctuation:

```````````````````````````````` example
foo-_(bar)_
.
<p>foo-<em>(bar)</em></p>
````````````````````````````````


Rule 3:

This is not emphasis, because the closing delimiter does
not match the opening delimiter:

```````````````````````````````` example
_foo*
.
<p>_foo*</p>
````````````````````````````````


This is not emphasis, because the closing `*` is preceded by
whitespace:

```````````````````````````````` example
*foo bar *
.
<p>*foo bar *</p>
````````````````````````````````


A newline also counts as whitespace:

```````````````````````````````` example
*foo bar
*
.
<p>*foo bar
*</p>
````````````````````````````````


This is not emphasis, because the second `*` is
preceded by punctuation and followed by an alphanumeric
(hence it is not part of a right-flanking delimiter run:

```````````````````````````````` example
*(*foo)
.
<p>*(*foo)</p>
````````````````````````````````


The point of this restriction is more easily appreciated
with this example:

```````````````````````````````` example
*(*foo*)*
.
<p><em>(<em>foo</em>)</em></p>
````````````````````````````````


Intraword emphasis with `*` is allowed:

```````````````````````````````` example
*foo*bar
.
<p><em>foo</em>bar</p>
````````````````````````````````



Rule 4:

This is not emphasis, because the closing `_` is preceded by
whitespace:

```````````````````````````````` example
_foo bar _
.
<p>_foo bar _</p>
````````````````````````````````


This is not emphasis, because the second `_` is
preceded by punctuation and followed by an alphanumeric:

```````````````````````````````` example
_(_foo)
.
<p>_(_foo)</p>
````````````````````````````````


This is emphasis within emphasis:

```````````````````````````````` example
_(_foo_)_
.
<p><em>(<em>foo</em>)</em></p>
````````````````````````````````


Intraword emphasis is disallowed for `_`:

```````````````````````````````` example
_foo_bar
.
<p>_foo_bar</p>
````````````````````````````````


```````````````````````````````` example
_пристаням_стремятся
.
<p>_пристаням_стремятся</p>
````````````````````````````````


```````````````````````````````` example
_foo_bar_baz_
.
<p><em>foo_bar_baz</em></p>
````````````````````````````````


This is emphasis, even though the closing delimiter is
both left- and right-flanking, because it is followed by
punctuation:

```````````````````````````````` example
_(bar)_.
.
<p><em>(bar)</em>.</p>
````````````````````````````````


Rule 5:

```````````````````````````````` example
**foo bar**
.
<p><strong>foo bar</strong></p>
````````````````````````````````


This is not strong emphasis, because the opening delimiter is
followed by whitespace:

```````````````````````````````` example
** foo bar**
.
<p>** foo bar**</p>
````````````````````````````````


This is not strong emphasis, because the opening `**` is preceded
by an alphanumeric and followed by punctuation, and hence
not part of a left-flanking delimiter run:

```````````````````````````````` example
a**"foo"**
.
<p>a**&quot;foo&quot;**</p>
````````````````````````````````


Intraword strong emphasis with `**` is permitted:

```````````````````````````````` example
foo**bar**
.
<p>foo<strong>bar</strong></p>
````````````````````````````````


Rule 6:

```````````````````````````````` example
__foo bar__
.
<p><strong>foo bar</strong></p>
````````````````````````````````


This is not strong emphasis, because the opening delimiter is
followed by whitespace:

```````````````````````````````` example
__ foo bar__
.
<p>__ foo bar__</p>
````````````````````````````````


A newline counts as whitespace:
```````````````````````````````` example
__
foo bar__
.
<p>__
foo bar__</p>
````````````````````````````````


This is not strong emphasis, because the opening `__` is preceded
by an alphanumeric and followed by punctuation:

```````````````````````````````` example
a__"foo"__
.
<p>a__&quot;foo&quot;__</p>
````````````````````````````````


Intraword strong emphasis is forbidden with `__`:

```````````````````````````````` example
foo__bar__
.
<p>foo__bar__</p>
````````````````````````````````


```````````````````````````````` example
5__6__78
.
<p>5__6__78</p>
````````````````````````````````


```````````````````````````````` example
пристаням__стремятся__
.
<p>пристаням__стремятся__</p>
````````````````````````````````


```````````````````````````````` example
__foo, __bar__, baz__
.
<p><strong>foo, <strong>bar</strong>, baz</strong></p>
````````````````````````````````


This is strong emphasis, even though the opening delimiter is
both left- and right-flanking, because it is preceded by
punctuation:

```````````````````````````````` example
foo-__(bar)__
.
<p>foo-<strong>(bar)</strong></p>
````````````````````````````````



Rule 7:

This is not strong emphasis, because the closing delimiter is preceded
by whitespace:

```````````````````````````````` example
**foo bar **
.
<p>**foo bar **</p>
````````````````````````````````


(Nor can it be interpreted as an emphasized `*foo bar *`, because of
Rule 11.)

This is not strong emphasis, because the second `**` is
preceded by punctuation and followed by an alphanumeric:

```````````````````````````````` example
**(**foo)
.
<p>**(**foo)</p>
````````````````````````````````


The point of this restriction is more easily appreciated
with these examples:

```````````````````````````````` example
*(**foo**)*
.
<p><em>(<strong>foo</strong>)</em></p>
````````````````````````````````


```````````````````````````````` example
**Gomphocarpus (*Gomphocarpus physocarpus*, syn.
*Asclepias physocarpa*)**
.
<p><strong>Gomphocarpus (<em>Gomphocarpus physocarpus</em>, syn.
<em>Asclepias physocarpa</em>)</strong></p>
````````````````````````````````


```````````````````````````````` example
**foo "*bar*" foo**
.
<p><strong>foo &quot;<em>bar</em>&quot; foo</strong></p>
````````````````````````````````


Intraword emphasis:

```````````````````````````````` example
**foo**bar
.
<p><strong>foo</strong>bar</p>
````````````````````````````````


Rule 8:

This is not strong emphasis, because the closing delimiter is
preceded by whitespace:

```````````````````````````````` example
__foo bar __
.
<p>__foo bar __</p>
````````````````````````````````


This is not strong emphasis, because the second `__` is
preceded by punctuation and followed by an alphanumeric:

```````````````````````````````` example
__(__foo)
.
<p>__(__foo)</p>
````````````````````````````````


The point of this restriction is more easily appreciated
with this example:

```````````````````````````````` example
_(__foo__)_
.
<p><em>(<strong>foo</strong>)</em></p>
````````````````````````````````


Intraword strong emphasis is forbidden with `__`:

```````````````````````````````` example
__foo__bar
.
<p>__foo__bar</p>
````````````````````````````````


```````````````````````````````` example
__пристаням__стремятся
.
<p>__пристаням__стремятся</p>
````````````````````````````````


```````````````````````````````` example
__foo__bar__baz__
.
<p><strong>foo__bar__baz</strong></p>
````````````````````````````````


This is strong emphasis, even though the closing delimiter is
both left- and right-flanking, because it is followed by
punctuation:

```````````````````````````````` example
__(bar)__.
.
<p><strong>(bar)</strong>.</p>
````````````````````````````````


Rule 9:

Any nonempty sequence of inline elements can be the contents of an
emphasized span.

```````````````````````````````` example
*foo [bar](/url)*
.
<p><em>foo <a href="/url">bar</a></em></p>
````````````````````````````````


```````````````````````````````` example
*foo
bar*
.
<p><em>foo
bar</em></p>
````````````````````````````````


In particular, emphasis and strong emphasis can be nested
inside emphasis:

```````````````````````````````` example
_foo __bar__ baz_
.
<p><em>foo <strong>bar</strong> baz</em></p>
````````````````````````````````


```````````````````````````````` example
_foo _bar_ baz_
.
<p><em>foo <em>bar</em> baz</em></p>
````````````````````````````````


```````````````````````````````` example
__foo_ bar_
.
<p><em><em>foo</em> bar</em></p>
````````````````````````````````


```````````````````````````````` example
*foo *bar**
.
<p><em>foo <em>bar</em></em></p>
````````````````````````````````


```````````````````````````````` example
*foo **bar** baz*
.
<p><em>foo <strong>bar</strong> baz</em></p>
````````````````````````````````

```````````````````````````````` example
*foo**bar**baz*
.
<p><em>foo<strong>bar</strong>baz</em></p>
````````````````````````````````

Note that in the preceding case, the interpretation

``` markdown
<p><em>foo</em><em>bar<em></em>baz</em></p>
```


is precluded by the condition that a delimiter that
can both open and close (like the `*` after `foo`)
cannot form emphasis if the sum of the lengths of
the delimiter runs containing the opening and
closing delimiters is a multiple of 3.

The same condition ensures that the following
cases are all strong emphasis nested inside
emphasis, even when the interior spaces are
omitted:


```````````````````````````````` example
***foo** bar*
.
<p><em><strong>foo</strong> bar</em></p>
````````````````````````````````


```````````````````````````````` example
*foo **bar***
.
<p><em>foo <strong>bar</strong></em></p>
````````````````````````````````


```````````````````````````````` example
*foo**bar***
.
<p><em>foo<strong>bar</strong></em></p>
````````````````````````````````


Indefinite levels of nesting are possible:

```````````````````````````````` example
*foo **bar *baz* bim** bop*
.
<p><em>foo <strong>bar <em>baz</em> bim</strong> bop</em></p>
````````````````````````````````


```````````````````````````````` example
*foo [*bar*](/url)*
.
<p><em>foo <a href="/url"><em>bar</em></a></em></p>
````````````````````````````````


There can be no empty emphasis or strong emphasis:

```````````````````````````````` example
** is not an empty emphasis
.
<p>** is not an empty emphasis</p>
````````````````````````````````


```````````````````````````````` example
**** is not an empty strong emphasis
.
<p>**** is not an empty strong emphasis</p>
````````````````````````````````



Rule 10:

Any nonempty sequence of inline elements can be the contents of an
strongly emphasized span.

```````````````````````````````` example
**foo [bar](/url)**
.
<p><strong>foo <a href="/url">bar</a></strong></p>
````````````````````````````````


```````````````````````````````` example
**foo
bar**
.
<p><strong>foo
bar</strong></p>
````````````````````````````````


In particular, emphasis and strong emphasis can be nested
inside strong emphasis:

```````````````````````````````` example
__foo _bar_ baz__
.
<p><strong>foo <em>bar</em> baz</strong></p>
````````````````````````````````


```````````````````````````````` example
__foo __bar__ baz__
.
<p><strong>foo <strong>bar</strong> baz</strong></p>
````````````````````````````````


```````````````````````````````` example
____foo__ bar__
.
<p><strong><strong>foo</strong> bar</strong></p>
````````````````````````````````


```````````````````````````````` example
**foo **bar****
.
<p><strong>foo <strong>bar</strong></strong></p>
````````````````````````````````


```````````````````````````````` example
**foo *bar* baz**
.
<p><strong>foo <em>bar</em> baz</strong></p>
````````````````````````````````


```````````````````````````````` example
**foo*bar*baz**
.
<p><strong>foo<em>bar</em>baz</strong></p>
````````````````````````````````


```````````````````````````````` example
***foo* bar**
.
<p><strong><em>foo</em> bar</strong></p>
````````````````````````````````


```````````````````````````````` example
**foo *bar***
.
<p><strong>foo <em>bar</em></strong></p>
````````````````````````````````


Indefinite levels of nesting are possible:

```````````````````````````````` example
**foo *bar **baz**
bim* bop**
.
<p><strong>foo <em>bar <strong>baz</strong>
bim</em> bop</strong></p>
````````````````````````````````


```````````````````````````````` example
**foo [*bar*](/url)**
.
<p><strong>foo <a href="/url"><em>bar</em></a></strong></p>
````````````````````````````````


There can be no empty emphasis or strong emphasis:

```````````````````````````````` example
__ is not an empty emphasis
.
<p>__ is not an empty emphasis</p>
````````````````````````````````


```````````````````````````````` example
____ is not an empty strong emphasis
.
<p>____ is not an empty strong emphasis</p>
````````````````````````````````



Rule 11:

```````````````````````````````` example
foo ***
.
<p>foo ***</p>
````````````````````````````````


```````````````````````````````` example
foo *\**
.
<p>foo <em>*</em></p>
````````````````````````````````


```````````````````````````````` example
foo *_*
.
<p>foo <em>_</em></p>
````````````````````````````````


```````````````````````````````` example
foo *****
.
<p>foo *****</p>
````````````````````````````````


```````````````````````````````` example
foo **\***
.
<p>foo <strong>*</strong></p>
````````````````````````````````


```````````````````````````````` example
foo **_**
.
<p>foo <strong>_</strong></p>
````````````````````````````````


Note that when delimiters do not match evenly, Rule 11 determines
that the excess literal `*` characters will appear outside of the
emphasis, rather than inside it:

```````````````````````````````` example
**foo*
.
<p>*<em>foo</em></p>
````````````````````````````````


```````````````````````````````` example
*foo**
.
<p><em>foo</em>*</p>
````````````````````````````````


```````````````````````````````` example
***foo**
.
<p>*<strong>foo</strong></p>
````````````````````````````````


```````````````````````````````` example
****foo*
.
<p>***<em>foo</em></p>
````````````````````````````````


```````````````````````````````` example
**foo***
.
<p><strong>foo</strong>*</p>
````````````````````````````````


```````````````````````````````` example
*foo****
.
<p><em>foo</em>***</p>
````````````````````````````````



Rule 12:

```````````````````````````````` example
foo ___
.
<p>foo ___</p>
````````````````````````````````


```````````````````````````````` example
foo _\__
.
<p>foo <em>_</em></p>
````````````````````````````````


```````````````````````````````` example
foo _*_
.
<p>foo <em>*</em></p>
````````````````````````````````


```````````````````````````````` example
foo _____
.
<p>foo _____</p>
````````````````````````````````


```````````````````````````````` example
foo __\___
.
<p>foo <strong>_</strong></p>
````````````````````````````````


```````````````````````````````` example
foo __*__
.
<p>foo <strong>*</strong></p>
````````````````````````````````


```````````````````````````````` example
__foo_
.
<p>_<em>foo</em></p>
````````````````````````````````


Note that when delimiters do not match evenly, Rule 12 determines
that the excess literal `_` characters will appear outside of the
emphasis, rather than inside it:

```````````````````````````````` example
_foo__
.
<p><em>foo</em>_</p>
````````````````````````````````


```````````````````````````````` example
___foo__
.
<p>_<strong>foo</strong></p>
````````````````````````````````


```````````````````````````````` example
____foo_
.
<p>___<em>foo</em></p>
````````````````````````````````


```````````````````````````````` example
__foo___
.
<p><strong>foo</strong>_</p>
````````````````````````````````


```````````````````````````````` example
_foo____
.
<p><em>foo</em>___</p>
````````````````````````````````


Rule 13 implies that if you want emphasis nested directly inside
emphasis, you must use different delimiters:

```````````````````````````````` example
**foo**
.
<p><strong>foo</strong></p>
````````````````````````````````


```````````````````````````````` example
*_foo_*
.
<p><em><em>foo</em></em></p>
````````````````````````````````


```````````````````````````````` example
__foo__
.
<p><strong>foo</strong></p>
````````````````````````````````


```````````````````````````````` example
_*foo*_
.
<p><em><em>foo</em></em></p>
````````````````````````````````


However, strong emphasis within strong emphasis is possible without
switching delimiters:

```````````````````````````````` example
****foo****
.
<p><strong><strong>foo</strong></strong></p>
````````````````````````````````


```````````````````````````````` example
____foo____
.
<p><strong><strong>foo</strong></strong></p>
````````````````````````````````



Rule 13 can be applied to arbitrarily long sequences of
delimiters:

```````````````````````````````` example
******foo******
.
<p><strong><strong><strong>foo</strong></strong></strong></p>
````````````````````````````````


Rule 14:

```````````````````````````````` example
***foo***
.
<p><em><strong>foo</strong></em></p>
````````````````````````````````


```````````````````````````````` example
_____foo_____
.
<p><em><strong><strong>foo</strong></strong></em></p>
````````````````````````````````


Rule 15:

```````````````````````````````` example
*foo _bar* baz_
.
<p><em>foo _bar</em> baz_</p>
````````````````````````````````


```````````````````````````````` example
*foo __bar *baz bim__ bam*
.
<p><em>foo <strong>bar *baz bim</strong> bam</em></p>
````````````````````````````````


Rule 16:

```````````````````````````````` example
**foo **bar baz**
.
<p>**foo <strong>bar baz</strong></p>
````````````````````````````````


```````````````````````````````` example
*foo *bar baz*
.
<p>*foo <em>bar baz</em></p>
````````````````````````````````


Rule 17:

```````````````````````````````` example
*[bar*](/url)
.
<p>*<a href="/url">bar*</a></p>
````````````````````````````````


```````````````````````````````` example
_foo [bar_](/url)
.
<p>_foo <a href="/url">bar_</a></p>
````````````````````````````````


```````````````````````````````` example
*<img src="foo" title="*"/>
.
<p>*<img src="foo" title="*"/></p>
````````````````````````````````


```````````````````````````````` example
**<a href="**">
.
<p>**<a href="**"></p>
````````````````````````````````


```````````````````````````````` example
__<a href="__">
.
<p>__<a href="__"></p>
````````````````````````````````


```````````````````````````````` example
*a `*`*
.
<p><em>a <code>*</code></em></p>
````````````````````````````````


```````````````````````````````` example
_a `_`_
.
<p><em>a <code>_</code></em></p>
````````````````````````````````

## Links

A link consists of anchor text encloesd in brackets followed immediately by a destination enclosed in parentheses.

- Anchor text may contain inline elements, but not other links (this is invalid in HTML). If multiple otherwise valid link definitions appear nested inside each other, the inner-most definition is used.

- Brackets are allowed in the anchor text only if (a) they are backslash-escaped or (b) they appear as a matched pair of brackets, with an open bracket `[`, a sequence of zero or more inlines, and a close bracket `]`.

- Backtick code spans and raw HTML tags bind more tightly than the brackets in anchor text. Thus, for example, `` [foo`]` `` could not be a link text, since the second `]` is part of a code span.

- The brackets in link text bind more tightly than markers for emphasis and strong emphasis. Thus, for example, `*[foo*](url)` is a link.

The **link destination** consists of a nonempty sequence of characters that does not include ASCII space or control characters, and includes parentheses only if (a) they are backslash-escaped or (b) they are part of a balanced pair of unescaped parentheses.


Here is a simple link:

```````````````````````````````` example
[link](/uri)
.
<p><a href="/uri">link</a></p>
````````````````````````````````

The destination may not be omitted:

```````````````````````````````` example
[link]()
.
<p>[link]()</p>
````````````````````````````````

Empty anchor text makes the anchor text the destination:

```````````````````````````````` example
[](/uri)
.
<p><a href="/uri">/uri</a></p>
````````````````````````````````

The destination may not contain newlines:

```````````````````````````````` example
[link](foo
bar)
.
<p>[link](foo
bar)</p>
````````````````````````````````

Parentheses inside the link destination may be escaped:

```````````````````````````````` example
[link](\(foo\)\:)
.
<p><a href="(foo):">link</a></p>
````````````````````````````````

Any number of parentheses are allowed without escaping, as long as they are balanced:

```````````````````````````````` example
[link](foo(and(bar)))
.
<p><a href="foo(and(bar))">link</a></p>
````````````````````````````````

However, if you have unbalanced parentheses, you need to escape:

```````````````````````````````` example
[link](foo\(and\(bar\))
.
<p><a href="foo(and(bar)">link</a></p>
````````````````````````````````

A link can contain fragment identifiers and queries:

```````````````````````````````` example
[link](#fragment)

[link](http://example.com#fragment)

[link](http://example.com?foo=3#frag)
.
<p><a href="#fragment">link</a></p>
<p><a href="http://example.com#fragment">link</a></p>
<p><a href="http://example.com?foo=3#frag">link</a></p>
````````````````````````````````

Note that a backslash before a non-escapable character is just a backslash:

```````````````````````````````` example
[link](foo\bar)
.
<p><a href="foo%5Cbar">link</a></p>
````````````````````````````````

URL-escaping should be left alone inside the destination, as all URL-escaped characters are also valid URL characters. However HTML must still be escaped.

```````````````````````````````` example
[link](foo%20b&auml;)
.
<p><a href="foo%20b&amp;auml;">link</a></p>
````````````````````````````````

Unescaped whitespace cannot appear before the destination:

```````````````````````````````` example
[link]( /uri)
.
<p>[link]( /uri)</p>
````````````````````````````````

Whitespace is not allowed between the link text and the following parenthesis:

```````````````````````````````` example
[link] (/uri)
.
<p>[link] (/uri)</p>
````````````````````````````````

The link text may contain balanced brackets, but not unbalanced ones, unless they are escaped:

```````````````````````````````` example
[link [foo [bar]]](/uri)
.
<p><a href="/uri">link [foo [bar]]</a></p>
````````````````````````````````

```````````````````````````````` example
[link] bar](/uri)
.
<p>[link] bar](/uri)</p>
````````````````````````````````

```````````````````````````````` example
[link [bar](/uri)
.
<p>[link <a href="/uri">bar</a></p>
````````````````````````````````

```````````````````````````````` example
[link \[bar](/uri)
.
<p><a href="/uri">link [bar</a></p>
````````````````````````````````

The link text may contain inline content:

```````````````````````````````` example
[link *foo **bar** `#`*](/uri)
.
<p><a href="/uri">link <em>foo <strong>bar</strong> <code>#</code></em></a></p>
````````````````````````````````

```````````````````````````````` example
[![moon](moon.jpg)](/uri)
.
<p><a href="/uri"><img src="moon.jpg" alt="moon"></a></p>
````````````````````````````````

However, links may not contain other links, at any level of nesting.

```````````````````````````````` example
[foo [bar](/uri)](/uri)
.
<p>[foo <a href="/uri">bar</a>](/uri)</p>
````````````````````````````````

```````````````````````````````` example
[foo *[bar [baz](/uri)](/uri)*](/uri)
.
<p>[foo <em>[bar <a href="/uri">baz</a>](/uri)</em>](/uri)</p>
````````````````````````````````

```````````````````````````````` example
![[[foo](uri1)](uri2)](uri3)
.
<p><img src="uri3" alt="[foo](uri2)"></p>
````````````````````````````````

These cases illustrate the precedence of link text grouping over
emphasis grouping:

```````````````````````````````` example
*[foo*](/uri)
.
<p>*<a href="/uri">foo*</a></p>
````````````````````````````````

```````````````````````````````` example
[foo *bar](baz*)
.
<p><a href="baz*">foo *bar</a></p>
````````````````````````````````

Note that brackets that *aren't* part of links do not take precedence:

```````````````````````````````` example
*foo [bar* baz]
.
<p><em>foo [bar</em> baz]</p>
````````````````````````````````

These cases illustrate the precedence of HTML tags and code spans over link grouping:

```````````````````````````````` example
[foo <bar attr="](baz)">
.
<p>[foo <bar attr="](baz)"></p>
````````````````````````````````

```````````````````````````````` example
[foo`](/uri)`
.
<p>[foo<code>](/uri)</code></p>
````````````````````````````````

## Images

Syntax for images is like the syntax for links, with the anchor text interpreted as an **image description** (rendered as the `alt` attribute in HTML). The differences are that (a) an image description starts with `![` rather than `[`, and (b) an image description may contain links.

```````````````````````````````` example
![foo](/url)
.
<p><img src="/url" alt="foo"></p>
````````````````````````````````

```````````````````````````````` example
![foo ![bar](/url)](/url2)
.
<p><img src="/url2" alt="foo bar"></p>
````````````````````````````````

```````````````````````````````` example
![foo [bar](/url)](/url2)
.
<p><img src="/url2" alt="foo bar"></p>
````````````````````````````````

Though this spec is concerned with parsing, not rendering, it is recommended that in rendering to HTML, only the plain string content of the image description be used. Note that in the above example, the alt attribute's value is `foo bar`, not `foo [bar](/url)` or `foo <a href="/url">bar</a>`.  Only the plain string content is rendered, without formatting.

```````````````````````````````` example
![foo *bar*][foobar]

[FOOBAR]: train.jpg
.
<p><img src="train.jpg" alt="foo bar"></p>
````````````````````````````````

```````````````````````````````` example
![foo](train.jpg)
.
<p><img src="train.jpg" alt="foo"></p>
````````````````````````````````

```````````````````````````````` example
My ![foo bar](/path/to/train.jpg)
.
<p>My <img src="/path/to/train.jpg" alt="foo bar"></p>
````````````````````````````````

```````````````````````````````` example
![](/url)
.
<p><img src="/url" alt=""></p>
````````````````````````````````

## Raw HTML

Text between `<` and `>` that looks like an HTML tag is parsed as a
raw HTML tag and will be rendered in HTML without escaping.
Tag and attribute names are not limited to current HTML tags,
so custom tags (and even, say, DocBook tags) may be used.

Here is the grammar for tags:

A **tag name** consists of an ASCII letter
followed by zero or more ASCII letters, digits, or
hyphens (`-`).

An **attribute** consists of whitespace,
an attribute name, and an optional
attribute value specification.

An **attribute name**
consists of an ASCII letter, `_`, or `:`, followed by zero or more ASCII
letters, digits, `_`, `.`, `:`, or `-`.  (Note:  This is the XML
specification restricted to ASCII.  HTML5 is laxer.)

An **attribute value specification**
consists of optional whitespace,
a `=` character, optional whitespace, and an [attribute
value].

An **attribute value**
consists of an unquoted attribute value,
a single-quoted attribute value, or a double-quoted attribute value.

An **unquoted attribute value**
is a nonempty string of characters not
including spaces, `"`, `'`, `=`, `<`, `>`, or `` ` ``.

A **single-quoted attribute value**
consists of `'`, zero or more
characters not including `'`, and a final `'`.

A **double-quoted attribute value**
consists of `"`, zero or more
characters not including `"`, and a final `"`.

An **open tag** consists of a `<` character, a tag name,
zero or more attributes, optional whitespace, an optional `/`
character, and a `>` character.

A **closing tag** consists of the string `</`, a
tag name, optional whitespace, and the character `>`.

An **HTML comment** consists of `<!--` + *text* + `-->`,
where *text* does not start with `>` or `->`, does not end with `-`,
and does not contain `--`.  (See the
[HTML5 spec](http://www.w3.org/TR/html5/syntax.html#comments).)

A **declaration** consists of the
string `<!`, a name consisting of one or more uppercase ASCII letters,
whitespace, a string of characters not including the
character `>`, and the character `>`.

An **HTML tag** consists of an open tag, a closing tag,
an HTML comment, or a declaration.

Here are some simple open tags:

```````````````````````````````` example
<a><bab><c2c>
.
<p><a><bab><c2c></p>
````````````````````````````````


Empty elements:

```````````````````````````````` example
<a/><b2/>
.
<p><a/><b2/></p>
````````````````````````````````


Whitespace is allowed:

```````````````````````````````` example
<a  /><b2
data="foo" >
.
<p><a  /><b2
data="foo" ></p>
````````````````````````````````


With attributes:

```````````````````````````````` example
<a foo="bar" bam = 'baz <em>"</em>'
_boolean zoop:33=zoop:33 />
.
<p><a foo="bar" bam = 'baz <em>"</em>'
_boolean zoop:33=zoop:33 /></p>
````````````````````````````````


Custom tag names can be used:

```````````````````````````````` example
Foo <responsive-image src="foo.jpg" />
.
<p>Foo <responsive-image src="foo.jpg" /></p>
````````````````````````````````


Illegal tag names, not parsed as HTML:

```````````````````````````````` example
<33> <__>
.
<p>&lt;33&gt; &lt;__&gt;</p>
````````````````````````````````


Illegal attribute names:

```````````````````````````````` example
<a h*#ref="hi">
.
<p>&lt;a h*#ref=&quot;hi&quot;&gt;</p>
````````````````````````````````


Illegal attribute values:

```````````````````````````````` example
<a href="hi'> <a href=hi'>
.
<p>&lt;a href=&quot;hi'&gt; &lt;a href=hi'&gt;</p>
````````````````````````````````


Illegal whitespace:

```````````````````````````````` example
< a><
foo><bar/ >
.
<p>&lt; a&gt;&lt;
foo&gt;&lt;bar/ &gt;</p>
````````````````````````````````


Missing whitespace:

```````````````````````````````` example
<a href='bar'title=title>
.
<p>&lt;a href='bar'title=title&gt;</p>
````````````````````````````````


Closing tags:

```````````````````````````````` example
</a></foo >
.
<p></a></foo ></p>
````````````````````````````````


Illegal attributes in closing tag:

```````````````````````````````` example
</a href="foo">
.
<p>&lt;/a href=&quot;foo&quot;&gt;</p>
````````````````````````````````


Comments:

```````````````````````````````` example
foo <!-- this is a
comment - with hyphen -->
.
<p>foo <!-- this is a
comment - with hyphen --></p>
````````````````````````````````


```````````````````````````````` example
foo <!-- not a comment -- two hyphens -->
.
<p>foo &lt;!-- not a comment -- two hyphens --&gt;</p>
````````````````````````````````


Not comments:

```````````````````````````````` example
foo <!--> foo -->

foo <!-- foo--->
.
<p>foo &lt;!--&gt; foo --&gt;</p>
<p>foo &lt;!-- foo---&gt;</p>
````````````````````````````````


Declarations:

```````````````````````````````` example
foo <!ELEMENT br EMPTY>
.
<p>foo <!ELEMENT br EMPTY></p>
````````````````````````````````


Entity and numeric character references are preserved in HTML
attributes:

```````````````````````````````` example
foo <a href="&ouml;">
.
<p>foo <a href="&ouml;"></p>
````````````````````````````````


Backslash escapes do not work in HTML attributes:

```````````````````````````````` example
foo <a href="\*">
.
<p>foo <a href="\*"></p>
````````````````````````````````


```````````````````````````````` example
<a href="\"">
.
<p>&lt;a href=&quot;&quot;&quot;&gt;</p>
````````````````````````````````

## Soft line breaks

A regular line break (not in a code span or HTML tag) that is not directly after a backslash is parsed as a **softbreak**. A softbreak should be rendered in HTML as a newline; this will not display a line break by default, allowing hard-wrapped paragraphs to render correctly, but if you want them to render as line breaks, use this CSS:

```css
p {
	white-space: pre-line;
	word-break: break-word;
}
```

An example of a soft break:

```````````````````````````````` example
foo
baz
.
<p>foo
baz</p>
````````````````````````````````

## Hard line breaks

A backslash before the line ending may be used to insert a line break (`<br>`) regardless of CSS:

```````````````````````````````` example
foo\
baz
.
<p>foo<br>baz</p>
````````````````````````````````

Note that this must *not* be rendered with an ASCII newline after the `<br>` or else it would appear as *two* line breaks if the suggested CSS is used.

Line breaks can occur inside emphasis, links, and other constructs that allow inline content:

```````````````````````````````` example
*foo\
bar*
.
<p><em>foo<br>bar</em></p>
````````````````````````````````

Line breaks do not occur inside code spans

```````````````````````````````` example
`code
span`
.
<p><code>code span</code></p>
````````````````````````````````


```````````````````````````````` example
`code\
span`
.
<p><code>code\ span</code></p>
````````````````````````````````

or HTML tags:

```````````````````````````````` example
<a href="foo\
bar">
.
<p><a href="foo\
bar"></p>
````````````````````````````````

Hard line breaks are for separating inline content within a block. They don't work at the end of a paragraph or other block element:

```````````````````````````````` example
foo\
.
<p>foo\</p>
````````````````````````````````

```````````````````````````````` example
### foo\
.
<h3>foo\</h3>
````````````````````````````````

## Textual content

Any characters not given an interpretation by the above rules will be parsed as plain textual content.

```````````````````````````````` example
hello $.;'there
.
<p>hello $.;'there</p>
````````````````````````````````

```````````````````````````````` example
Foo χρῆν
.
<p>Foo χρῆν</p>
````````````````````````````````

Internal spaces are preserved verbatim:

```````````````````````````````` example
Multiple     spaces
.
<p>Multiple     spaces</p>
````````````````````````````````
