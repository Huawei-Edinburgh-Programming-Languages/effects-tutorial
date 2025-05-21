import stdx.effect.Command

class ValueEffect <: Command<Int64> {}

main() {
    try {
        println("one")
        var foo = perform ValueEffect()
        println("three: ${foo}")
    } handle (e: ValueEffect) {
        println("two")
        resume with 99
    }
    println("four")
}