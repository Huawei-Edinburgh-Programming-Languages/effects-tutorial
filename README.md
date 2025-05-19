# Cangjie Effect Hanlers Tutorial

## Simple example

To use effects, we must first define a type that inherits from `Command<T>`:

```
class Example <: Command<Unit> {}
```

We can peform this effect by passing an instance in a perform expression:

```
perform Example()
```


