Checkmate
=========

Checkmate is a simple way to create style checkers for various languages. It does simple parsing of source
files and then applies user-specified rules to detect style violations.

Code parsing is *not* full lexing; it is an intentional design goal to limit code introspection in order to
avoid overlap with tasks best left to language-specific linters and static analysis tools. To that end, the
code parsing is done with Textpow, which uses TextMate syntax files and annotates source with tags (so that we
can detect things like comments, string literals, etc). Then rules are applied based on Textpow tags.

Creating new styles
-------------------

To create a new style, you will need a Textmate syntax file and a rules file written in the Checkmate DSL.

The easiest way to get Textmate syntax files is to copy them out of a Textmate installation on your computer.
They should have the path

    /Applications/TextMate.app/Contents/SharedSupport/Bundles/<your-language>.tmbundle/Syntaxes/<your-language>.plist

This is a binary plist file, and Checkmate requires it to be in the text XML format; you can convert it like this:

    $ plutil -convert xml1 <your-language>.plist

(Of course, you'll want to copy the plist file into the project directory to avoid corrupting your TextMate
installation). You can download other, more exotic TextMate syntax files from the [TextMate subversion
repository](http://svn.textmate.org/trunk/Bundles/).

Next, you need to write your rules file.

TODO(caleb): Update steps below.

1. Make a file called `<language>_style.rb`, where `<language>` is the type of file you want to check.
2. Use the DSL implemented in this file to write your style.
   * The regex you give to Checkmate::Style#create matches the filenames you wish to check.
   * Each rule consists of a regex and a message to indicate what the violation was.
   * The regex may contain a match. The offset of the beginning of this match will be used to indicate
     exactly where a style violation occurred.

Dumb example:

    Checkmate::Style.create(/\.txt$/) do
      rule /(q)/, "The letter 'q' is not allowed in text files."
    end

Output formats
--------------

TODO(caleb) Implement these. Ideas:

* Colorized console output
* Summary output suitable for consumption by other tools (# of tests / # of failures)
* Markdown? (For automatic CR bot)

Usage
-----

TODO(caleb)
