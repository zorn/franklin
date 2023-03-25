# Testing in Franklin 

- Testing is a broad and easily conflated topic. 
- The following is a set of values that we try to follow when it comes to testing in Franklin.


- Testing is not a goal on to itself. It is part of a larger goal of building systems that are: stable, easy to change
- We have a few values that we try to follow when it comes to testing in Franklin.



Why it's important to state the testing values of a project.

What our values are.

Code is a liability, not an asset. A small number of highly valuable tests will do a much better job protecting the project from bugs than a large number of mediocre tests. They couple tests to the class’s implementation details, as opposed to its observable behavior.

Mocks aren't your friend. Mostly. This is the road to brittle tests, paved with good intentions.


How you can observe these values in action.

These values drew heavy inspiration from Clarity, TDD what when wrong and the book.


My goal concerning testing is to shoot for the maximum about of system confidence while writing the fewest tests as possible. I highly prefer my test be written in the language of my contract with the user, with small exceptions for tricky implementation details.

I'm fine writing tests against the implementation if I can in a TDD session, those help me in the moment but when it comes time to merge things, I want to refactor those tests into the language of the user.

I want to embrace the full spectrum of tools (not just testing) to verify the correctness and successful use of my software. This includes manual QA, error capture (Sentry), uptime, and other general observability.

Why we avoid testing implementation: it will change and as we refactor implementation (that does not change the user contract) we should not have to edit a bunch of tests.

Things to capture:

    Work hard to follow a single Arrange/Act/Assert flow. If you are doing more acts after asserts, you might be breaking this ideal.
    Multiple asserts are allowed, as we are testing a unit of domain behavior, not a line of code.
