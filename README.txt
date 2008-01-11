Bus Scheme
    by Phil Hagelberg (c) 2007
    http://bus-scheme.rubyforge.org

== Description

Bus Scheme is a Scheme written in Ruby, but implemented on the bus!
Every programmer must implement Scheme as a rite of passage; this is
mine. Note that all the implementation of Bus Scheme must be written
while on a bus. Documentation, tests, and administrivia may be
accomplished elsewhere, but all actual implementation code is strictly
bus-driven. Patches are welcome as long as they were written while
riding a bus. (If your daily commute does not involve a bus but you
want to submit a patch, we may be able to work something out regarding
code written on trains, ferries, or perhaps even carpool lanes.) Bus
Scheme is primarily a toy; using it for anything serious is (right
now) ill-advised.

Bus Scheme aims for general Scheme usefulness optimized for learning
and fun. It's not targeting R5RS or anything like that.

== Install

* sudo gem install bus-scheme

For the source:

* git clone git://git.caboo.se/bus_scheme.git

== Usage

$ bus # drop into a repl

$ bus -e "(do some stuff)"

$ bus foo.scm # load a file

== Todo

Bus Scheme is currently missing pieces of functionality:

* optimize tail call recursion
* continuations (?!?)
* parse cons cells
* parse character literals
* parse quote, unquote

Failing tests for some of these are already included (commented out,
mostly) in the relevant test files.

== Requirements

Bus Scheme should run on (at least) Ruby 1.8, Ruby 1.9, and Rubinius.

== Bonus Fact

I haven't actually used a real Scheme yet. Everything I know about it
I've gathered from reading The Little Schemer, watching the Structure
and Interpretation of Computer Programs videos, and reading lots about
Common Lisp and Emacs Lisp. If there are huge gaping flaws in the
implementation, this is likely to be why.
