require 'uart'
require 'io/wait'

class Sample < Struct.new(:time,
                          :pm1_0_standard, :pm2_5_standard, :pm10_standard,
                          :pm1_0_env,      :pm2_5_env,
                          :concentration_unit,
                          :particle_03um,   :particle_05um,   :particle_10um,
                          :particle_25um,   :particle_50um,   :particle_100um)
end

class PMS
  def initialize(arg)
    @uart = UART.open arg, 9600, '8N1'
  end
  def get
    @uart.wait_readable
    start1, start2 = @uart.read(2).bytes

    unless start1 == 0x42 && start2 == 0x4d
      @uart.read
      return
    end

    length = @uart.read(2).unpack('n').first
    data = @uart.read(length)
    crc  = 0x42 + 0x4d + 28 + data.bytes.first(26).inject(:+)
    data = data.unpack('n14')

    return unless crc == data.last

    Sample.new(Time.now, *data.first(12))
  end
end
