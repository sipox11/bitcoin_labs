# Bitcoin Transaction Deserializer

AMOUNT_BYTE_SIZE = 8;
SATOSHI_MULTIPLIER = 100000000;

DEBUG = true

def littleToBigEndian(byte_stream)
    big_endian_byte_stream = "";
    for i in (0..byte_stream.length-1).step(2)
        big_endian_byte_stream = byte_stream[i..i+1] + big_endian_byte_stream
    end
    big_endian_byte_stream
end

def getVarintScriptSize(rawTx)
    # Get the first byte and convert to binary
    scriptSize = "";
    varintSize = 0;
    for i in 0..8 do 
        currentByte = rawTx[i..i+1]
        puts "Current byte -> #{currentByte}"
        hexByte = currentByte.to_i(16)
        if hexByte > 0x7F
            hexByte -= 0x80 
            currentByte = hexByte.to_s(16)
            currentByte = "0#{currentByte}" if hexByte < 0x10
            scriptSize += currentByte
        else 
            scriptSize += currentByte
            varintSize = i+1
            break
        end
    end
    return scriptSize.to_i(16), varintSize
end

originalRawTx = "60e31600000000001976a914ab68025513c3dbd2f7b92a94e0581f5d50f654e788acd0ef8000000000001976a9147f9b1a7fb68d60c536c2fd8aeaa53a8f3cc025a888ac"
rawTx = originalRawTx;

puts "Tx received: #{rawTx}\n";

# Calculate Tx Size in bytes
originalTxSize = rawTx.length/2;
txSize = originalTxSize;
puts "Size of tx: #{txSize/2} bytes\n"

# Determine the value amount that was transferred (in satoshis)
amountSatHex = littleToBigEndian(rawTx[0..2*AMOUNT_BYTE_SIZE-1]).upcase!;
puts "Amount transferred in satoshis (HEX): #{amountSatHex}\n";
puts "Amount transferred in satoshis (DEC): #{amountSatHex.to_i(16)}\n";
puts "Amount transferred in BTC: #{amountSatHex.to_i(16)/SATOSHI_MULTIPLIER.to_f}\n";

# Chop the amount bytes from the rawTx
rawTx = rawTx[2*AMOUNT_BYTE_SIZE..txSize-1]
txSize = rawTx.length;

# Determine the script size in bytes (decode Varint, 1-9 bytes)
scriptSize, varintSize = getVarintScriptSize(rawTx)
puts "VarInt field is #{varintSize.to_s(16)} (HEX) and #{varintSize} (DEC) bytes long"
puts "The script size is #{scriptSize.to_s(16)} (HEX) and #{scriptSize} (DEC) bytes long\n"

# Extract the script and remove varint and script from rawTx

varint = rawTx[0..2*varintSize-1]
script = rawTx[2*varintSize..(2*varintSize + 2*scriptSize - 1)]

puts "The varint is -> #{varint}"
puts "The script is -> #{script.upcase!}"

rawTx = rawTx[(2*varintSize + 2*scriptSize)..txSize-1]
txSize = rawTx.length







