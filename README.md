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
In addition to changing control flow, `perform` can return a value and `resume` can take an argument:

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
Effect handler have similar behaviour to exceptions when it comes to handler resolution. When we perform an effect, the runtime searches up the stack for the first handler than handles the type of effect we have performed:

```
try {
    perform One()
    try {
        perform One()
        perform Two()
    } handle (e: One) {
        println("One inner")
    } handle (e: Two) {
        println("Two")
    }
    perform Two()
} handle(e: One) {
    println("One")
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
So far, all the examples we have shown have resumed immediately after handling the effect. However, we do have the option of not resuming. If we want to ignore the resumption, or store it for later use, we can used the "deferred" handle block as shown below:

```
handle(e: Effect, res: Resumption<Unit>) {
    ...
}
```

We can use this to implement behaviour equivalent to classical exceptions, as shown in [04exceptions.cj](04exceptions.cj):


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

## 6. Dependency Injection
C
## 7. Custom Concurrency
