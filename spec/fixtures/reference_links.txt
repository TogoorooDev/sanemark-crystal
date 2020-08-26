## Reference links

There are three kinds of **reference link**s:
[full](#full-reference-link), [collapsed](#collapsed-reference-link),
and [shortcut](#shortcut-reference-link).

A **full reference link**
consists of a link text] immediately followed by a link label
that matches a link reference definition elsewhere in the document.

A **link label**  begins with a left bracket (`[`) and ends
with the first right bracket (`]`) that is not backslash-escaped.
Between these brackets there must be at least one [non-whitespace character].
Unescaped square bracket characters are not allowed in
[link labels].

One label **matches**
another just in case their normalized forms are equal.  To normalize a
label, perform the *Unicode case fold* and collapse consecutive internal
[whitespace] to a single space.  If there are multiple
matching reference link definitions, the one that comes first in the
document is used.  (It is desirable in such cases to emit a warning.)

The contents of the first link label are parsed as inlines, which are
used as the link's text.  The link's URI and title are provided by the
matching link reference definition.

Here is a simple example:

```````````````````````````````` example
[foo][bar]

[bar]: /url
.
<p><a href="/url">foo</a></p>
````````````````````````````````

The rules for the link text are the same as with inline links. Thus:

The link text may contain balanced brackets, but not unbalanced ones, unless they are escaped:

```````````````````````````````` example
[link [foo [bar]]][ref]

[ref]: /uri
.
<p><a href="/uri">link [foo [bar]]</a></p>
````````````````````````````````

```````````````````````````````` example
[link \[bar][ref]

[ref]: /uri
.
<p><a href="/uri">link [bar</a></p>
````````````````````````````````

The link text may contain inline content:

```````````````````````````````` example
[link *foo **bar** `#`*][ref]

[ref]: /uri
.
<p><a href="/uri">link <em>foo <strong>bar</strong> <code>#</code></em></a></p>
````````````````````````````````

```````````````````````````````` example
[![moon](moon.jpg)][ref]

[ref]: /uri
.
<p><a href="/uri"><img src="moon.jpg" alt="moon"></a></p>
````````````````````````````````

However, links may not contain other links, at any level of nesting.

```````````````````````````````` example
[foo [bar](/uri)][ref]

[ref]: /uri
.
<p>[foo <a href="/uri">bar</a>]<a href="/uri">ref</a></p>
````````````````````````````````

```````````````````````````````` example
[foo *bar [baz][ref]*][ref]

[ref]: /uri
.
<p>[foo <em>bar <a href="/uri">baz</a></em>]<a href="/uri">ref</a></p>
````````````````````````````````

(In the examples above, we have two [shortcut reference links] instead of one full reference link.)

The following cases illustrate the precedence of link text grouping over
emphasis grouping:

```````````````````````````````` example
*[foo*][ref]

[ref]: /uri
.
<p>*<a href="/uri">foo*</a></p>
````````````````````````````````


```````````````````````````````` example
[foo *bar][ref]

[ref]: /uri
.
<p><a href="/uri">foo *bar</a></p>
````````````````````````````````


These cases illustrate the precedence of HTML tags and code spans over link grouping:

```````````````````````````````` example
[foo <bar attr="][ref]">

[ref]: /uri
.
<p>[foo <bar attr="][ref]"></p>
````````````````````````````````


```````````````````````````````` example
[foo`][ref]`

[ref]: /uri
.
<p>[foo<code>][ref]</code></p>
````````````````````````````````

Matching is case-insensitive:

```````````````````````````````` example
[foo][BaR]

[bar]: /url
.
<p><a href="/url">foo</a></p>
````````````````````````````````

Unicode case fold is used:

```````````````````````````````` example
[Толпой][Толпой] is a Russian word.

[ТОЛПОЙ]: /url
.
<p><a href="/url">Толпой</a> is a Russian word.</p>
````````````````````````````````

Consecutive internal whitespace is treated as one space for purposes of determining matching:

```````````````````````````````` example
[Foo
  bar]: /url

[Baz][Foo bar]
.
<p><a href="/url">Baz</a></p>
````````````````````````````````

No whitespace is allowed between the link text and the
link label:

```````````````````````````````` example
[foo] [bar]

[bar]: /url
.
<p>[foo] <a href="/url">bar</a></p>
````````````````````````````````

```````````````````````````````` example
[foo]
[bar]

[bar]: /url
.
<p>[foo]
<a href="/url">bar</a></p>
````````````````````````````````

Note that matching is performed on normalized strings, not parsed
inline content.  So the following does not match, even though the
labels define equivalent inline content:

```````````````````````````````` example
[bar][foo\!]

[foo!]: /url
.
<p>[bar][foo!]</p>
````````````````````````````````

Link labels cannot contain brackets, unless they are backslash-escaped:

```````````````````````````````` example
[foo][ref[]

[ref[]: /uri
.
<p>[foo][ref[]</p>
<p>[ref[]: /uri</p>
````````````````````````````````

```````````````````````````````` example
[foo][ref[bar]]

[ref[bar]]: /uri
.
<p>[foo][ref[bar]]</p>
<p>[ref[bar]]: /uri</p>
````````````````````````````````

```````````````````````````````` example
[[[foo]]]

[[[foo]]]: /url
.
<p>[[[foo]]]</p>
<p>[[[foo]]]: /url</p>
````````````````````````````````

```````````````````````````````` example
[foo][ref\[]

[ref\[]: /uri
.
<p><a href="/uri">foo</a></p>
````````````````````````````````

Note that in this example `]` is not backslash-escaped:

```````````````````````````````` example
[bar\\]: /uri

[bar\\]
.
<p><a href="/uri">bar\</a></p>
````````````````````````````````

A link label must contain at least one non-whitespace character:

```````````````````````````````` example
[]

[]: /uri
.
<p>[]</p>
<p>[]: /uri</p>
````````````````````````````````

```````````````````````````````` example
[
 ]

[
 ]: /uri
.
<p>[
]</p>
<p>[
]: /uri</p>
````````````````````````````````

A **collapsed reference link** consists of a link label that matches a link reference definition elsewhere in the document, followed by the string `[]`. The contents of the first link label are parsed as inlines, which are used as the link's text. The link's URI and title are provided by the matching reference link definition. Thus, `foo` is equivalent to `[foo][foo]`.

```````````````````````````````` example
[foo][]

[foo]: /url
.
<p><a href="/url">foo</a></p>
````````````````````````````````

```````````````````````````````` example
[*foo* bar][]

[*foo* bar]: /url
.
<p><a href="/url"><em>foo</em> bar</a></p>
````````````````````````````````

The link labels are case-insensitive:

```````````````````````````````` example
[Foo][]

[foo]: /url
.
<p><a href="/url">Foo</a></p>
````````````````````````````````

As with full reference links, whitespace is not
allowed between the two sets of brackets:

```````````````````````````````` example
[foo] []

[foo]: /url
.
<p><a href="/url">foo</a> []</p>
````````````````````````````````

A **shortcut reference link**
consists of a link label that matches a
link reference definition elsewhere in the
document and is not followed by `[]` or a link label.
The contents of the first link label are parsed as inlines,
which are used as the link's text.  The link's URI and title
are provided by the matching link reference definition.
Thus, `[foo]` is equivalent to `[foo][]`.

```````````````````````````````` example
[foo]

[foo]: /url
.
<p><a href="/url">foo</a></p>
````````````````````````````````

```````````````````````````````` example
[*foo* bar]

[*foo* bar]: /url
.
<p><a href="/url"><em>foo</em> bar</a></p>
````````````````````````````````

```````````````````````````````` example
[[*foo* bar]]

[*foo* bar]: /url
.
<p>[<a href="/url"><em>foo</em> bar</a>]</p>
````````````````````````````````

```````````````````````````````` example
[[bar [foo]

[foo]: /url
.
<p>[[bar <a href="/url">foo</a></p>
````````````````````````````````

The link labels are case-insensitive:

```````````````````````````````` example
[Foo]

[foo]: /url
.
<p><a href="/url">Foo</a></p>
````````````````````````````````

A space after the link text should be preserved:

```````````````````````````````` example
[foo] bar

[foo]: /url
.
<p><a href="/url">foo</a> bar</p>
````````````````````````````````

If you just want bracketed text, you can backslash-escape the opening bracket to avoid links:

```````````````````````````````` example
\[foo]

[foo]: /url
.
<p>[foo]</p>
````````````````````````````````

Note that this is a link, because a link label ends with the first following closing bracket:

```````````````````````````````` example
[foo*]: /url

*[foo*]
.
<p>*<a href="/url">foo*</a></p>
````````````````````````````````

Full and compact references take precedence over shortcut
references:

```````````````````````````````` example
[foo][bar]

[foo]: /url1
[bar]: /url2
.
<p><a href="/url2">foo</a></p>
````````````````````````````````

```````````````````````````````` example
[foo][]

[foo]: /url1
.
<p><a href="/url1">foo</a></p>
````````````````````````````````

Inline links also take precedence:

```````````````````````````````` example
[foo](/url1)

[foo]: /url2
.
<p><a href="/url1">foo</a></p>
````````````````````````````````

```````````````````````````````` example
[foo](not a link)

[foo]: /url1
.
<p><a href="/url1">foo</a>(not a link)</p>
````````````````````````````````

In the following case `[bar][baz]` is parsed as a reference,
`[foo]` as normal text:

```````````````````````````````` example
[foo][bar][baz]

[baz]: /url
.
<p>[foo]<a href="/url">bar</a></p>
````````````````````````````````

Here, though, `[foo][bar]` is parsed as a reference, since `[bar]` is defined:

```````````````````````````````` example
[foo][bar][baz]

[baz]: /url1
[bar]: /url2
.
<p><a href="/url2">foo</a><a href="/url1">baz</a></p>
````````````````````````````````


Here `[foo]` is not parsed as a shortcut reference, because it
is followed by a link label (even though `[bar]` is not defined):

```````````````````````````````` example
[foo][bar][baz]

[baz]: /url1
[foo]: /url2
.
<p>[foo]<a href="/url1">bar</a></p>
````````````````````````````````

## Link reference definitions

A **link reference definition** consists of a link label followed by a colon (`:`), optional whitespace (including up to one line ending), a link destination, and then the end of the line.

A link reference definition does not correspond to a structural element of a document. Instead, it defines a label which can be used in reference links and reference-style images elsewhere in the document. Link reference definitions can come either before or after the links that use them.

```````````````````````````````` example
[foo]: /url

[foo]
.
<p><a href="/url">foo</a></p>
````````````````````````````````

Link references can be indented 1-3 spaces:
```````````````````````````````` example
 [foo]: /url

[foo]
.
<p><a href="/url">foo</a></p>
````````````````````````````````

```````````````````````````````` example
[Foo*bar\]]:my_(url)

[Foo*bar\]]
.
<p><a href="my_(url)">Foo*bar]</a></p>
````````````````````````````````

```````````````````````````````` example
[Foo bar]:
my%20url

[Foo bar]
.
<p><a href="my%20url">Foo bar</a></p>
````````````````````````````````

The destination can contain backslash escapes and literal backslashes:

```````````````````````````````` example
[foo]: /url\bar\*baz

[foo]
.
<p><a href="/url%5Cbar*baz">foo</a></p>
````````````````````````````````

A link can come before its corresponding definition:

```````````````````````````````` example
[foo]

[foo]: url
.
<p><a href="url">foo</a></p>
````````````````````````````````

As noted in the section on [Links], matching of labels is case-insensitive (see [matches]).

```````````````````````````````` example
[FOO]: /url

[Foo]
.
<p><a href="/url">Foo</a></p>
````````````````````````````````

```````````````````````````````` example
[ΑΓΩ]: /φου

[αγω]
.
<p><a href="/%CF%86%CE%BF%CF%85">αγω</a></p>
````````````````````````````````

Here is a link reference definition with no corresponding link.
It contributes nothing to the document.

```````````````````````````````` example
[foo]: /url
.
````````````````````````````````

Here is another one:

```````````````````````````````` example
[
foo
]: /url
bar
.
<p>bar</p>
````````````````````````````````

This is not a link reference definition, because there are
non-whitespace characters after the title:

```````````````````````````````` example
[foo]: /url foo
.
<p>[foo]: /url foo</p>
````````````````````````````````

This is not a link reference definition, because it occurs inside
a code block:

```````````````````````````````` example
```
[foo]: /url
```

[foo]
.
<pre><code>[foo]: /url
</code></pre>
<p>[foo]</p>
````````````````````````````````

A link reference definition cannot interrupt a paragraph.

```````````````````````````````` example
Foo
[bar]: /baz

[bar]
.
<p>Foo
[bar]: /baz</p>
<p>[bar]</p>
````````````````````````````````

However, it can directly follow other block elements, such as headings and thematic breaks, and it need not be followed by a blank line.

```````````````````````````````` example
# [Foo]
[foo]: /url
> bar
.
<h1><a href="/url">Foo</a></h1>
<blockquote>
<p>bar</p>
</blockquote>
````````````````````````````````

Several link reference definitions can occur one after another, without intervening blank lines.

```````````````````````````````` example
[foo]: /foo-url
[bar]: /bar-url
[baz]: /baz-url

[foo],
[bar],
[baz]
.
<p><a href="/foo-url">foo</a>,
<a href="/bar-url">bar</a>,
<a href="/baz-url">baz</a></p>
````````````````````````````````

[Link reference definitions] can occur inside block containers, like lists and block quotations. They affect the entire document, not just the container in which they are defined:

```````````````````````````````` example
[foo]

> [foo]: /url
.
<p><a href="/url">foo</a></p>
<blockquote>
</blockquote>
````````````````````````````````

## Images


```````````````````````````````` example
![foo *bar*]

[foo *bar*]: train.jpg
.
<p><img src="train.jpg" alt="foo bar"></p>
````````````````````````````````

```````````````````````````````` example
![foo][bar]

[bar]: /url
.
<p><img src="/url" alt="foo"></p>
````````````````````````````````

```````````````````````````````` example
![foo][bar]

[BAR]: /url
.
<p><img src="/url" alt="foo"></p>
````````````````````````````````

Collapsed:

```````````````````````````````` example
![foo][]

[foo]: /url
.
<p><img src="/url" alt="foo"></p>
````````````````````````````````

```````````````````````````````` example
![*foo* bar][]

[*foo* bar]: /url
.
<p><img src="/url" alt="foo bar"></p>
````````````````````````````````

The labels are case-insensitive:

```````````````````````````````` example
![Foo][]

[foo]: /url
.
<p><img src="/url" alt="Foo"></p>
````````````````````````````````

As with reference links, whitespace is not allowed between the two sets of brackets:

```````````````````````````````` example
![foo] []

[foo]: /url
.
<p><img src="/url" alt="foo"> []</p>
````````````````````````````````

Shortcut:

```````````````````````````````` example
![foo]

[foo]: /url
.
<p><img src="/url" alt="foo"></p>
````````````````````````````````

```````````````````````````````` example
![*foo* bar]

[*foo* bar]: /url
.
<p><img src="/url" alt="foo bar"></p>
````````````````````````````````

Note that link labels cannot contain unescaped brackets:

```````````````````````````````` example
![[foo]]

[[foo]]: /url
.
<p>![[foo]]</p>
<p>[[foo]]: /url</p>
````````````````````````````````

The link labels are case-insensitive:

```````````````````````````````` example
![Foo]

[foo]: /url
.
<p><img src="/url" alt="Foo"></p>
````````````````````````````````

If you just want bracketed text, you can backslash-escape the opening `!` and `[`:

```````````````````````````````` example
\!\[foo]

[foo]: /url
.
<p>![foo]</p>
````````````````````````````````

If you want a link after a literal `!`, backslash-escape the `!`:

```````````````````````````````` example
\![foo]

[foo]: /url
.
<p>!<a href="/url">foo</a></p>
````````````````````````````````
