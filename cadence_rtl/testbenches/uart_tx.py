import serial

def read_binary(serial_port: str, baudrate: int):
    """
    Reads and prints 8-bit binary data from the specified serial port.
    :param serial_port: The serial port (e.g., 'COM6' on Windows or '/dev/ttyUSB0' on Linux/Mac)
    :param baudrate: Baud rate for communication
    """
    try:
        with serial.Serial(port=serial_port, baudrate=baudrate, bytesize=serial.EIGHTBITS,
                           parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, timeout=1) as ser:
            print(f"Listening on {serial_port} at {baudrate} baud...")
            
            while True:
                byte_received = ser.read(1)  # Read one byte
                if byte_received:
                    binary_data = format(int.from_bytes(byte_received, 'big'), '08b')
                    print(f"Received: {binary_data} (0x{byte_received.hex()})")
    except serial.SerialException as e:
        print(f"Error: {e}")


read_binary(serial_port='COM6', baudrate=625000)