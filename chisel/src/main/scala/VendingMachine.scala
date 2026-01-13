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

  // Constants
  val PRICE0 = 3.U 
  val PRICE1 = 5.U
  val V50    = 1.U
  val V1L    = 2.U
  val V5L    = 10.U
  val MAX_AMOUNT = 20.U

  // States
  // S_ASTEAPTA, S_BANI, S_REST
  val sIdle :: sMoney :: sChange :: Nil = Enum(3)
  val state = RegInit(sIdle)

  // Registers
  val amount = RegInit(0.U(5.W)) // 0 to 20 needs 5 bits

  // Default Output Values
  io.dispense_prod := 0.U
  io.change_out    := false.B
  io.change_type   := 0.U
  io.coin_reject   := false.B

  // Coin Value Interpretation
  val coin_value = WireDefault(0.U(4.W))
  when (io.coin_valid) {
    switch (io.coin_in) {
      is ("b001".U) { coin_value := V50 }
      is ("b010".U) { coin_value := V1L }
      is ("b100".U) { coin_value := V5L }
    }
  }

  // Selected Price
  val selected_price = Mux(io.prod_sel, PRICE1, PRICE0)

  // State Machine
  switch (state) {
    is (sIdle) { // S_ASTEAPTA
      handleWaitOrMoney()
    }
    is (sMoney) { // S_BANI
      handleWaitOrMoney()
    }
    is (sChange) { // S_REST
      // Logic for dispensing change
      when (amount >= V1L) {
        io.change_out  := true.B
        io.change_type := "b10".U
        amount         := amount - V1L
      } .elsewhen (amount >= V50) {
        io.change_out  := true.B
        io.change_type := "b01".U
        amount         := amount - V50
      } .otherwise {
        state := sIdle
      }
      
      // If amount is 0, go to Idle (VHDL logic check)
      when (amount === 0.U) {
        state := sIdle
      }
    }
  }

  // Helper logic for S_ASTEAPTA and S_BANI
  def handleWaitOrMoney(): Unit = {
    // 1. Process Coin Insertion
    when (io.coin_valid && coin_value > 0.U) {
      when (amount + coin_value <= MAX_AMOUNT) {
        amount := amount + coin_value
        state  := sMoney
      } .otherwise {
        io.coin_reject := true.B
      }
    }

    // 2. Process Product Dispense Request
    // Note: In VHDL process, later assignments override earlier ones.
    // If req_disp happens same cycle as coin valid, this logic prevails for 'amount' and 'state'
    when (io.req_disp) {
      when (amount >= selected_price) {
        io.dispense_prod := Mux(io.prod_sel, "b10".U, "b01".U)
        amount := amount - selected_price
        state  := sMoney
      } .otherwise {
        io.dispense_prod := 0.U // Already 0 by default, but explicit matches VHDL structure
      }
    }

    // 3. Process Change Request
    // Overrides state transition if active
    when (io.req_change && amount > 0.U) {
      state := sChange
    }
  }
}
