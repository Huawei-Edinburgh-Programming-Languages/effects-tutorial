import stdx.effect.Command

class Yield <: Command<Unit> {}

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