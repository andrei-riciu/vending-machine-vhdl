import chisel3._
import chisel3.util._

class VendingMachine extends Module {
  val io = IO(new Bundle {
    val coin_in       = Input(UInt(3.W))
    val coin_valid    = Input(Bool())
    val prod_sel      = Input(Bool())
    val req_disp      = Input(Bool())
    val req_change    = Input(Bool())

    val dispense_prod = Output(UInt(2.W))
    val change_out    = Output(Bool())
    val change_type   = Output(UInt(2.W))
    val coin_reject   = Output(Bool())
  })

  val PRICE0 = 3.U 
  val PRICE1 = 5.U

  val V50    = 1.U
  val V1L    = 2.U
  val V5L    = 10.U

  val MAX_AMOUNT = 20.U

  val sIdle :: sMoney :: sChange :: Nil = Enum(3)
  
  val state = RegInit(sIdle)
  val amount = RegInit(0.U(5.W))
  val dispense_reg = RegInit(0.U(2.W))
  val change_out_reg = RegInit(false.B)
  val change_type_reg = RegInit(0.U(2.W))
  val coin_reject_reg = RegInit(false.B)

  val next_state = WireDefault(state)
  val next_amount = WireDefault(amount)
  val next_dispense = WireDefault(0.U(2.W))
  val next_change_out = WireDefault(false.B)
  val next_change_type = WireDefault(0.U(2.W))
  val next_coin_reject = WireDefault(false.B)

  state := next_state
  amount := next_amount
  dispense_reg := next_dispense
  change_out_reg := next_change_out
  change_type_reg := next_change_type
  coin_reject_reg := next_coin_reject

  io.dispense_prod := dispense_reg
  io.change_out    := change_out_reg
  io.change_type   := change_type_reg
  io.coin_reject   := coin_reject_reg

  val coin_value = WireDefault(0.U(4.W))
  when (io.coin_valid) {
    switch (io.coin_in) {
      is ("b001".U) { coin_value := V50 }
      is ("b010".U) { coin_value := V1L }
      is ("b100".U) { coin_value := V5L }
    }
  }

  val selected_price = Mux(io.prod_sel, PRICE1, PRICE0)

  switch (state) {
    is (sIdle) {
      handleWaitOrMoney()
    }
    is (sMoney) {
      handleWaitOrMoney()
    }
    is (sChange) {
      when (amount >= V1L) {
        next_change_out  := true.B
        next_change_type := "b10".U
        next_amount      := amount - V1L
      } .elsewhen (amount >= V50) {
        next_change_out  := true.B
        next_change_type := "b01".U
        next_amount      := amount - V50
      } .otherwise {
        next_state := sIdle
      }
      
      when (amount === 0.U) {
        next_state := sIdle
      }
    }
  }

  def handleWaitOrMoney(): Unit = {
    when (io.coin_valid && coin_value > 0.U) {
      when (amount + coin_value <= MAX_AMOUNT) {
        next_amount := amount + coin_value
        next_state  := sMoney
      } .otherwise {
        next_coin_reject := true.B
      }
    }

    when (io.req_disp) {
      when (amount >= selected_price) {
        next_dispense := Mux(io.prod_sel, "b10".U, "b01".U)
        next_amount   := amount - selected_price
        next_state    := sMoney
      } .otherwise {
        next_dispense := 0.U
      }
    }

    when (io.req_change && amount > 0.U) {
      next_state := sChange
    }
  }
}
