Bus Scheme
    by Phil Hagelberg (c) 2007 - 2008
    http://bus-scheme.rubyforge.org

== Description

Bus Scheme is a Scheme written in Ruby, but implemented on the bus!
Every programmer must implement Scheme as a rite of passage; this is
mine. Note that at least half of the implementation of Bus Scheme must
be written while on a bus. Documentation, tests, and administrivia may
be accomplished elsewhere, but the majority of actual implementation
code is strictly bus-driven. Patches are welcome especially if they were
written while riding a bus. (If your daily commute does not involve a
bus but you want to submit a patch, we may be able to work something
out regarding code written on trains, ferries, or perhaps even carpool
lanes.) Bus Scheme is primarily a toy; using it for anything serious
is (right now) ill-advised.

Bus Scheme aims for general Scheme usefulness optimized for learning
and fun. It's not targeting R5RS or anything like that.

== Usage

$ bus # drop into the REPL

$ bus -e "(do some stuff)"

$ bus foo.scm # load a file

== What makes Bus Scheme different?

Well, for starters it's implemented on the bus. No other Scheme
implementation can claim this. Here are a few other things that set
Bus Scheme apart:

=== Flexible calling syntax

Taking a hint from Arc, Bus Scheme allows you to use the notation
(mylist n) to access the nth place of the mylist list instead of (nth
mylist n) or the (myhash key) notation to access the slot in myhash
corresponding to the value of key instead of (gethash myhash key). 
TODO: This notation is flexible, and other data types may have
their own "call behaviour" specified.

=== Mongrel integration

Web and RESTful application development are part of the package. Bus
Scheme uses the wonderful Mongrel web server to allow scheme programs
to serve web applications. TODO: Representations of data can be easily
translated between s-expressions, HTML, and JSON.

=== Written in a high-level language

Bus Scheme is written in Ruby, which means anyone with experience in
high-level dynamic languages (like, oh, I don't know... Scheme?)
should be right at home poking around at the implementation. Using
Ruby allows the implementation code to remain compact and concise. Bus
Scheme should run on Ruby 1.8, Ruby 1.9, and Rubinius at least. Bus
Scheme also allows you to drop into Ruby when that's convenient. TODO:
allow real inline Ruby blocks instead of access via a function call.

=== XML integration

TODO: Bus Scheme has a notion of XML literals so that it may be
inlined into your Scheme code, much like the way ECMAScript uses
E4X. If you'd prefer, you can leverage convenient s-expression -> XML
conversion facilities.

=== Test-Driven

Bus Scheme is written in an entirely test-driven manner. As much as
possible, it tries to keep its tests written in Scheme itself, so it
includes a fairly comprehensive testing suite and encourages programs
to be written test-first.

== Install

* sudo gem install bus-scheme

For the source:

* git clone git://git.caboo.se/bus_scheme.git

== Todo

Bus Scheme is currently missing pieces of functionality:

=== Parser
* character literals
* multiline strings
* dotted cons cells

=== General
* test framework needs work
* macros
* continuations

Failing tests for some of these are already included (commented out,
mostly) in the relevant test files.

=== Long Term (post 1.0)
* web functions (defresource and friends)
* (lambda (arg1 arg2 . args) body) for rest args
* string interpolation
* escape sequences in strings
* Ruby blocks inline?
* XML literals?
* optimize tail call recursion
* compile to Rubinius bytecode
* custom call behaviour
* parse non-decimal base numbers
* parse rationals, scientific, complex, and polar complex numbers

== Requirements

Bus Scheme should run on (at least) Ruby 1.8, Ruby 1.9, and Rubinius.

== Bonus Fact

I haven't actually used a real Scheme yet. Everything I know about it
I've gathered from reading The Little Schemer, watching the Structure
and Interpretation of Computer Programs videos, and reading lots about
Common Lisp and Emacs Lisp. If there are huge gaping flaws in the
implementation, this is likely to be why.
