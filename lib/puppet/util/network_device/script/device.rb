require 'puppet/util/network_device'
require 'puppet/util/network_device/script'
require 'puppet/util/network_device/script/facts'
require 'uri'

class Puppet::Util::NetworkDevice::Script::Device
  def initialize(url, options = {})
    @url = URI.parse(url)
    raise("Script devices need a path component indicating the script to run") if @url.path == "/"
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Script::Facts.new(@url)
    @facts.retrieve
  end
end
