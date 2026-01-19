import stdx.effect.{Command, Resumption}
import std.collection.*

class Yield <: Command<Unit> {}

func rrScheduler(funcs: Array<() -> Unit>): Unit {
    let numTasks = funcs.size
    let resumptions = ArrayQueue<Resumption<Unit, Unit>>(numTasks)

    for (f in funcs) {
        try {
            f()
        } handle (_: Yield, r: Resumption<Unit, Unit>) {
            resumptions.add(r)
        }
    }

    while (let Some(next) <- resumptions.remove()) {
        // Effect handlers in Cangjie are 'deep',
        // this means that resuming `next` here will
        // resume the try-handle block with its original
        // hander; so a resumption will be added to the
        // `resumptions` queue if and when another `Yield`
        // is performed.
        resume next 
    }
}

func ping() {
    for (_ in (1..1000)) {
        println("Ping")
        perform Yield()
    }
}

func pong() {
    for (_ in (1..1050)) {
        println("Pong")
        perform Yield()
    }
}

main() {
    rrScheduler(ping, pong)
}
