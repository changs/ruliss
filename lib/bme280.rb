require 'i2c/bme280'
require 'json'

class BME280
  def initialize
    @bme280 = I2C::Driver::BME280.new(device: 1)
  end
  def get
    @bme280
  end
end
