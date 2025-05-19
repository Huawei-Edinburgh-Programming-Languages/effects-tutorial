# Cangjie Effect Hanlers Tutorial

## 1. Simple example

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


## 2. Producing a value
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