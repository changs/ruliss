require 'pry'
require 'influxdb-client'
require 'set'
require 'yaml'

require './lib/pms'
require './lib/bme280'

config = YAML.load_file('config.yml')
client = InfluxDB2::Client.new(config['influxdb']['url'], config['influxdb']['password'],use_ssl: false,
                               bucket: config['influxdb']['bucket'],
                               org: config['influxdb']['org'], precision: InfluxDB2::WritePrecision::NANOSECOND)

write_api = client.create_write_api

pms = PMS.new(ARGV[0] || '/dev/ttyUSB0')
bme = BME280.new

loop do
  s = pms.get
  point = InfluxDB2::Point.new(name: 'pm_1')
            .add_tag('location', 'office')
            .add_field('level', s[:pm1_0_env])
  point2 = InfluxDB2::Point.new(name: 'pm_25')
             .add_tag('location', 'office')
             .add_field('level', s[:pm2_5_env])
  point3 = InfluxDB2::Point.new(name: 'pm_10')
             .add_tag('location', 'office')
             .add_field('level', s[:pm10_standard])

  bme280 = bme.get
  point4 = InfluxDB2::Point.new(name: 'temperature')
             .add_tag('location', 'office')
             .add_field('level', "#{'%7.2f' % bme280.temperature}".to_f )
  point5 = InfluxDB2::Point.new(name: 'pressure')
             .add_tag('location', 'office')
             .add_field('level', "#{'%7.2f' % bme280.pressure}".to_f )
  point6 = InfluxDB2::Point.new(name: 'humidity')
             .add_tag('location', 'office')
             .add_field('level', "#{'%7.2f' % bme280.humidity}".to_f )
  begin
    write_api.write(data: [point, point2, point3, point4, point5, point6])
  rescue
    puts 'timeout'
  end
  sleep(180)
end
