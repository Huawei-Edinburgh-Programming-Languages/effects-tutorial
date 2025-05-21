import stdx.effect.Command

class ValueEffect <: Command<Int64> {}

main() {
    try {
        println("one")
        var foo = perform Example()
        println("three: ${foo}")
    } handle (e: Example) {
        println("two")
        resume with 99
    }
    println("four")
}