import stdx.effect.Command

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