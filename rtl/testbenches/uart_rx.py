import serial
import time

def transmit_binary(serial_port: str, baudrate: int, binary_data: str):
    """
    Transmits 8-bit binary data through the serial port.
    :param serial_port: The serial port (e.g., 'COM3' on Windows or '/dev/ttyUSB0' on Linux/Mac)
    :param baudrate: Baud rate for communication
    :param binary_data: 8-bit binary string (e.g., '11001010')
    """
    if len(binary_data) != 8 or not all(bit in '01' for bit in binary_data):
        raise ValueError("Binary data must be exactly 8 bits (e.g., '11001010')")
    
    binary_data = binary_data
    
    # Convert binary string to bytes
    byte_to_send = int(binary_data, 2).to_bytes(1, byteorder='big')
    
    try:
        with serial.Serial(port=serial_port, baudrate=baudrate, bytesize=serial.EIGHTBITS,
                           parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, timeout=1) as ser:
            print(f"Transmitting: {binary_data} ({byte_to_send.hex()})")
            ser.write(byte_to_send)
            time.sleep(0.1)  # Small delay for stability
    except serial.SerialException as e:
        print(f"Error: {e}")


transmit_binary(serial_port='COM6', baudrate=625000, binary_data='00110011')