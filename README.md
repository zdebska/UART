# UART
Universal Asynchronous Receiver-Transmitter

## Technical task

The development of the project is divided into two parts. In the first part, we design the functioning of the circuit at the RTL level and also the logic of its control automaton. 
The second part focuses on implementing the designed circuit in VHDL and debugging its correct functionality using digital circuit simulation tools.


## Description
1. Design a circuit for receiving data words over an asynchronous serial link (UART_RX).  
The UART_RX circuit will receive individual bits on the DIN input data port, de-serialize them, and write the resulting
8-bit word to the DOUT data port. Confirm the validity of the data word on the DOUT port by setting the DOUT_VLD flag to logic 1 for one clock cycle of the CLK clock signal.

2. Implement the designed RTL circuit from the first part of the project in VHDL in the file uart_rx.vhd.
Put the code corresponding to the final automaton into the file uart_rx_fsm.vhd.
Perform synthesis and simulation of VHDL code by running the prepared uart.sh script using GHDL and GTKWave.

## Results
My circuit, FSM, and a screenshot of the simulation you can see in [zprava](https://github.com/zdebska/UART/blob/main/zprava.pdf).
