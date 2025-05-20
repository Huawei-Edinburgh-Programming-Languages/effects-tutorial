import stdx.effect.Command

class Default <: Command<Unit> {
    public func defaultImpl() {
        println("default")
    }
}

main() {
    println("one")
    perform Default()
    println("two")
}