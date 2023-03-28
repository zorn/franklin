# Testing in Franklin 

The following document defines a particular perspective this project takes toward testing. By documenting this, future and returning contributors can better align their work to a common goal.

## High-level project values

Writing test code is not a goal in itself. It is a particular practice, mixed with other team behaviors, that works towards the project's core values: "we value building reliable and sustainable software."

* **Reliable** in that the software provides correct and consistent value to its users. 
* **Sustainable** in that the software is easy to change and maintain with confidence, overcoming a diverse team of contributors, the human condition of forgetfulness, ever-growing requirements, and never-ending dependency updates.

In addition to writing automated tests to satisfy these values, we also expect the following:

* **manual testing** as part of a quality assurance process to verify the software meets the domain requirements and provides a delightful user experience.
* **system observability** of production deployments (error and logging capture, uptime, telemetry, etc.) to better see and understand what is happening in the real world.
* **code-level collaboration and review** to make sure the code contributed meets the domain requirements while also being expressed with a professional level of clarity.

## Franklin's testing approach

### Automated in CI

The project is configured to run all tests and other code quality checks during merges into `main` and proposed pull requests. We value the consistency of running these checks often and with haste. The CI checks are broken into isolated steps to provide helpful signals in a single CI pass allowing contributors to fix multiple issues before the next round of code updates on their branch.

## We prioritize testing our contracts with the user

Our software provides a user contract expressed in a domain. We write our tests in the language of that contract and, when possible, test using the user's interface (i.e.: a LiveView experience, an API call, etc.) to verify the contract works as expected.

**We are not interested in using tests to verify the implementation of the contract.** As an example, the current version of the app might persist a user's profile in Postgres, but that might change in the future. If the user contract states they can read and write their profile via an API call, that is what we test. If we swap out Postgres for something else in the future, the test should still work.

> Aside: Sometimes, starting a new feature and testing at the user contract level can be challenging. In these cases, it can be helpful to focus on smaller implementation modules and write tests against those to keep things simple and focused at the start. Do this, write headless tests against your domain logic, and then over time, as the user's interface becomes available, refactor them into user-contract level tests and delete the original.

## Arrange the system state with the user contracts too

In that same spirit, as you _arrange_ the system's state in preparation for an _act_ and _assert_ inside a test, the _arrange_ should also, when possible, use the user perspective to set up that data. Yes, this results in slower tests, but we want to avoid coupling the tests to implementation assumptions to allow the codebase to evolve. If your tests were raw injecting rows into a Postgres database before our change, we would need to update all your tests during our refactor.

Like all things, this is a tradeoff, and there may be times when this rule needs to be broken. If you decide to couple the tests to implementation, please do it with awareness and caution. Document why you chose this tradeoff so it can be considered in future work.

### Code coverage

We are not interested in 100% code coverage. We may provide code coverage numbers are part of our CI suite, but it is a signal to be interpreted by humans and not an automated blocker to contributions.

### Test file layout and design 

Test file layout and design should be consistent within a single file. Over time we expect most of our test files to feel similar, but we also recognize that it takes time for that style to come to light. Contributors should feel free to experiment with the format and layout of test files, but in general, we ask for consistency within any single test file.

## Summary: Maximum value with minimum maintenance costs

All roads have led to this core testing value, which is probably the most challenging part. We want to write **valuable tests** and understand the maintenance cost of the test code we contribute. Code is a liability, not an asset. A few valuable tests will better protect the project from bugs than many mediocre tests.

Over-testing with excessive implementation coupling leads to systems you can't refactor or update with speed. Low or no testing leads to unexpected regressions and low confidence about system stability.

Hopefully, the guidance of this document helps you find the productive balance when thinking about testing here within the Franklin project and others.

## More Info

This approach to testing was highly inspired by the language-agnostic book [Unit Testing Principles, Practices, and Patterns](https://www.manning.com/books/unit-testing). I highly recommend it if you want to refine your approach to testing.

I also recommend the talk [Clarity](https://www.youtube.com/watch?v=6sNmJtoKDCo&t=2277s) by Saša Jurić from ElixirConf EU 2021.
