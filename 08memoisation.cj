import std.collection.HashMap
import stdx.effect.Command

class Fibonacci <: Command<Int64> & Hashable & Equatable<Fibonacci> {
    Fibonacci(let n: Int64) {}
    
    public override func defaultImpl() {
        if (n <= 1) {
            1
        } else {
            fibonacci(n-1) + fibonacci(n-2)
        }        
    }
    
    
    public override operator func ==(other: Fibonacci) { n == other.n }
    public override operator func !=(other: Fibonacci) { n != other.n }
    public override func hashCode() { n.hashCode() }    
}

func fibonacci(n: Int64) {
    perform Fibonacci(n)
}

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

main() {
    println("uncached")
    for (i in 0 .. 10) {
        println(i)
        fibonacci(30)
    }
    
    println("cached")
    cache<Fibonacci, Int64, Unit> {
        for (i in 0 .. 10) {
            println(i)
            fibonacci(30)
        }
    }
}