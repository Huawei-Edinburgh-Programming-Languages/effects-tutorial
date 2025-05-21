import stdx.effect.Command

class Example <: Command<Unit> {}

main() {
	try {
		println("one")
		perform Example()
		println("three")
	} handle (e: Example) {
		println("two")
		resume
	}
	println("four")
}
