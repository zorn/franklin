# Testing in Franklin 

Testing is a broad and easily conflated topic of discussion. 

The following document seeks to define a particular perspective this projects takes towards testing. By having this documented, future and returning contributors can better align their work to a common goal.

## High-level project values

Writing automated test code is not a goal unto itself. It is a particular practice, mixed with other team behaviors, that ultimately work towards the project's core values. 

For Franklin this is summarized as: "we value building reliable and sustainable software".

* **Reliable** in that the software provides correct and consistent value to its users. 
* **Sustainable** in that the software is easy to change and maintain; overcoming an an ever changing team of contributors, the human condition of forgetfulness, every growing requirements, and never ending updates to dependencies.

In addition to writing automated tests to fullfil these values, we also expect:

* **manual testing** as part of a quality assurance process.
* **system observability** of production deployments to better see and understand what is happening in the real world.
* **code-level collaboration and review** with other developers to make sure the code being contributed meets the domain requirements while also being expressed with a professional level of clarity.

## Franklin's testing approach

So with all of the context out in the open, how do we approach testing in Franklin?



## What makes a successful automated test suite?


1. It's integrated into the development cycle.
2. It targets only the most important parts of your code base.
3. It provides maximum value with minimum maintenance costs.

### 1. It's integrated into the development cycle.

Writing automated tests and not automating their regular execution is madness. Tests should be ran as part of the project's CI cycle, including the main branch and pull requests.

### 2. It targets only the most important parts of your code base.



### 3. It provides maximum value with minimum maintenance costs.


# What makes a successful test suite?



Why it's important to state the testing values of a project.

What our values are.

Code is a liability, not an asset. A small number of highly valuable tests will do a much better job protecting the project from bugs than a large number of mediocre tests. They couple tests to the class's implementation details, as opposed to its observable behavior.

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
