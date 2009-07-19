= ecstatic

* http://github.com/jgm/ecstatic

== DESCRIPTION:

ecstatic helps you manage a static website.  Pages are generated
from tenjin templates and YAML data files.

== FEATURES:

* Generates a static site, for high performance and security
* Separation of data and presentation, as in a dynamic web framework,
  but with data in text files rather than databases
* Supports markdown
* Supports output in HTML, plain text, and LaTeX

== SYNOPSIS:

First, generate a site skeleton:

    ecstatic mysite

See what has been done:

    cd mysite
    ls

To build the site (in the <tt>site</tt> directory):

    rake

Try modifying the layout (<tt>standard.rbhtml</tt>),
the data (<tt>events.yaml</tt>), or the template
(<tt>events.rbhtml</tt>).  Recompile the site with rake.

If you want to add new pages, just add templates and
datafiles, and register the pages in <tt>siteindex.yaml</tt>.
Put any static files in <tt>files</tt>; these will be copied
verbatim into the site.

If a page has no dynamic elements (other than the ones handled
by the layout), you can use a markdown file instead of a
template.  Just give it the extension <tt>.markdown</tt>

== REQUIREMENTS:

* rpeg-markdown
* tenjin
* activesupport

== INSTALL:

* sudo gem install ecstatic

== LICENSE:

(The MIT License)

Copyright (c) 2009 John MacFarlane

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
