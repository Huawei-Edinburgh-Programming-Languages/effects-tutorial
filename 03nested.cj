import stdx.effect.Command

class One <: Command<Unit> {}

class Two <: Command<Unit> {}

main() {
    try {
        perform One()
        try {
            perform One()
            perform Two()
        } handle (e: One) {
            println("One inner")
            resume
        } handle (e: Two) {
            println("Two")
            resume
        }
        perform Two()
    } handle(e: One) {
        println("One")
        resume
    }
} 
