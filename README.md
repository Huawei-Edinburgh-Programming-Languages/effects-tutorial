# Cangjie Effect Handlers Tutorial

## 1. Simple Example

To use effects, we must first define a type that inherits from `Command<T>`:

```
class Example <: Command<Unit> {}
```

We can peform this effect by passing an instance in a perform expression:

```
perform Example()
```


To fully use effects, we have to use a `try-handle` expression:

```
try {
    println("one")
    perform Example()
    println("three")
} handle (e: Example) {
    println("two")
    resume
}
println("four")
```

The control flow of this can be explained by looking at the output of the program:

```
one
two
three
four
```

The full listing can be found in [01basic.cj](01basic.cj)


## 2. Producing a Value
In addition to changing control flow, `perform` can return a value and
`resume` can take an argument:

```
try {
    println("one")
    var foo = perform Example()
    println("three: ${foo}")
} handle (e: Example) {
    println("two")
    resume with 99
}
println("four")
```

This time, the output will be:
```
one
two
three: 99
four
```

The full listing is in [02value.cj](02value.cj)

## 3. Nested Effects and Dynamic Binding
Effect handler have similar behaviour to exceptions when it comes to
handler resolution. When we perform an effect, the runtime searches up
the stack for the first handler than handles the type of effect we have
performed:

```
try {
    perform One()
    try {
        perform One()
        perform Two()
    } handle (e: One) {
        println("One inner")
        resume
    } handle (e: Two) {
        println("Two")
        resume
    }
    perform Two()
} handle(e: One) {
    println("One")
    resume
}
```

The resulting output will be

```
One
One inner
Two
Error: unhandled exception "Unhandled effect"
```

The full listing is in [03nested.cj](03nested.cj)

## 4. Deferred Resumptions and Implementing Exceptions
So far, all the examples we have shown have resumed immediately after
handling the effect. However, we do have the option of not resuming. If
we want to ignore the resumption, or store it for later use, we can used
the "deferred" handle block as shown below:

```
handle(e: Effect, res: Resumption<Unit>) {
    ...
}
```

We can use this to implement behaviour equivalent to classical
exceptions, as shown in [04exceptions.cj](04exceptions.cj):


```
class EffException <: Command<Unit> {
    public EffException(let msg:String = msg) {}
}


main() {
    try {
        println("one")
        perform EffException("error")
        println("three")
    } handle(e: EffException, _: Resumption<Unit>) {
        println("two:  ${e.msg}")
    }
    println("four")
}
```

The output of this program will be:

```
one
two: error
four
```

the line
```
println("three")
```
will never execute.

## 5. Default Handlers
We have the option of defining a default handler for a `Command<T>`,
meaning that an unhandled effect will be handled by a global handler for
that type.

A default handler is defined by defining the `defaultImpl` instance method:

```
class Default <: Command<Unit> {
    public func defaultImpl() {
        println("default")
    }
}
```

Running the following program
```
println("one")
perform Default()
println("two")
```

will result in 
```
one
default
two
```
with no errors produced

The full listing is in [05default.cj](05default.cj)

## 6. Dependency Injection
Dependency inject is widely used in real-world applications. This is
often provided by a heavyweight framework.

However, effect handlers can provide dependency injection as a built-in language feature.

Given an `Alert` effect:

```
class Alert <: Command<Unit> {
    Alert(let message: String = message) {}
}
```

We then abstract alert notifications from our application:

```
func app() {
    var error = true
    if (error) {
        perform Alert("error")
    }
}
```

Then we define different handlers that inject the dependencies and run the application:

```
func stdOutHandler(fn: () -> Unit) {
    try {
        fn()
    } handle(e: Alert) {
        println(e.message)
    }
}

func popupHandler(fn: () -> Unit) {
    try {
        fn()
    } handle(e: Alert) {
        makePopup(e.message)
    }
}

main() {
    stdOutHandler {
        application()
    }
    
    // or
    
    popUpHandler {
        application()
    }
}
```

Note the trailing closure syntax:
```
popUpHandler {
   application()
}
```
is equivalent to
```
popUpHandler({ => application() })
```

The full listing can be found in [06dependencyinjection.cj](06dependencyinjection.cj)

## 7. Custom Concurrency
One of the most powerful features of effect handlers is the ability to
implement multiple types lightweight concurrency.

[07concurrency.cj](07concurrency.cj) implements a very basic round-robin
scheduler that allows two "threads" to execute and interleave
cooperatively

```
func rrScheduler(one: () -> Unit, two: () -> Unit) {
    try {
        one()
    } handle(_: Yield) {
        rrScheduler(u, { => resume })
    }
}

func ping() {
    println("Ping")
    perform Yield()
    println("Ping")
    perform Yield()
}

func pong() {
    println("Pong")
    perform Yield()
    println("Pong")
    perform Yield()
}

main() {
    rrScheduler(ping, pong)
}
```

This will output
```
Ping
Pong
Ping
Pong
```

## 8. Memoization 

[08memoisation.cj](08memoisation.cj) shows an example of using effect
handlers to cache results from recursive fibonacci calls.

We start by defining an effect that represents a fibonacci computation:

```
struct Fibonacci <: Command<Int64> & Hashable & Equatable<Fibonacci> {
    Fibonacci(let n: Int64) {}
    
    public override func defaultImpl() {
        if (n < = 1) {
            1
        } else {
            fibonacci(n-1) + fibonacci(n-2)
        }        
    }
    
    
    public override operator func ==(other: Fibonacci) { n == other.n }
    public override operator func 1=(other: Fibonacci) { n != other.n }
    public override func hashCode() { n.hashCode() }    
}
```

This uses default handlers to compute a traditional recursive fibonacci computation.

We wrap this to expose a normal API to the user:
```
func fibonacci(n: Int64) {
    perform Fibonacci(n)
}
```

Calling this in a loop like below will be very slow, due to repeated exponential complexity function calls.

```
main() {
    for (i in 0 .. 100) {
        fibonacci(i)
    }
}
```

However, we can see that this can be optimised by memoizing previously computed result:

```
func cache<Cmd, Result, Return>(fn: () -> Return): Return where Cmd <: Hashable & Equatable<Cmd> & Command<Result> {
    let map = HashMap<Cmd, Result>()
    try {
        fn()
    } handle(cmd: Cmd) {
        let result  = match (map.get(cmd)) {
            case None =>
                let result = perform cmd
                map.add(cmd, result)
                result
            case Some(cached) =>
                cached
        }
        resume with result
    }
}
```

This function runs code in a `try-handle` block and handles generic
commands. If the command has been cached, it returns the previous
result; otherwise, it re-performs the effect. In the case of our
Fibonacci effect, this will run the default handler.


When we re-run the function with our cache handler, the performance will now be linear.

```
main() {
    cache {
        for (i in 0 .. 100) {
            fibonacci(i)
        }
    }
}
```