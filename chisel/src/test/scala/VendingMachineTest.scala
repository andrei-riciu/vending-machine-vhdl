import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class VendingMachineTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "VendingMachine"

  it should "replay the VHDL testbench sequence" in {
    test(new VendingMachine) { dut =>
      val V50 = "b001".U
      val V1L = "b010".U
      val V5L = "b100".U

      dut.io.coin_in.poke(0.U)
      dut.io.coin_valid.poke(false.B)
      dut.io.prod_sel.poke(false.B)
      dut.io.req_disp.poke(false.B)
      dut.io.req_change.poke(false.B)

      dut.reset.poke(true.B)
      dut.clock.step(3)
      dut.reset.poke(false.B)

      dut.clock.step(2)
      
      dut.io.coin_in.poke(V1L)
      dut.io.coin_valid.poke(true.B)
      dut.clock.step(1)

      dut.io.coin_in.poke(V50)
      dut.io.coin_valid.poke(true.B)
      dut.clock.step(1)

      dut.io.coin_valid.poke(false.B)
      dut.io.coin_in.poke(0.U)
      dut.clock.step(1)

      // "Cumpara prod0"
      dut.io.prod_sel.poke(false.B)
      dut.io.req_disp.poke(true.B)
      dut.clock.step(1)
      
      dut.io.req_disp.poke(false.B)

      dut.reset.poke(true.B)
      dut.clock.step(3)
      dut.reset.poke(false.B)

      // "Pune 5 lei"
      dut.clock.step(2)

      dut.io.coin_in.poke(V5L)
      dut.io.coin_valid.poke(true.B)
      dut.clock.step(1)

      dut.io.coin_valid.poke(false.B)
      dut.io.coin_in.poke(0.U)
      dut.clock.step(1)

      // "Cumpara prod1"
      dut.io.prod_sel.poke(true.B)
      dut.io.req_disp.poke(true.B)
      dut.clock.step(1)

      dut.io.req_disp.poke(false.B)

      // "Cere restul"
      dut.clock.step(1)
      dut.io.req_change.poke(true.B)
      dut.clock.step(10)

      dut.io.req_change.poke(false.B)

      dut.reset.poke(true.B)
      dut.clock.step(3)
      dut.reset.poke(false.B)

      // "Incearca sa depaseasca suma maxima"
      dut.clock.step(1)

      dut.io.coin_in.poke(V5L)
      dut.io.coin_valid.poke(true.B)
      dut.clock.step(1)

      dut.io.coin_in.poke(V1L)
      dut.io.coin_valid.poke(true.B)
      
      dut.clock.step(1)
      dut.clock.step(1)
      dut.clock.step(1)
      dut.clock.step(1)
      dut.clock.step(1)
      
      // "Am atins suma maxima, urmatoarele monede trebuie respinse"
      dut.clock.step(1) 
      // Banii ar trebui respinsi
      dut.io.coin_reject.expect(true.B)

      dut.clock.step(1)
    }
  }
}
