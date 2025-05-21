import stdx.effect.{Command, Resumption}

class EffException <: Command<Unit> {
    public EffException(let msg: String) {}
}


main() {
    try {
        println("one")
        perform EffException("error")
        println("three")
    } handle(e: EffException, _: Resumption<Unit, Unit>) {
        println("two: ${e.msg}")
    }
    println("four")
}